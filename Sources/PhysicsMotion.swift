//
//  PhysicsMotion.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  PhysicsMotion handles a single motion operation on one or more properties, using a physics system to update values with decaying velocity.
 */
@MainActor public class PhysicsMotion<TargetType: AnyObject>: Moveable, Additive, TempoDriven, PropertyDataDelegate {

    /// A closure used to provide status updates for a ``PhysicsMotion`` object.
    /// - Parameter motion: The ``PhysicsMotion`` object which published this update closure.
    public typealias PhysicsMotionUpdateClosure = (_ motion: PhysicsMotion) -> Void
    
    /// This notification closure should be called when the ``start()`` method starts a motion operation. If a delay has been specified, this closure is called after the delay is complete.
    public typealias PhysicsMotionStarted = PhysicsMotionUpdateClosure

    /// This notification closure should be called when the ``stop()`` method starts a motion operation.
    public typealias PhysicsMotionStopped = PhysicsMotionUpdateClosure

    /// This notification closure should be called when the ``update(withTimeInterval:)`` method is called while a ``Moveable`` object is currently moving.
    public typealias PhysicsMotionUpdated = PhysicsMotionUpdateClosure

    /// This notification closure should be called when a motion operation reverses its movement direction.
    public typealias PhysicsMotionReversed = PhysicsMotionUpdateClosure

    /// This notification closure should be called when a motion has started a new motion cycle.
    public typealias PhysicsMotionRepeated = PhysicsMotionUpdateClosure

    /// This notification closure should be called when calling the ``pause()`` method pauses a motion operation.
    public typealias PhysicsMotionPaused = PhysicsMotionUpdateClosure

    /// This notification closure should be called when calling the ``resume()`` method resumes a motion operation.
    public typealias PhysicsMotionResumed = PhysicsMotionUpdateClosure

    /// This notification closure should be called when a motion operation has fully completed.
    ///
    /// > Note: This closure should only be executed when all activity related to the motion has ceased. For instance, if a ``Moveable`` class allows a motion to be repeated multiple times, this closure should be called when all repetitions have finished.
    public typealias PhysicsMotionCompleted = PhysicsMotionUpdateClosure


    // Default limit for a velocity's decay.
    let DEFAULT_DECAY_LIMIT: Double = 0.95
    
    
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
     *  An object conforming to the ``ValueAssistant`` protocol which acts as an interface for retrieving and updating value types.
     *
     *  - remark: By default, Motion will assign an instance of the ``ValueAssistantGroup`` class with value assistants supported on the system platform it is running on. You may add your own custom type assistants to this group, or replace it with your own custom ``ValueAssistant`` implementation.
     */
    public var valueAssistant: any ValueAssistant<TargetType> = ValueAssistantGroup(assistants: []) {
        didSet {
            valueAssistant.isAdditive = _isAdditive
            valueAssistant.additiveWeighting = additiveWeighting
        }
    }
    
    // MARK: - Identifiable conformance
    
    /// A unique identifier.
    public let id = UUID()
    
    
    // MARK: Additive protocol conformance
    
    /**
     *  A Boolean which determines whether this Motion should change its object values additively. Additive animation allows multiple motions to produce a compound effect, creating smooth transitions and blends between different ending value targets. Additive animation is the default behavior for UIKit animations as of iOS 8 and is great for making user interface animations fluid and responsive. MotionMachine uses its own implementation of additive movement, so you can use additive motions on any supported object properties.
     *
     *   By default, each PhysicsMotion will apply a strong influence on the movement of a property towards its ending value. This means that two Motion objects with the same duration and moving the same object property to different ending values will fight, and the "winning" value will be the last Motion to start its movement. If the durations or starting times are different, a transition between the values will occur. If you wish to create additive motions that apply weighted value updates, you can adjust the ``additiveWeighting`` property. Setting values to that property that are less than 1.0 will create compound additive motions that are blends of each Motion object's ending values.
     *
     *  - remark: The `start` value of ``PropertyData`` objects are ignored for additive animations, and will instead combine with the current value of the properties being moved.
     *
     *  - warning: Please be aware that because of the composite nature of additive movements, values can temporarily move past a ``PropertyData``'s specified `end` value. This can have unintended consequences if the property value you are moving is clamped to a limited range. Also note that additive movements may not work well with compound motions that are comprised of sequences, reversing, or repeating, and will not behave correctly when other Motion objects moving the same properties are not using the additive mode. Because of these caveats, the default value is `false`.
     *
     *  - seealso: additiveWeighting
     *
     */
    public private(set) var isAdditive: Bool {
        get {
            return _isAdditive
        }
        
        set(newValue) {
            _isAdditive = newValue
            valueAssistant.isAdditive = isAdditive
        }
        
    }
    private var _isAdditive: Bool = false
    
