//
//  PathPhysicsMotion.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import CoreGraphics

/// A closure used to provide status updates for a ``PathPhysicsMotion`` object.
/// - Parameter motion: The ``PathPhysicsMotion`` object which published this update closure.
/// - Parameter currentPoint: The current position of a point being animated along a path.
public typealias PathPhysicsMotionUpdateClosure = (_ motion: PathPhysicsMotion, _ currentPoint: CGPoint) -> Void

/**
 *  This notification closure should be called when the `start` method starts a motion operation. If a delay has been specified, this closure is called after the delay is complete.
 *
 *  - seealso: start
 */
public typealias PathPhysicsMotionStarted = PathPhysicsMotionUpdateClosure

/**
 *  This notification closure should be called when the `stop` method starts a motion operation.
 *
 *  - seealso: stop
 */
public typealias PathPhysicsMotionStopped = PathPhysicsMotionUpdateClosure


/**
 *  This notification closure should be called when the `update(withTimeInterval:)` method is called while a Moveable object is currently moving.
 *
 *  - seealso: update(withTimeInterval:)
 */
public typealias PathPhysicsMotionUpdated = PathPhysicsMotionUpdateClosure


/**
 *  This notification closure should be called when a motion operation reverses its movement direction.
 *
 */
public typealias PathPhysicsMotionReversed = PathPhysicsMotionUpdateClosure

/**
 *  This notification closure should be called when a motion has started a new repeat cycle.
 *
 */
public typealias PathPhysicsMotionRepeated = PathPhysicsMotionUpdateClosure

/**
 *  This notification closure should be called when calling the `pause` method pauses a motion operation.
 *
 */
public typealias PathPhysicsMotionPaused = PathPhysicsMotionUpdateClosure

/**
 *  This notification closure should be called when calling the `resume` method resumes a motion operation.
 *
 */
public typealias PathPhysicsMotionResumed = PathPhysicsMotionUpdateClosure

/**
 *  This notification closure should be called when a motion operation has fully completed.
 *
 *  - remark: This closure should only be executed when all activity related to the motion has ceased. For instance, if a Moveable class allows a motion to be repeated multiple times, this closure should be called when all repetitions have finished.
 *
 */
public typealias PathPhysicsMotionCompleted = PathPhysicsMotionUpdateClosure


/// PathPhysicsMotion handles a single motion operation of a coordinate point along a `CGPath` using a physics system to update the value with a decaying velocity. It does not directly accept `PropertyData` objects, but instead transforms a value between 0.0 and 1.0, representing the length of the associated path. Using this value, it updates the current point on the path.
@MainActor public class PathPhysicsMotion: Moveable, TempoDriven, PropertyDataDelegate {

    // Default limit for a velocity's decay.
    static let DEFAULT_DECAY_LIMIT: Double = 0.95
    
    
    // MARK: - Public Properties
    
    ///-------------------------------------
    /// Setting Up a Motion
    ///-------------------------------------
    
    /**
     *  The delay, in seconds, before a motion operation begins.
     *
     *  - warning: Setting this parameter after a motion operation has begun has no effect.
     */
    public var delay: TimeInterval = 0.0
    
    
    /**
     *  A Boolean which determines whether a motion operation should repeat. When set to `true`, the motion operation repeats for the number of times specified by the `repeatCycles` property. The default value is `false`.
     *
     *  - note: By design, setting this value to `true` without changing the `repeatCycles` property from its default value will cause the motion to repeat infinitely.
     *  - seealso: repeatCycles
     */
    public var repeating: Bool = false
    
    
    /**
     *  The number of motion cycle operations to repeat.
     *
     *  - remark: This property is only used when `repeating` is set to `true`. Assigning `REPEAT_INFINITE` to this property signals an infinite amount of motion cycle repetitions. The default value is `REPEAT_INFINITE`.
     *
     *  - seealso: repeating
     */
    public var repeatCycles: UInt = REPEAT_INFINITE

    
    /**
     *  An object conforming to the `ValueAssistant` protocol which acts as an interface for retrieving and updating value types.
     *
     *  - remark: By default, PhysicsMotion will assign an instance of the `ValueAssistantGroup` class with value assistants for Core Foundation structs and UIKit colors. You may add your own custom type assistants to this group, or replace it with your own custom `ValueAssistant` implementation.
     */
    public var valueAssistant: ValueAssistant = ValueAssistantGroup(assistants: [CGStructAssistant()])
    
    
    /**
     *  An operation ID is assigned to a PhysicsMotion instance when it is moving an object's property (via initWithObject...) and its motion operation is currently in progress. (read-only)
     *
     *  - remark: This value returns 0 if no ID is currently assigned.
     */
    private(set) public var operationID: UInt = 0
    

    
    // MARK: Physics properties
    
    /**
     *  An object conforming to the `PhysicsSolving` protocol which solves position calculation updates.
     *
     *  - remark: By default, PhysicsMotion will assign an instance of `PhysicsSystem` to this property, but you can override this with your own custom physics system.
     */
    public var physicsSystem: PhysicsSolving
    
    /**
     *  The current velocity used by the physics system to calculate motion values, measured in units per second.
     *
     *  - remark: If you wish to change the velocity after initially setting it via one of the init methods, use this setter. If you change the velocity directly on the `physicsSystem` object, the `motionProgress` property won't be accurate.
     */
    public var velocity: Double {
        get {
            return physicsSystem.velocity
        }
        
        set {
            physicsSystem.velocity = newValue
            initialVelocity = velocity
        }
 
    }
    
    /**
     *  The current friction coefficient used by the physics system.
     *
     *  - remark: A value range between 0.0 and 1.0, with 1.0 representing very high friction and 0.0 representing almost no friction (setting this property to 0.0 will actually set it a bit fractionally higher than 0.0 to avoid divide-by-zero errors during calculations).
     */
    public var friction: Double = 0.0 {
        didSet {
            physicsSystem.friction = friction
        }
    }
    
    /**
     *  This value is used to determine whether the object modeled by the physics system has come to rest due to deceleration.
     *
     *  - remark: The way in which `PhysicsSystem` applies friction means that as velocity approaches 0.0, it will be assigned smaller and smaller fractional numbers, so we need a reasonable cutoff that approximates the velocity coming to rest. The default value is the constant DEFAULT_DECAY_LIMIT (set to 0.95), which is fine for display properties, but you may prefer other values.
     */
    public var velocityDecayLimit: Double = PhysicsMotion.DEFAULT_DECAY_LIMIT
    
    
    /**
     *  Specifies a time step for the physics solver, which is updated independently of motion value updates. The default value calls the physics system 120 times a second, which provides double the precision if your app is rendering at 60 fps.
     */
    public var physicsTimerInterval: TimeInterval = 1.0 / 120.0 // call the physics system at 120 fps
    
    
    // MARK: Property collection methods
    
    /**
     *  The collection of `PropertyData` instances, representing the object's properties being moved.
     *
     *  - remark: The `path` property of each `PropertyData` must be a valid KVC-compliant keyPath of `targetObject`.
     *  - seealso: targetObject
     */
    private(set) public var properties: [PropertyData] = []
    
    
    // MARK: Motion state properties
    
    /// The target object whose property should be moved.
    private(set) public var targetObject: NSObject?
    
    /// A `MotionState` enum which represents the current movement state of the motion operation. (read-only)
    private(set) public var motionState: MotionState
    
    /// A `MotionDirection` enum which represents the current direction of the motion operation. (read-only)
    private(set) public var motionDirection: MotionDirection
    
    /**
     *  A value between 0.0 and 1.0, which represents the current progress of a movement between two value destinations. (read-only)
     *
     *  - remark: Be aware that if this motion is `reversing` or `repeating`, this value will only represent one movement. For instance, if a PhysicsMotion has been set to repeat once, this value will move from 0.0 to 1.0, then reset to 0.0 again as the new repeat cycle starts. Similarly, if a PhysicsMotion is set to reverse, this progress will represent each movement; first in the forward direction, then again when reversing back to the starting values.
     */
    private(set) public var motionProgress: Double {
        
        get {
            return _motionProgress
        }
        
        set(newValue) {
            _motionProgress = newValue
            
            // sync cycleProgress with motionProgress so that cycleProgress always represents total cycle progress
            if (reversing && motionDirection == .forward) {
                _cycleProgress = _motionProgress * 0.5
            } else if (reversing && motionDirection == .reverse) {
                _cycleProgress = (_motionProgress * 0.5) + 0.5
            } else {
                _cycleProgress = _motionProgress
            }
            
            
        }
        
    }
    private var _motionProgress: Double = 0.0
    
    
    /**
     *  A value between 0.0 and 1.0, which represents the current progress of a motion cycle. (read-only)
     *
     *  - remark: A cycle represents the total length of a one motion operation. If `reversing` is set to `true`, a cycle comprises two separate movements (the forward movement, which at completion will have a value of 0.5, and the movement in reverse which at completion will have a value of 1.0); otherwise a cycle is the length of one movement. Note that if `repeating`, each repetition will be a new cycle and thus the progress will reset to 0.0 for each repeat.
     */
    private(set) public var cycleProgress: Double {
        get {
            return _cycleProgress
        }
        
        set(newValue) {
            _cycleProgress = newValue
            
            // sync motionProgress with cycleProgress, so we modify the ivar directly (otherwise we'd enter a recursive loop as each setter is called)
            if (reversing) {
                var new_progress = _cycleProgress * 2
                if (_cycleProgress >= 0.5) { new_progress -= 1 }
                _motionProgress = new_progress
                
            } else {
                _motionProgress = _cycleProgress
            }
            
        }
    }
    private var _cycleProgress: Double = 0.0
    
    
    /**
     *  The amount of completed motion cycles.  (read-only)
     *
     * - remark: A cycle represents the total length of a one motion operation. If `reversing` is set to `true`, a cycle comprises two separate movements (the forward movement and the movement in reverse); otherwise a cycle is the length of one movement. Note that if `repeating`, each repetition will be a new cycle.
     */
    private(set) public var cyclesCompletedCount: UInt = 0
    
    
    /**
     *  A value between 0.0 and 1.0, which represents the current overall progress of the PhysicsMotion. This value should include all reversing and repeat motion cycles. (read-only)
     *
     *  - remark: If a Motion is not repeating, this value will be equivalent to the value of `cycleProgress`.
     *  - seealso: cycleProgress
     *
     */
    public var totalProgress: Double {
        get {
            // sync totalProgress with cycleProgress
            if (repeating && repeatCycles > 0 && cyclesCompletedCount < (repeatCycles+1)) {
                return (_cycleProgress + Double(cyclesCompletedCount)) / Double(repeatCycles+1)
            } else {
                return _cycleProgress
            }
        }
        
    }
    
    
    