    /**
     *  A weighting between 0.0 and 1.0 which is applied to this PhysicsMotion's object value updates when it is using an additive movement. The higher the weighting amount, the more its additive updates apply to the properties being moved. A value of 1.0 will mean the motion will reach the specific `end` value of each ``PropertyData`` being moved, while a value of 0.0 will not move towards the `end` value at all. When multiple Motions in `additive` mode are moving the same object properties, adjusting this weighting on each Motion can create complex composite motions.
     *
     *  - note: This value only has an effect when ``isAdditive`` is set to `true`. The default value is 1.0.
     *  - seealso: additive
     */
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
            valueAssistant.additiveWeighting = additiveWeighting
        }
    }
    
    /**
     *  An operation ID is assigned to a PhysicsMotion instance when it is moving an object's property (via initWithObject...) and its motion operation is currently in progress. (read-only)
     *
     *  - remark: This value returns 0 if no ID is currently assigned.
     */
    private(set) public var operationID: UInt = 0
    

    
    // MARK: Physics properties
    
    /**
     *  An object conforming to the ``PhysicsSolving`` protocol which solves position calculation updates.
     *
     *  - remark: By default, PhysicsMotion will assign an instance of ``PhysicsSystem`` to this property, but you can override this with your own custom physics system.
     */
    public var physicsSystem: PhysicsSolving
    
    /**
     *  The current velocity used by the physics system to calculate motion values, measured in units per second.
     *
     *  - remark: If you wish to change the velocity after initially setting it via one of the init methods, use this setter. If you change the velocity directly on the ``physicsSystem`` object, the ``motionProgress`` property won't be accurate.
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
     *  - remark: The way in which ``PhysicsSystem`` applies friction means that as velocity approaches 0.0, it will be assigned smaller and smaller fractional numbers, so we need a reasonable cutoff that approximates the velocity coming to rest. The default value is the constant `DEFAULT_DECAY_LIMIT` (set to 0.95), which is fine for display properties, but you may prefer other values.
     */
    public var velocityDecayLimit: Double
    
    
    /**
     *  Specifies a time step for the physics solver, which is updated independently of motion value updates. The default value calls the physics system 120 times a second, which provides double the precision if your app is rendering at 60 fps.
     */
    public var physicsTimerInterval: TimeInterval = 1.0 / 120.0; // call the physics system at 120 fps
    
    
    // MARK: Property collection methods
    
    /// A collection of ``PropertyData`` instances, representing the object's properties being moved.
    private(set) public var properties: [PropertyData<TargetType>] = []
    
    
    
    // MARK: Motion state properties
    
    /// The target object whose property should be moved.
    private(set) public var targetObject: TargetType?
    
    /// An enum which represents the current movement state of the motion operation. (read-only)
    private(set) public var motionState: MoveableState
    
    /// A ``MotionDirection`` enum which represents the current direction of the motion operation. (read-only)
    private(set) public var motionDirection: MotionDirection
    
    /**
     *  A value between 0.0 and 1.0, which represents the current progress of a movement between two value destinations. (read-only)
     *
     *  - remark: Be aware that if this motion is ``isReversing`` or ``isRepeating``, this value will only represent one movement. For instance, if a Motion has been set to repeat once, this value will move from 0.0 to 1.0, then reset to 0.0 again as the new repeat cycle starts. Similarly, if a Motion is set to reverse, this progress will represent each movement; first in the forward direction, then again when reversing back to the starting values.
     */
    private(set) public var motionProgress: Double {
        
        get {
            return _motionProgress
        }
        
        set(newValue) {
            _motionProgress = newValue
            
            // sync cycleProgress with motionProgress so that cycleProgress always represents total cycle progress
            if (isReversing && motionDirection == .forward) {
                _cycleProgress = _motionProgress * 0.5
            } else if (isReversing && motionDirection == .reverse) {
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
     *  - remark: A cycle represents the total length of a one motion operation. If ``isReversing`` is set to `true`, a cycle comprises two separate movements (the forward movement, which at completion will have a value of 0.5, and the movement in reverse which at completion will have a value of 1.0); otherwise a cycle is the length of one movement. Note that if ``isRepeating`` is `true`, each repetition will be a new cycle and thus the progress will reset to 0.0 for each repeat.
     */
    private(set) public var cycleProgress: Double {
        get {
            return _cycleProgress
        }
        
        set(newValue) {
            _cycleProgress = newValue
            
            // sync motionProgress with cycleProgress, so we modify the ivar directly (otherwise we'd enter a recursive loop as each setter is called)
            if (isReversing) {
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
     * - remark: A cycle represents the total length of a one motion operation. If ``isReversing`` is set to `true`, a cycle comprises two separate movements (the forward movement and the movement in reverse); otherwise a cycle is the length of one movement. Note that if ``isRepeating`` is `true`, each repetition will be a new cycle.
     */
    private(set) public var cyclesCompletedCount: UInt = 0
    
    
    /**
     *  A value between 0.0 and 1.0, which represents the current overall progress of the motion. This value should include all reversing and repeat motion cycles. (read-only)
     *
     *  - remark: If a motion is not repeating, this value will be equivalent to the value of ``cycleProgress``.
     *
     */
    public var totalProgress: Double {
        get {
            // sync totalProgress with cycleProgress
            if (isRepeating && repeatCycles > 0 && cyclesCompletedCount < (repeatCycles+1)) {
                return (_cycleProgress + Double(cyclesCompletedCount)) / Double(repeatCycles+1)
            } else {
                return _cycleProgress
            }
        }
        
    }
    
    
    
    // MARK: Moveable protocol properties
    
    /// A Boolean which determines whether a motion operation, when it has moved to the ending value, should move from the ending value back to the starting value.
    public var isReversing: Bool = false
    
    
    /**
     *  A Boolean which determines whether a motion operation should repeat. When set to `true`, the motion operation repeats for the number of times specified by the ``repeatCycles`` property. The default value is `false`.
     *
     *  - note: By design, setting this value to `true` without changing the ``repeatCycles`` property from its default value will cause the motion to repeat infinitely.
     */
    public var isRepeating: Bool = false
    
    
    /**
     *  The number of motion cycle operations to repeat.
     *
     *  - remark: This property is only used when ``isRepeating`` is set to `true`. Assigning `REPEAT_INFINITE` to this property signals an infinite amount of motion cycle repetitions. The default value is `REPEAT_INFINITE`.
     *
     */
    public var repeatCycles: UInt = REPEAT_INFINITE
    
    
    /// Provides a delegate for updates to a Moveable object's status, used by ``Moveable`` collections.
    public var updateDelegate: MotionUpdateDelegate?
    
    
    
    // MARK: TempoDriven protocol properties
    
    /**
     *  An object conforming to the ``TempoProviding`` protocol that provides an update "beat" while a motion operation occurs.
     *
     *  - Note: By default, Motion will assign an instance of ``DisplayLinkTempo`` to this property, which automatically chooses the best tempo class for the system platform. For iOS, visionOS, and tvOS the class chosen is ``CATempo``, but for macOS it is ``MacDisplayLinkTempo``. Both classes internally use a `CADisplayLink` object for updates.
     */
    public var tempo: TempoProviding? {
        
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
    lazy private var _tempo: TempoProviding? = {
        return DisplayLinkTempo()
    }()
    
    
    
    // MARK: - Notification closures
    
    /**
     *  This closure is called when a motion operation starts.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: start
     */
    @discardableResult public func started(_ closure: @escaping PhysicsMotionStarted) -> Self {
        _started = closure
        
        return self
    }
    private var _started: PhysicsMotionStarted?
    
    /**
     *  This closure is called when a motion operation is stopped by calling the ``stop()`` method.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: stop
     */
    @discardableResult public func stopped(_ closure: @escaping PhysicsMotionStopped) -> Self {
        _stopped = closure
        
        return self
    }
    private var _stopped: PhysicsMotionStopped?
    
    /**
     *  This closure is called when a motion operation update occurs and this instance's ``motionState`` is `moving`.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: update(withTimeInterval:)
     */
    @discardableResult public func updated(_ closure: @escaping PhysicsMotionUpdated) -> Self {
        _updated = closure
        
        return self
    }
    private var _updated: PhysicsMotionUpdated?
    
    /**
     *  This closure is called when a motion cycle has completed.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: repeating, cyclesCompletedCount
     */
    @discardableResult public func cycleRepeated(_ closure: @escaping PhysicsMotionRepeated) -> Self {
        _cycleRepeated = closure
        
        return self
    }
    private var _cycleRepeated: PhysicsMotionRepeated?
    
    /**
     *  This closure is called when the ``motionDirection`` property changes to `reversing`.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: motionDirection, reversing
     */
    @discardableResult public func reversed(_ closure: @escaping PhysicsMotionReversed) -> Self {
        _reversed = closure
        
        return self
    }
    private var _reversed: PhysicsMotionReversed?
    
    /**
     *  This closure is called when calling the ``pause()`` method on this instance causes a motion operation to pause.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: pause
     */
    @discardableResult public func paused(_ closure: @escaping PhysicsMotionPaused) -> Self {
        _paused = closure
        
        return self
    }
    private var _paused: PhysicsMotionPaused?
    
    /**
     *  This closure is called when calling the ``resume()`` method on this instance causes a motion operation to resume.
     *
     *  - remark: This method can be chained when initializing the object.
     *
     *  - seealso: resume
     */
    @discardableResult public func resumed(_ closure: @escaping PhysicsMotionResumed) -> Self {
        _resumed = closure
        
        return self
    }
    private var _resumed: PhysicsMotionResumed?
    
    /**
     *  This closure is called when a motion operation has completed (or when all motion cycles have completed, if ``repeating`` is set to `true`).
     *
     *  - remark: This method can be chained when initializing the object.
     */
    @discardableResult public func completed(_ closure: @escaping PhysicsMotionCompleted) -> Self {
        _completed = closure
        
        return self
    }
    private var _completed: PhysicsMotionCompleted?
    
    
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
    
    /// A `DispatchSourceTimer` which calls the physics update calculation at fixed rate, separate from display rate
    private var physicsTimer: DispatchSourceTimer?
    

    // The last initial velocity set.
    private var initialVelocity: Double = 0.0
    
    
    // MARK: - Initialization
    
    /**
     *  Initializer method.
     *
     *  - parameters:
     *      - target: The target object whose properties should be modified.
     *      - properties: An array of ``PropertyData`` objects that provide instructions for which properties to modify and how.
     *      - velocity: The velocity used to calculate new values in the ``PhysicsSolving`` system. Any values are accepted due to the differing ranges of velocity magnitude required for various motion applications. Experiment to see what suits your needs best.
     *      - friction: The friction used to calculate new values in the ``PhysicsSolving`` system. Acceptable values are 0.0 (no friction) to 1.0 (no movement); values outside of this range will be clamped to the nearest edge.
     *      - options: An optional set of ``MotionsOptions``.
     */
    public convenience init(target targetObject: TargetType, properties: [PropertyData<TargetType>], velocity: Double, friction: Double, options: MotionOptions? = MotionOptions.none) {
        
        self.init(targetObject: targetObject, properties: properties, velocity: velocity, friction: friction, options: options)
        
    }
    
    /**
     *  Initializer.
     *
     *  - parameters:
     *      - target: The target object whose properties should be modified.
     *      - velocity: The velocity used to calculate new values in the ``PhysicsSolving`` system. Any values are accepted due to the differing ranges of velocity magnitude required for various motion applications. Experiment to see what suits your needs best.
     *      - friction: The friction used to calculate new values in the ``PhysicsSolving`` system. Acceptable values are 0.0 (no friction) to 1.0 (no movement); values outside of this range will be clamped to the nearest edge.
     *      - options: An optional set of ``MotionsOptions``.
     */
    public convenience init(target targetObject: TargetType, velocity: Double, friction: Double, options: MotionOptions? = MotionOptions.none) {
        
        self.init(targetObject: targetObject, properties: [], velocity: velocity, friction: friction, options: options)
    }
    
    /// A convenience initializer.
    /// - Parameters:
    ///   - target: The target object whose properties should be modified.
    ///   - properties: An array of ``PropertyData`` objects that provide instructions for which properties to modify and how.
    ///   - configuration: A configuration model containing data to set up this object's ``PhysicsSystem`` for physics calculations.
    ///   - options: An optional options model.
    public convenience init(target targetObject: TargetType, properties: [PropertyData<TargetType>], configuration: PhysicsConfiguration, options: MotionOptions? = MotionOptions.none) {
        
        self.init(targetObject: targetObject, properties: properties, velocity: configuration.velocity, friction: configuration.friction, restitution: configuration.restitution, useCollisionDetection: configuration.useCollisionDetection,  options: options)
    }
    
    private init(targetObject: TargetType, properties props: [PropertyData<TargetType>]?, velocity: Double, friction: Double, restitution: Double? = nil, useCollisionDetection: Bool? = nil, options: MotionOptions? = MotionOptions.none) {
        
        let properties = props ?? []
        
        self.targetObject = targetObject
        
        if let assistantGroup = valueAssistant as? ValueAssistantGroup<TargetType> {
            assistantGroup.add(NumericAssistant())
            assistantGroup.add(SIMDAssistant())
            
#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
            assistantGroup.add(CGStructAssistant())
            assistantGroup.add(CGColorAssistant())
            assistantGroup.add(CIColorAssistant())
#endif
            
#if os(iOS) || os(tvOS) || os(visionOS)
            assistantGroup.add(UIColorAssistant())
            assistantGroup.add(UIKitStructAssistant())
#endif
        }
        
        motionState = .stopped
        motionDirection = .forward
        
        physicsSystem = PhysicsSystem(velocity: velocity, friction: friction, restitution: restitution, useCollisionDetection: useCollisionDetection)
        
        self.friction = friction
        
        self.velocityDecayLimit = DEFAULT_DECAY_LIMIT
        
        // unpack options values
        if let options {
            isRepeating = options.contains(.repeats)
            isReversing = options.contains(.reverses)
            resetObjectStateOnRepeat = options.contains(.resetsStateOnRepeat)
            isAdditive = options.contains(.additive)
        }
        
        setupProperties(properties: properties)
        
        _tempo?.delegate = self

    }
    
    
    // MARK: - Public methods
    
    /**
     *  Adds a `PropertyData` to control an object's property. The PropertyData's `path` must reflect a property keyPath of the Motion's target object.
     *
     *  - parameter property: A `PropertyData` instance.
     *  - remark: This method can be chained when initializing the object.
     *  - warning: This method should not be called after the Motion has started.
     *  - returns: A reference to this Motion instance, for the purpose of chaining multiple calls to this method.
     */
    @discardableResult public func add(_ property: PropertyData<TargetType>) -> PhysicsMotion {
        
        if let targetObject {
            setupProperty(property: property, for: targetObject)
        }
        property.delegate = self
        if (resetObjectStateOnRepeat) {
            property.startingParentProperty = property.target
        }
        properties.append(property)
        
        return self
    }
    
    
    /**
     *  Adds a delay before the motion operation will begin.
     *
     *  - parameter amount: The number of seconds to wait.
     *  - returns: A reference to this PhysicsMotion instance, for the purpose of chaining multiple calls to this method.
     */
    @discardableResult public func afterDelay(_ amount: TimeInterval) -> PhysicsMotion {
        
        delay = amount
        
        return self
        
    }
    
    
    /**
     *  Specifies that a motion cycle should repeat and the number of times it should do so. When no value is provided, the motion will repeat infinitely.
     *
     *  - remark: When this method is used there is no need to specify `repeats` in the `options` parameter of the init method.
     *
     *  - parameter numberOfCycles: The number of motion cycles to repeat. The default value is `REPEAT_INFINITE`.
     *  - returns: A reference to this PhysicsMotion instance, for the purpose of chaining multiple calls to this method.
     *  - seealso: repeating, repeatCycles
     */
    @discardableResult public func repeats(_ numberOfCycles: UInt = REPEAT_INFINITE) -> PhysicsMotion {
        
        repeatCycles = numberOfCycles
        isRepeating = true
        
        return self
    }
    
    
    /**
     *  Specifies that a motion, when it has moved to the ending value, should move from the ending value back to the starting value.
     *
     *  - remark: When this method is used there is no need to specify `reverse` in the `options` parameter of the init method.
     *
     *  - returns: A reference to this PhysicsMotion instance, for the purpose of chaining multiple calls to this method.
     *  - seealso: reversing, reverseEasing
     */
    @discardableResult public func reverses() -> PhysicsMotion {
        
        isReversing = true
        
        return self
    }
    
    
    public func cleanupResources() {
        removePhysicsTimer()
    }
    
    
    // MARK: - Private methods
    
    func setupProperties(properties: [PropertyData<TargetType>]) {
        guard let targetObject else { return }
        
        for property in properties {
            setupProperty(property: property, for: targetObject)
            
            property.delegate = self
            if (resetObjectStateOnRepeat) {
                property.startingParentProperty = property.target
            }

            self.properties.append(property)
        }
    }
    
    /**
     *  Assigns a start value for the property, useful when a motion is starting with the property's current value.
     *
     *  - parameter property: The `PropertyData` instance to modify.
     */
    private func assignStartingPropertyValue(_ property: PropertyData<TargetType>) {
        if (property.useExistingStartValue && completedCount == 0) {
            
            if let targetObject = property.targetObject {
                
                if let startValue = property.retrieveValue(from: targetObject) as? any BinaryFloatingPoint, let convertedValue = startValue.toDouble() {
                    property.start = convertedValue
                    
                } else if let startValue = property.retrieveValue(from: targetObject) as? any BinaryInteger, let convertedValue = startValue.toDouble() {
                    property.start = convertedValue
                }
                
                let shouldChangeEndValue = (property.start == property.end && physicsSystem.useCollisionDetection)
                // We need to keep start and end values equal if physics collisions are active. By default a PropertyData end value is 0.0, so if the start value changes and an end value wasn't provided, turning on collisions would create a collision value at 0.0 that the user might not expect.
                // The physics system ignores collisions if start and end collision points are equal, so this circumvents unwanted behavior.
                if shouldChangeEndValue {
                    property.end = property.start
                }
            }

        }
    }
    
    
    /// Prepares the PhysicsMotion's state for movement and starts
    private func startMotion() {
        for index in 0 ..< properties.count {
            // modify start value if we should use the existing value instead
            if (!isAdditive) { assignStartingPropertyValue(properties[index]) }
            properties[index].current = properties[index].start
        }
        
        motionState = .moving
        startTime = 0.0
        initialVelocity = physicsSystem.velocity
        
        if (isAdditive && targetObject != nil) {
            operationID = MotionSupport.register(additiveMotion: self)
        }
        
        setupPhysicsTimer()
        physicsTimerState = .suspended
        resumePhysicsTimer()
        
        // call start closure
        _started?(self)
        
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
        
        physicsTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        physicsTimer?.schedule(deadline: .now(), repeating: physicsTimerInterval, leeway: .milliseconds(2))
        physicsTimer?.setEventHandler { [weak self] in
            self?.updatePhysicsSystem()
        }
        physicsTimer?.resume()
    }

    
    private func removePhysicsTimer() {
        if let timer = physicsTimer {
            timer.cancel()
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
            let new_positions = physicsSystem.solve(forPositions: properties, timestamp: Date().timeIntervalSince1970)

            for index in 0 ..< new_positions.count {
                properties[index].delta = new_positions[index] - properties[index].current
                properties[index].current = new_positions[index]
            }

        }
        
    }
    
    
    
    // MARK: - Motion methods
    
    /**
     *  Updates the target property with a new delta value.
     *
     *  - parameter property: The property to update.
     */
    private func updatePropertyValue(forProperty property: PropertyData<TargetType>) {
        
        let newValue = (isAdditive) ? property.delta : property.current
        
        valueAssistant.update(property: property, newValue: newValue)

    }
    
    
    /// Called when the motion has completed.
    private func motionCompleted() {
        
        motionState = .stopped
        removePhysicsTimer()
        _motionProgress = 1.0
        _cycleProgress = 1.0
        completedCount += 1
        if (!isRepeating) { cyclesCompletedCount += 1 }

        for index in 0 ..< properties.count {
            updatePropertyValue(forProperty: properties[index])
        }
        
        if (isAdditive && targetObject != nil) {
            operationID = 0
            MotionSupport.unregister(additiveMotion: self)
        }
        
        // call update closure
        _updated?(self)
        
        // call complete closure
        _completed?(self)
        
        // send completion status update
        sendStatusUpdate(.completed)
    }

    
    /// Starts the motion's next repeat cycle, if there is one.
    private func nextRepeatCycle() {
        cyclesCompletedCount += 1
        completedCount = 0
        
        if (repeatCycles == 0 || cyclesCompletedCount - 1 < repeatCycles) {
            
            // reset for next cycle
            for index in 0 ..< properties.count {
                properties[index].current = properties[index].start
            }
            _cycleProgress = 0.0
            _motionProgress = 0.0
            
            if (resetObjectStateOnRepeat) {
                if let targetObject {
                    for index in 0 ..< properties.count {
                        let property = properties[index]

                        if let startingParentProperty = property.startingParentProperty, property.replaceParentProperty {
                            property.applyToParent(value: startingParentProperty, to: targetObject)
                        } else {
                            property.apply(value: property.start, to: targetObject)
                        }
                    }
                }
            }
            
            // setting startTime to 0.0 causes update method to re-init the motion
            startTime = 0.0
            
            if (isReversing) {
                reverseMotionDirection()
            } else {
                physicsSystem.reset()
            }
            
            // call cycle closure
            _cycleRepeated?(self)
            
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
        
        // tell the physics to reverse so we can calculate values the opposite direction
        physicsSystem.reverseDirection()
        physicsSystem.reset()
        
        // call reverse closure
        _reversed?(self)
        
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
                
                // temporarily turn off additive mode for the first update so the starting position can be set
                let temp_additive = isAdditive
                isAdditive = false
                _isAdditive = temp_additive
                for index in 0 ..< properties.count {
                    if (!_isAdditive) { updatePropertyValue(forProperty: properties[index]) }
                }
                valueAssistant.isAdditive = _isAdditive
            }
            
            if (abs(physicsSystem.velocity) > velocityDecayLimit) {
                
                for index in 0 ..< properties.count {
                    updatePropertyValue(forProperty: properties[index])
                }
                
                // call update closure
                _updated?(self)
                
            } else {
                
                // motion has completed
                if (isReversing || isRepeating) {
                    if ((isRepeating && !isReversing) || (isReversing && isRepeating && motionDirection == .reverse)) {
                        nextRepeatCycle()
                        
                    } else if (!isRepeating && isReversing && motionDirection == .reverse) {
                        motionCompleted()
                        
                    } else if (isReversing && motionState == .moving) {
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
            
            if (isAdditive) {
                if let unwrapped_object = targetObject {
                    for index in 0 ..< properties.count {
                        // assign the ending value of the last motion for this obj/keyPath to each property's starting value
                        let property = properties[index]
                        
                        if let lastTargetValue = MotionSupport.targetValue(forObject: unwrapped_object, targetProperty: property, requestingID: self.operationID) {
                            properties[index].start = lastTargetValue
                        }
                    }
                    
                    if (no_delay_set) {
                        operationID = MotionSupport.register(additiveMotion: self as any Additive)
                    }
                }
            }
            
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
            
            if (isAdditive && targetObject != nil) {
                operationID = 0
                MotionSupport.unregister(additiveMotion: self)
            }
            
            // call stop closure
            _stopped?(self)
            
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
            _paused?(self)
            
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
            _resumed?(self)
            
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
                if let targetObject {
                    if let startingParentProperty = property.startingParentProperty {
                        property.applyToParent(value: startingParentProperty, to: targetObject)
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

extension PhysicsMotion: Equatable {
    nonisolated public static func == (lhs: PhysicsMotion<TargetType>, rhs: PhysicsMotion<TargetType>) -> Bool {
        return (lhs.id == rhs.id)
    }
}