    // MARK: Moveable protocol properties
    
    /// A Boolean which determines whether a motion operation, when it has moved to the ending value, should move from the ending value back to the starting value.
    public var reversing: Bool = false
    
    /// Provides a delegate for updates to a Moveable object's status, used by `Moveable` collections.
    public var updateDelegate: MotionUpdateDelegate?
    
    
    
    // MARK: TempoDriven protocol properties
    
    /**
     *  A concrete `Tempo` subclass that provides an update "beat" while a motion operation occurs.
     *
     *  - remark: By default, PhysicsMotion will assign an instance of `CATempo` to this property, which uses `CADisplayLink` for interval updates.
     */
    public var tempo: Tempo? {
        
        get {
            return _tempo
        }
        
        set(newValue) {
            if _tempo != nil {
                _tempo?.delegate = nil
                _tempo = nil
            }
            
            _tempo = newValue
            _tempo?.delegate = self
            
        }
    }
    lazy private var _tempo: Tempo? = {
        return CATempo.init()
    }()
    
    
    
    // MARK: - Notification closures
    
    /**
     *  This closure is called when a motion operation starts.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: start
     */
    @discardableResult public func started(_ closure: @escaping PathPhysicsMotionStarted) -> Self {
        _started = closure
        
        return self
    }
    private var _started: PathPhysicsMotionStarted?
    
    /**
     *  This closure is called when a motion operation is stopped by calling the `stop` method.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: stop
     */
    @discardableResult public func stopped(_ closure: @escaping PathPhysicsMotionStopped) -> Self {
        _stopped = closure
        
        return self
    }
    private var _stopped: PathPhysicsMotionStopped?
    
    /**
     *  This closure is called when a motion operation update occurs and this instance's `motionState` is `.Moving`.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: update(withTimeInterval:)
     */
    @discardableResult public func updated(_ closure: @escaping PathPhysicsMotionUpdated) -> Self {
        _updated = closure
        
        return self
    }
    private var _updated: PathPhysicsMotionUpdated?
    
    /**
     *  This closure is called when a motion cycle has completed.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: repeating, cyclesCompletedCount
     */
    @discardableResult public func cycleRepeated(_ closure: @escaping PathPhysicsMotionRepeated) -> Self {
        _cycleRepeated = closure
        
        return self
    }
    private var _cycleRepeated: PathPhysicsMotionRepeated?
    
    /**
     *  This closure is called when the `motionDirection` property changes to `reversing`.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: motionDirection, reversing
     */
    @discardableResult public func reversed(_ closure: @escaping PathPhysicsMotionReversed) -> Self {
        _reversed = closure
        
        return self
    }
    private var _reversed: PathPhysicsMotionReversed?
    
    /**
     *  This closure is called when calling the `pause` method on this instance causes a motion operation to pause.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: pause
     */
    @discardableResult public func paused(_ closure: @escaping PathPhysicsMotionPaused) -> Self {
        _paused = closure
        
        return self
    }
    private var _paused: PathPhysicsMotionPaused?
    
    /**
     *  This closure is called when calling the `resume` method on this instance causes a motion operation to resume.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: resume
     */
    @discardableResult public func resumed(_ closure: @escaping PathPhysicsMotionResumed) -> Self {
        _resumed = closure
        
        return self
    }
    private var _resumed: PathPhysicsMotionResumed?
    
    /**
     *  This closure is called when a motion operation has completed (or when all motion cycles have completed, if `repeating` is set to `true`).
     *
     *  - remark: This method can be chained when initializing the object.
     */
    @discardableResult public func completed(_ closure: @escaping PathPhysicsMotionCompleted) -> Self {
        _completed = closure
        
        return self
    }
    private var _completed: PathPhysicsMotionCompleted?
    
    /// The object maintaining state on the path.
    public private(set) var pathState: PathState
    
    /// This Boolean represents whether collision detections are active in the physics simulation. If `true`, collisions will be checked using the `start` and `end` properties of each ``PropertyData`` object passed in to the ``solve(forPositions:timestamp:)`` method. The default value is `false`.
    public var useCollisionDetection: Bool {
        get {
            return physicsSystem.useCollisionDetection
        }
        set {
            physicsSystem.useCollisionDetection = newValue
        }
    }
    
    
    // MARK: - Private Properties
    
    /// The starting time of the current motion operation. A value of 0.0 means that the motion is not in progress.
    private var startTime: TimeInterval = 0.0
    
    /// The most recent update timestamp, sent to the `update` method.
    private var currentTime: TimeInterval = 0.0
    
    /// The ending time of the motion, which is determined by adding the motion duration to the starting time.
    private var endTime: TimeInterval = 0.0
    
    /// Boolean value representing whether the object of the property should be reset when we repeat or restart the motion.
    private var resetObjectStateOnRepeat: Bool = false
    
    /**
     *  Tracks the number of completed motions. Not incremented when repeating.
     *
     *  - note: Currently this property only exists in order to avoid PhysicsMotions not moving when a `MotionSequence` they're being controlled by, whose `reversingMode` is set to `sequential`, reverses direction. Without checking this property in the `assignStartingPropertyValue` method, `PropertyData` objects with `useExistingStartValue` set to `true` (which occurs whenever a `PropertyData` is created without an explicit `start` value) would end up with their `start` and `end` values being equal, and thus no movement would occur. (whew)
     */
    private var completedCount: UInt = 0
    
    /// Timestamp set when the `pause` method is called; used to track the amount of time paused.
    private var pauseTimestamp: TimeInterval = 0.0
    
    /// A Timer which calls the physics update calculation at fixed rate, separate from display rate
    private var physicsTimer: Timer?
    
    // The last initial velocity set.
    private var initialVelocity: Double = 0.0
    
    
    // MARK: - Initialization
    
    /// A convenience initializer.
    /// - Parameters:
    ///   - path: A `CGPath` object to use as a motion guide.
    ///   - configuration: A configuration model containing data to set up this object's ``PhysicsSystem`` for physics calculations.
    ///   - startPosition: An optional starting value, corresponding to a percentage along the path's length where the motion should begin. The range must be between 0.0 and 1.0; values outside that range will be clamped to the minimum or maximum value. The default value is 0.0.
    ///   - endPosition: An optional ending value, corresponding to a percentage along the path's length where the motion should end. The range must be between 0.0 and 1.0; values outside that range will be clamped to the minimum or maximum value. The default value is 1.0.
    ///   - edgeBehavior: Determines how path edges are handled during a motion when the motion attempts to travel past the path's edges. This is rare, but can occur in some cases such as the ``EasingBack`` and ``EasingElastic`` easing equations. The default value is `stopAtEdges`.
    ///   - options: An optional options model.
    public convenience init(path: CGPath, configuration: PhysicsConfiguration, startPosition: Double? = nil, endPosition: Double? = nil, edgeBehavior: PathEdgeBehavior? = nil, options: MotionOptions? = MotionOptions.none) {
        
        let state = PathState(path: path)
        self.init(pathState: state, velocity: configuration.velocity, friction: configuration.friction, restitution: configuration.restitution, useCollisionDetection: configuration.useCollisionDetection, startPosition: startPosition, endPosition: endPosition, edgeBehavior: edgeBehavior, options: options)
    }
    
    /// A convenience initializer.
    /// - Parameters:
    ///   - path: A state object containing information about the path to use as a motion guide.
    ///   - configuration: A configuration model containing data to set up this object's ``PhysicsSystem`` for physics calculations.
    ///   - startPosition: An optional starting value, corresponding to a percentage along the path's length where the motion should begin. The range must be between 0.0 and 1.0; values outside that range will be clamped to the minimum or maximum value. The default value is 0.0.
    ///   - endPosition: An optional ending value, corresponding to a percentage along the path's length where the motion should end. The range must be between 0.0 and 1.0; values outside that range will be clamped to the minimum or maximum value. The default value is 1.0.
    ///   - edgeBehavior: Determines how path edges are handled during a motion when the motion attempts to travel past the path's edges. This is rare, but can occur in some cases such as the ``EasingBack`` and ``EasingElastic`` easing equations. The default value is `stopAtEdges`.
    ///   - options: An optional options model.
    public convenience init(pathState: PathState, configuration: PhysicsConfiguration, startPosition: Double? = nil, endPosition: Double? = nil, edgeBehavior: PathEdgeBehavior? = nil, options: MotionOptions? = MotionOptions.none) {
        
        self.init(pathState: pathState, velocity: configuration.velocity, friction: configuration.friction, restitution: configuration.restitution, useCollisionDetection: configuration.useCollisionDetection, startPosition: startPosition, endPosition: endPosition, edgeBehavior: edgeBehavior, options: options)
    }
    
    /// The initializer.
    /// - Parameters:
    ///   - path: A state object containing information about the path to use as a motion guide.
    ///   - velocity: The velocity used to calculate new values in the `PhysicsSolving` system. Any values are accepted due to the differing ranges of velocity magnitude required for various motion applications. Experiment to see what suits your needs best.
    ///   - friction: The friction used to calculate new values in the `PhysicsSolving` system. Acceptable values are 0.0 (almost no friction) to 1.0 (no movement); values outside of this range will be clamped to the nearest edge.
    ///   - startPosition: An optional starting value, corresponding to a percentage along the path's length where the motion should begin. The range must be between 0.0 and 1.0; values outside that range will be clamped to the minimum or maximum value. The default value is 0.0.
    ///   - endPosition: An optional ending value, corresponding to a percentage along the path's length where the motion should end. The range must be between 0.0 and 1.0; values outside that range will be clamped to the minimum or maximum value. The default value is 1.0.
    ///   - edgeBehavior: Determines how path edges are handled during a motion when the motion attempts to travel past the path's edges. This is rare, but can occur in some cases such as the ``EasingBack`` and ``EasingElastic`` easing equations. The default value is `stopAtEdges`.
    ///   - options: An optional options model.
    public init(pathState: PathState, velocity: Double, friction: Double, restitution: Double? = nil, useCollisionDetection: Bool? = nil, startPosition: Double? = nil, endPosition: Double? = nil, edgeBehavior: PathEdgeBehavior? = nil, options: MotionOptions? = MotionOptions.none) {
        
        // clamp start and end values to a 0.0...1.0 range
        let start = max(min(startPosition ?? 0.0, 1.0), 0.0)
        let end = max(min(endPosition ?? 1.0, 1.0), 0.0)
        
        let state = PropertyData(path: "percentageComplete", start: start, end: end)
        
        let properties: [PropertyData] = [state]
        self.targetObject = pathState
        self.pathState = pathState
        
        if let edgeBehavior {
            self.pathState.edgeBehavior = edgeBehavior
        }
                
        
        // unpack options values
        if let options {
            repeating = options.contains(.repeats)
            reversing = options.contains(.reverses)
        }
        
        motionState = .stopped
        motionDirection = .forward
        
        // If no restitution is passed in, by default the object should stop at end of path without bouncing back if "stopAtEdges" edge behavior is chosen, so in that case we should turn on collision detection and set restitution to 0.0, which will prevent bounce back.
        var restitution = restitution
        if (restitution == nil && pathState.edgeBehavior == .stopAtEdges) {
            restitution = 0.0
        }
        let useCollision = useCollisionDetection ?? (pathState.edgeBehavior == .stopAtEdges)
        physicsSystem = PhysicsSystem(velocity: velocity, friction: friction, restitution: restitution, useCollisionDetection: useCollision)
        
        _tempo?.delegate = self
        
        self.friction = friction
        
        for var property in properties {
            setup(forProperty: &property)
            property.delegate = self
            if (resetObjectStateOnRepeat) {
                property.startingParentProperty = property.target
            }
            
            self.properties.append(property)
        }
        
    }

    
    // MARK: - Public methods
    
    /**
     *  Adds a delay before the motion operation will begin.
     *
     *  - parameter amount: The number of seconds to wait.
     *  - returns: A reference to this PathPhysicsMotion instance, for the purpose of chaining multiple calls to this method.
     */
    @discardableResult public func afterDelay(_ amount: TimeInterval) -> PathPhysicsMotion {
        
        delay = amount
        
        return self
        
    }
    
    
    /**
     *  Specifies that a motion cycle should repeat and the number of times it should do so. When no value is provided, the motion will repeat infinitely.
     *
     *  - remark: When this method is used there is no need to specify `repeats` in the `options` parameter of the init method.
     *
     *  - parameter numberOfCycles: The number of motion cycles to repeat. The default value is `REPEAT_INFINITE`.
     *  - returns: A reference to this PathPhysicsMotion instance, for the purpose of chaining multiple calls to this method.
     *  - seealso: repeating, repeatCycles
     */
    @discardableResult public func repeats(_ numberOfCycles: UInt = REPEAT_INFINITE) -> PathPhysicsMotion {
        
        repeatCycles = numberOfCycles
        repeating = true
        
        return self
    }
    
    
    /**
     *  Specifies that a motion, when it has moved to the ending value, should move from the ending value back to the starting value.
     *
     *  - remark: When this method is used there is no need to specify `reverse` in the `options` parameter of the init method.
     *
     *  - returns: A reference to this PathPhysicsMotion instance, for the purpose of chaining multiple calls to this method.
     *  - seealso: reversing, reverseEasing
     */
    @discardableResult public func reverses() -> PathPhysicsMotion {
        
        reversing = true
        
        return self
    }
    
    /// Sets up performance mode, generating an internal lookup table for faster position calculations. To use the performance mode, this method must be used before calling `start()`.
    ///
    /// > Note: With large paths, the lookup table generation could take a second or longer to complete. Be aware that the lookup table generation runs synchronously on another dispatch queue, blocking the return of this async call until the generation has completed. Be sure to call this method as early as possible to give the operation time to complete before your ``PathMotion`` needs to begin.
    /// - Parameter lookupCapacity: An optional capacity that caps the maximum lookup table amount.
    public func setupPerformanceMode() async {
        await pathState.setupPerformanceMode()
    }
    
    
    public func cleanupResources() {
        removePhysicsTimer()
        
        tempo?.delegate = nil
        tempo?.cleanupResources()
        
        for index in 0 ..< properties.count {
            properties[index].delegate = nil
        }
    }
    
    
    // MARK: - Private methods
    
    /**
     *  Initializes property metadata in preparation for a motion operation.
     *
     *  - parameter property: The `PropertyData` instance to modify.
     */
    private func setup(forProperty property: inout PropertyData) {
        
        guard let unwrapped_object = targetObject else { return }
        
        if (unwrapped_object is NSValue) {
            property.target = unwrapped_object
            property.parentKeyPath = property.path
            
            // modify start value if we should use the existing value instead
            assignStartingPropertyValue(&property)
            
            return
        }
        
        if (valueAssistant.acceptsKeypath(unwrapped_object)) {
            property.targetObject = unwrapped_object
        }
        
        // determine if target property is a value we can update directly, or if it's an element of a struct we need to replace
        property.parentKeyPath = property.path
        let keys: [String] = property.path.components(separatedBy: ".")
        let key_count = keys.count
        
        if (key_count > 1) {
            // there's more than one element in the path, meaning we have a parent, so let's find the prop type
            
            // descend keypath tree until we find a key in the path that isn't a struct or integer
            var parent_value: AnyObject?
            
            for (index, key) in keys.enumerated() {
                let parent_keys = keys[0 ... index]
                
                if (parent_keys.count > 0) {
                    let parent_path = parent_keys.joined(separator: ".")
                    
                    if let parent = unwrapped_object.value(forKeyPath: parent_path) as? NSObject {
                        parent_value = parent
                        var is_value_supported = false
                        
                        if (valueAssistant.updateValue(inObject: parent, newValues: [property.path : 1]) != nil) {
                            is_value_supported = true
                        }
                        
                        if (is_value_supported) {
                            // we found a path element that isn't numeric, so we'll need to save the path element below this one
                            
                            property.replaceParentProperty = true
                            property.parentKeyPath = parent_path
                            
                            property.getter = MotionSupport.propertyGetter(forName: key)
                            property.setter = MotionSupport.propertySetter(forName: key)
                            
                            break
                            
                        }
                        
                    }
                    
                }
            }
            
            if (property.replaceParentProperty) {
                if let value = parent_value {
                    property.target = value
                }
                
            } else if let lastProp = keys.last {
                property.getter = MotionSupport.propertyGetter(forName: lastProp)
                property.setter = MotionSupport.propertySetter(forName: lastProp)
            }
            
            // modify start value if we should use the existing value instead
            assignStartingPropertyValue(&property)
            
        } else if (key_count == 1) {
            // this is a top-level property, so let's see if this property is updatable
            var is_value_supported = false
            var propValue: Any?
            let keypath_accepted = valueAssistant.acceptsKeypath(unwrapped_object)
            if (keypath_accepted) {
                do {
                    propValue = try valueAssistant.retrieveValue(inObject: unwrapped_object, keyPath: property.path)

                } catch ValueAssistantError.typeRequirement(let valueType) {
                    ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)

                } catch {
                    // any other errors
                }
                
                if (propValue == nil) {
                    
                    // this should be wrapped in a do/catch, but Swift doesn't catch obj-c exceptions :(
                    propValue = valueAssistant.updateValue(inObject: unwrapped_object, newValues: [property.path : property.start])

                    if let retrieved = try? valueAssistant.retrieveValue(inObject: unwrapped_object, keyPath: property.path) {
                        propValue = retrieved
                    }
                }
                
                if let propValue = propValue as? NSObject, valueAssistant.supports(propValue) {
                    is_value_supported = true
                }
            }
            if (is_value_supported) {
                if let value = propValue {
                    property.target = value as AnyObject
                }
                
            } else if (unwrapped_object is NSNumber) {
                // target property's value could be nil if it's a NSNumber, so set it to the starting value
                let start_value = NSNumber.init(value: property.start)
                property.target = start_value
            } else {
                property.target = unwrapped_object
            }
            
            // modify start value if we should use the existing value instead
            assignStartingPropertyValue(&property)
            
        } else {
            // there is no path, so the top-level object should be the target
            property.target = unwrapped_object
        }
        
    }
    
    
    /**
     *  Assigns a start value for the property, useful when a motion is starting with the property's current value.
     *
     *  - parameter property: The `PropertyData` instance to modify.
     */
    private func assignStartingPropertyValue(_ property: inout PropertyData) {
        if (property.useExistingStartValue && completedCount == 0) {
            if let current_value = valueAssistant.retrieveCurrentObjectValue(forProperty: property) {
                property.start = current_value
            }
        }
    }
    
    
    /// Prepares the PhysicsMotion's state for movement and starts
    private func startMotion() {
        for index in 0 ..< properties.count {
            // modify start value if we should use the existing value instead
            assignStartingPropertyValue(&properties[index])
            properties[index].current = properties[index].start
        }
        
        motionState = .moving
        startTime = 0.0
        initialVelocity = physicsSystem.velocity
        
        setupPhysicsTimer()
        physicsTimerState = .suspended
        resumePhysicsTimer()
        
        // call start closure
        _started?(self, pathState.currentPoint)
        
        // send start status update
        sendStatusUpdate(.started)
        
    }
    
    
    
    /**
     *  Dispatches a status update to the `MotionUpdateDelegate` delegate assigned to the object, if there is one.
     *
     *  - parameter status: The `MoveableStatus` enum value to send to the delegate.
     */
    private func sendStatusUpdate(_ status: MoveableStatus) {
        
        updateDelegate?.motionStatusUpdated(forMotion: self, updateType: status)
    }
    
    
    
    
    // MARK: Physics methods
    
    private func setupPhysicsTimer() {
        if (physicsTimer != nil) {
            removePhysicsTimer()
        }
        physicsTimer = Timer.scheduledTimer(timeInterval: physicsTimerInterval, target: self, selector: #selector(handleTimerUpdated), userInfo: nil, repeats: true)
        
    }
    
    
    @objc private func handleTimerUpdated() {
        updatePhysicsSystem()
    }
    
    private func removePhysicsTimer() {
        if let timer = physicsTimer {
            timer.invalidate()
            physicsTimer = nil
        }
    }
    
    enum TimerRunningState {
        case suspended
        case resumed
    }
    private var physicsTimerState: TimerRunningState = .suspended
    
    private func suspendPhysicsTimer() {
        guard physicsTimer != nil else { return }
        
        if physicsTimerState == .suspended {
            return
        }
        physicsTimerState = .suspended
        removePhysicsTimer()
        
    }
    
    private func resumePhysicsTimer() {

        if physicsTimerState == .resumed {
            return
        }
        physicsTimerState = .resumed
        setupPhysicsTimer()
    }
    
    private func updatePhysicsSystem() {
        if (properties.count > 0) {

            // we're sending in a "fake" PropertyData here with values adjusted for the actual path length
            // we will transform those back to a 0 to 1 percentage after the system solves the current step
            let pathLengthStart = pathState.length*properties[0].start
            let pathLengthEnd = pathState.length*properties[0].end
            var adjustedProperty = PropertyData(path: "unused", start: pathLengthStart, end: pathLengthEnd)
            adjustedProperty.current = pathState.length*properties[0].current
            
            let newPositions = physicsSystem.solve(forPositions: [adjustedProperty], timestamp: CFAbsoluteTimeGetCurrent())

            if newPositions.count > 0 {
                let delta = abs(abs(newPositions[0]) - abs(properties[0].current))
                properties[0].delta = delta
                
                // the solver passed back values based on path length, so we need to get that back to a 0 to 1 percentage
                var percentageCurrent = newPositions[0] / pathState.length
                // adjust percentage to account for object crossing edges in contiguous mode
                if self.pathState.edgeBehavior == .contiguousEdges {
                    if (percentageCurrent > 1.0) {
                        percentageCurrent = min(percentageCurrent, 2.0) - 1.0
                    } else if (percentageCurrent < 0.0) {
                        percentageCurrent = abs(max(percentageCurrent, -2.0) + 1.0)
                    }
                }
                
                properties[0].current = percentageCurrent
            }
        }
        
    }
    
    
    
    // MARK: - Motion methods
    
    /**
     *  Updates the target property with a new delta value.
     *
     *  - parameter property: The property to update.
     */
    private func updatePropertyValue(forProperty property: inout PropertyData) {
        
        let newValue = property.current
        
        if (property.targetObject == nil) {
            
            if let new_prop = valueAssistant.calculateValue(forProperty: property, newValue: newValue) {
                property.target = new_prop
            }
            
            return
        }
        
        if let targetObject = property.targetObject {
            
            if let new_prop = valueAssistant.calculateValue(forProperty: property, newValue: newValue) {
                
                if (!property.replaceParentProperty) {
                    targetObject.setValue(new_prop, forKey: property.path)
                    
                } else {
                    targetObject.setValue(new_prop, forKeyPath: property.parentKeyPath)
                    
                }
            }
        }
        
        // in PathPhysicsMotion we just move a float value from 0 to 1, so we need to manually update the CGPoint to reflect the new value
        self.pathState.movePoint(to: newValue, startEdge: property.start, endEdge: property.end)
    }
    
    
    /// Called when the motion has completed.
    private func motionCompleted() {
        
        motionState = .stopped
        removePhysicsTimer()
        _motionProgress = 1.0
        _cycleProgress = 1.0
        completedCount += 1
        if (!repeating) { cyclesCompletedCount += 1 }

        for index in 0 ..< properties.count {
            updatePropertyValue(forProperty: &properties[index])
        }
        
        // call update closure
        _updated?(self, pathState.currentPoint)
        
        // call complete closure
        _completed?(self, pathState.currentPoint)
        
        // send completion status update
        sendStatusUpdate(.completed)
    }

    
    /// Starts the motion's next repeat cycle, if there is one.
    private func nextRepeatCycle() {
        cyclesCompletedCount += 1
        completedCount = 0
        
        if (repeatCycles == 0 || cyclesCompletedCount - 1 < repeatCycles) {
            
            // reset for next cycle
            properties[0].current = properties[0].start
            updatePropertyValue(forProperty: &properties[0])
            
            _cycleProgress = 0.0
            _motionProgress = 0.0
            
            if (resetObjectStateOnRepeat) {
                if let unwrapped_object = targetObject {
                    for index in 0 ..< properties.count {
                        let property = properties[index]
                        if let unwrapped_starting = property.startingParentProperty {
                            unwrapped_object.setValue(unwrapped_starting, forKey: property.parentKeyPath)
                        }
                    }
                }
            }
            
            // setting startTime to 0.0 causes update method to re-init the motion
            startTime = 0.0
            
            if (reversing) {
                reverseMotionDirection()
            } else {
                physicsSystem.reset()
            }
            
            // call cycle closure
            _cycleRepeated?(self, pathState.currentPoint)
            
            // send repeated status update
            sendStatusUpdate(.repeated)
            
            motionState = .moving
            
        } else {
            motionCompleted()
        }
        
    }
    
    
    /// Reverses the direction of the motion.
    private func reverseMotionDirection() {
        
        if (motionDirection == .forward) {
            motionDirection = .reverse
        } else if (motionDirection == .reverse) {
            motionDirection = .forward
        }
        
        // reset the times to get ready for the new reverse motion
        startTime = 0.0
        _motionProgress = 0.0
        
        // update state before calling reverse closure
        updatePropertyValue(forProperty: &properties[0])
        
        // tell the physics to reverse so we can calculate values the opposite direction
        physicsSystem.reverseDirection()
        physicsSystem.reset()
        
        // call reverse closure
        _reversed?(self, pathState.currentPoint)
        
        // send reverse notification
        // send out 50% complete notification, used by MotionSequence in contiguous mode
        sendStatusUpdate(.reversed)
        
        
        // send out 50% complete notification, used by MotionSequence in contiguous mode
        let half_complete = round(Double(repeatCycles) * 0.5)
        if (motionDirection == .reverse && (Double(cyclesCompletedCount) ≈≈ half_complete)) {
            sendStatusUpdate(.halfCompleted)
        }
        
    }
    
    
    
    // MARK: - Moveable protocol methods
    
    public func update(withTimeInterval currentTime: TimeInterval) {
        
        self.currentTime = currentTime
        
        if (motionState == .moving) {
            
            if (pauseTimestamp > 0.0 && startTime > 0.0) {
                // we just resumed from a pause, so adjust the times to account for paused length
                let pause_delta = currentTime - pauseTimestamp
                startTime += pause_delta
                endTime += pause_delta
                pauseTimestamp = 0.0 // reset pause timestamp
            }
            
            if (startTime == 0.0) {
                // a start time of 0 means we need to initialize the motion times
                startTime = currentTime
                pauseTimestamp = 0.0
                
                for index in 0 ..< properties.count {
                    updatePropertyValue(forProperty: &properties[index])
                }
            }
            
            if (abs(physicsSystem.velocity) > velocityDecayLimit) {
                
                for index in 0 ..< properties.count {
                    updatePropertyValue(forProperty: &properties[index])
                }
                
                // call update closure
                _updated?(self, pathState.currentPoint)
                
            } else {
                
                // motion has completed
                if (reversing || repeating) {
                    if ((repeating && !reversing) || (reversing && repeating && motionDirection == .reverse)) {
                        nextRepeatCycle()
                        
                    } else if (!repeating && reversing && motionDirection == .reverse) {
                        motionCompleted()
                        
                    } else if (reversing && motionState == .moving) {
                        reverseMotionDirection()
                    }
                    
                } else {
                    // not reversing or repeating
                    motionCompleted()
                }
            }
            
        } else if (motionState == .delayed) {
            
            self.currentTime = currentTime
            
            if (startTime == 0.0) {
                // a start time of 0 means we need to initialize the motion times
                startTime = currentTime
                endTime = startTime + delay
            }
            
            if (currentTime >= endTime) {
                // delay is done, time to move
                
                startMotion()
            }
            
        }
        
        
        
    }
    
    
    
    @discardableResult public func start() -> Self {
        if (motionState == .stopped) {
            reset()
            
            let no_delay_set: Bool = ((delay == 0.0) ? true : false)
            
            if (no_delay_set) {
                
               startMotion()
                
            } else {
                motionState = .delayed
            }

        }
        
        return self
    }
    
    
    
    public func stop() {
        
        if (motionState == .moving || motionState == .paused || motionState == .delayed) {
            motionState = .stopped
            removePhysicsTimer()
            
            startTime = 0.0
            currentTime = 0.0
            motionProgress = 0.0
            
            // call stop closure
            _stopped?(self, pathState.currentPoint)
            
            // send stopped status update
            sendStatusUpdate(.stopped)
            
        }
        
        cleanupResources()
    }
    
    
    public func pause() {
        
        if (motionState == .moving) {
            motionState = .paused
            
            // saves current time so we can determine length of pause time
            pauseTimestamp = currentTime
            
            // call pause closure
            _paused?(self, pathState.currentPoint)
            
            // send paused status update
            sendStatusUpdate(.paused)
            
            physicsSystem.pause()
            suspendPhysicsTimer()
            
        }
    }
    
    public func resume() {
        if (motionState == .paused) {
            motionState = .moving

            // call resume closure
            _resumed?(self, pathState.currentPoint)
            
            // send resumed status update
            sendStatusUpdate(.resumed)
            
            physicsSystem.resume()
            resumePhysicsTimer()
        }
    }
    
    
    /// Resets the motion to its initial state.
    public func reset() {
        motionState = .stopped
        motionDirection = .forward
        
        for index in 0 ..< properties.count {
            let property = properties[index]
            properties[index].current = property.start
            if (resetObjectStateOnRepeat) {
                if let unwrapped_object = targetObject {
                    if let unwrapped_starting = property.startingParentProperty {
                        unwrapped_object.setValue(unwrapped_starting, forKey: property.parentKeyPath)
                    }
                }
            }
        }
        
        physicsSystem.reset()
        
        cyclesCompletedCount = 0
        _cycleProgress = 0.0
        _motionProgress = 0.0
        
        // setting startTime to 0.0 causes motionUpdate method to re-init the motion
        startTime = 0.0
    }
    
    
    
    // MARK: - TempoDriven methods
    
    public func stopTempoUpdates() {
        
        tempo?.delegate = nil
        tempo?.cleanupResources()
        tempo = nil
        
    }
    
    
    // MARK: - TempoDelegate methods
    
    public func tempoBeatUpdate(_ timestamp: TimeInterval) {
        
        update(withTimeInterval: timestamp)
        
    }
    
    // MARK: - PropertyDataDelegate methods
    
    public func didUpdate(_ startValue: Double) {
        motionProgress = 0.0
        
        physicsSystem.reset()
        
        // setting startTime to 0 causes motionUpdate method to re-init the motion
        startTime = 0.0
    }
    
}