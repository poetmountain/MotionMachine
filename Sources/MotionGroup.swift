//
//  MotionGroup.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/6/16.
//  Copyright © 2016-2018 Poet & Mountain, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public typealias GroupUpdateClosure = (_ group: MotionGroup) -> Void

/**
 *  This notification closure should be called when the `start` method starts a motion operation. If a delay has been specified, this closure is called after the delay is complete.
 *
 *  - seealso: start
 */
public typealias GroupStarted = GroupUpdateClosure

/**
 *  This notification closure should be called when the `stop` method starts a motion operation.
 *
 *  - seealso: stop
 */
public typealias GroupStopped = GroupUpdateClosure


/**
 *  This notification closure should be called when the `update` method is called while a Moveable object is currently moving.
 *
 *  - seealso: update
 */
public typealias GroupUpdated = GroupUpdateClosure


/**
 *  This notification closure should be called when a motion operation reverses its movement direction.
 *
 */
public typealias GroupReversed = GroupUpdateClosure

/**
 *  This notification closure should be called when a motion has started a new repeat cycle.
 *
 */
public typealias GroupRepeated = GroupUpdateClosure

/**
 *  This notification closure should be called when calling the `pause` method pauses a motion operation.
 *
 */
public typealias GroupPaused = GroupUpdateClosure

/**
 *  This notification closure should be called when calling the `resume` method resumes a motion operation.
 *
 */
public typealias GroupResumed = GroupUpdateClosure

/**
 *  This notification closure should be called when a motion operation has fully completed.
 *
 *  - remark: This closure should only be executed when all activity related to the motion has ceased. For instance, if a Moveable class allows a motion to be repeated multiple times, this closure should be called when all repetitions have finished.
 *
 */
public typealias GroupCompleted = GroupUpdateClosure


/**
 *  MotionGroup handles the movement of one or more objects which conform to the `Moveable` protocol, either being instances of `Motion` or other custom classes. The MotionGroup class is a good solution when you want to easily synchronize the movements of many `Moveable` objects.
 */
public class MotionGroup: Moveable, MoveableCollection, TempoDriven, MotionUpdateDelegate {
    
    // MARK: - Public Properties
    
    ///-------------------------------------
    /// Setting Up a MotionGroup
    ///-------------------------------------
    
    /**
     *  The delay, in seconds, before the group's motion operation begins.
     *
     *  - warning: Setting this parameter after a motion operation has begun has no effect.
     */
    public var delay: TimeInterval = 0.0
    
    /**
     *  A Boolean which determines whether the group's motion operation should repeat. When set to `true`, the motion operation repeats for the number of times specified by the `repeatCycles` property. The default value is `false`.
     *
     *  - note: By design, setting this value to `true` without changing the `repeatCycles` property from its default value (0) will cause the motion to repeat infinitely.
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
     *  A Boolean which determines whether the MotionGroup should synchronize when its `Moveable` objects reverse direction during each movement cycle.  This means that the MotionGroup's fastest child motion will wait for the other children to finish their movements before reversing direction.
     *
     *  When set to `true`, the MotionGroup will not tell its `Moveable` objects to reverse direction until all of them have completed their current movement cycle. This will occur both when the child motions have finished their foward movement, and when they've finished their movement in the opposite direction. When this property is set to `false`, the MotionGroup's objects will move independently of each other.
     *
     *  - note: This property only has an effect when `reversing` is set to `true`, in which case the MotionGroup will call the `GroupReversed` notification closure when all of its `Moveable` objects are ready to reverse.
     * 
     *   The default value is `false`.
     *
     *  - seealso: reversing
     */
    public var syncMotionsWhenReversing: Bool = false
    
    
    
    // MOTION STATE
    
    /// An array comprising the Moveable objects controlled by this MotionGroup object. (read-only)
    private(set) public var motions: [Moveable] = []
    
    /// A `MotionState` enum which represents the current movement state of the motion operation. (read-only)
    private(set) public var motionState: MotionState
    
    /// A `MotionDirection` enum which represents the current direction of the motion operation. (read-only)
    private(set) public var motionDirection: MotionDirection
    
    /**
     *  A value between 0.0 and 1.0, which represents the current progress of a movement between two value destinations. (read-only)
     *
     *  - remark: Be aware that if this motion is `reversing` or `repeating`, this value will only represent one movement. For instance, if a MotionGroup has been set to repeat once, this value will move from 0.0 to 1.0, then reset to 0.0 again as the new repeat cycle starts. Similarly, if a MotionGroup is reversing, this property's value will represent each movement; first in the forward direction, then again when reversing back to the starting values.
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
     *  A value between 0.0 and 1.0, which represents the current overall progress of the group. This value should include all reversing and repeat motion cycles. (read-only)
     *
     *  - remark: If a group is not repeating, this value will be equivalent to the value of `cycleProgress`.
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
    
    /// A Boolean which determines whether the MotionGroup's child motions should reverse their movements back to their starting values after completing their forward movements.
    public var reversing: Bool {
        get {
            return _reversing
        }
        
        set(newValue) {
            _reversing = newValue
            
            // change the `reversing` property on each `Moveable` object in the group to reflect the group's new state
            for motion in motions {
                motion.reversing = _reversing
            }
            
            motionsCompletedCount = 0
        }
        
    }
    private var _reversing: Bool = false
    
    
    /// Provides a delegate for updates to a Moveable object's status, used by Moveable collections.
    public weak var updateDelegate: MotionUpdateDelegate?
    
    
    // MARK: MoveableCollection protocol properties
    
    /**
     *  A `CollectionReversingMode` enum which defines the behavior of a `Moveable` class when its `reversing` property is set to `true`. In the standard MotionMachine classes only `MotionSequence` currently uses this property to alter its behavior. This property should not be set directly on a `MotionGroup` object.
     *
     *  - note: While including this property in custom classes which implement the `MoveableCollection` protocol is required, implementation of behavior based on the property's value is optional.
     *  - remark: The default value is `Sequential`. Please see the documentation for `CollectionReversingMode` for more information on these modes.
     */
    public var reversingMode: CollectionReversingMode = .sequential {
        didSet {
            if (reversingMode == .contiguous && reversing) {
                for motion in motions {
                    motion.reversing = true
                    if var collection = motion as? MoveableCollection {
                        // by default, setting a .Contiguous reversingMode will cascade down to sub-collections
                        // since usually a user would expect a contiguous movement from each sub-motion when setting this value
                        collection.reversingMode = .contiguous
                    }
                }
            } else if (reversingMode == .sequential && reversing) {
                for motion in motions {
                    motion.reversing = false
                }
            }
        }
    }
    
    
    
    // MARK: TempoBeating protocol properties
    
    /**
     *  A concrete `Tempo` subclass that provides an update "beat" while a motion operation occurs.
     *
     *  - remark: By default, Motion will assign an instance of `CATempo` to this property, which uses CADisplayLink for interval updates.
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
            
             // tell motions conforming to the `TempoDriven` protocol that don't want their tempo used to stop their tempo updates
            for (index, motion) in motions.enumerated() {
                if let driven = motion as? TempoDriven {
                    if (index < tempoOverrides.count) {
                        let should_override = tempoOverrides[index]
                        if should_override {
                            driven.stopTempoUpdates()
                        }
                    }
                }
            }
        }
    }
    lazy private var _tempo: Tempo? = {
        return CATempo.init()
    }()
    

    
    // MARK: - Notification closures
    
    /**
     *  This closure is called when a motion operation starts. If a delay has been specified, this closure is called after the delay is complete.
     *
     *  - seealso: start
     */
    @discardableResult public func started(_ closure: @escaping GroupStarted) -> Self {
        _started = closure
        
        return self
    }
    private var _started: GroupStarted?
    
    /**
     *  This closure is called when a motion operation is stopped by calling the `stop` method.
     *
     *  - seealso: stop
     */
    @discardableResult public func stopped(_ closure: @escaping GroupStopped) -> Self {
        _stopped = closure
        
        return self
    }
    private var _stopped: GroupStopped?
    
    /**
     *  This closure is called when a motion operation update occurs and this instance's `motionState` is `.Moving`.
     *
     *  - seealso: update(withTimeInterval:)
     */
    @discardableResult public func updated(_ closure: @escaping GroupUpdated) -> Self {
        _updated = closure
        
        return self
    }
    private var _updated: GroupUpdated?
    
    /**
     *  This closure is called when a motion cycle has completed.
     *
     *  - seealso: repeating, cyclesCompletedCount
     */
    @discardableResult public func cycleRepeated(_ closure: @escaping GroupRepeated) -> Self {
        _cycleRepeated = closure
        
        return self
    }
    private var _cycleRepeated: GroupRepeated?
    
    /**
     *  This closure is called when the `motionDirection` property changes to `.Reversing`.
     *
     *  - seealso: motionDirection, reversing
     */
    @discardableResult public func reversed(_ closure: @escaping GroupReversed) -> Self {
        _reversed = closure
        
        return self
    }
    private var _reversed: GroupReversed?
    
    /**
     *  This closure is called when calling the `pause` method on this instance causes a motion operation to pause.
     *
     *  - seealso: pause
     */
    @discardableResult public func paused(_ closure: @escaping GroupPaused) -> Self {
        _paused = closure
        
        return self
    }
    private var _paused: GroupPaused?
    
    /**
     *  This closure is called when calling the `resume` method on this instance causes a motion operation to resume.
     *
     *  - seealso: resume
     */
    @discardableResult public func resumed(_ closure: @escaping GroupResumed) -> Self {
        _resumed = closure
        
        return self
    }
    private var _resumed: GroupResumed?
    
    /**
     *  This closure is called when a motion operation has completed (or when all motion cycles have completed, if `repeating` is set to `true`).
     *
     */
    @discardableResult public func completed(_ closure: @escaping GroupCompleted) -> Self {
        _completed = closure
        
        return self
    }
    private var _completed: GroupCompleted?
    
    
    // MARK: - Private Properties
    
    /// The starting time of the group's current motion operation. A value of 0 means that no motion is currently in progress.
    private var startTime: TimeInterval = 0.0
    
    /// The most recent update timestamp, as sent by the `update` method.
    private var currentTime: TimeInterval = 0.0
    
    /// The ending time of the delay, which is determined by adding the delay to the starting time.
    private var endTime: TimeInterval = 0.0
    
    /// Timestamp when the `pause` method is called, to track amount of time paused.
    private var pauseTimestamp: TimeInterval = 0.0
    
    
    /**
     *  An array of Boolean values representing whether a `Moveable` object should 'override' the MotionGroup's `Tempo` object and use its own instead. The positions of the array correspond to the positions of the `Moveable` objects in the `motions` array.
     */
    private var tempoOverrides: [Bool] = []
    
    /// The number of `Moveable` objects which have completed their motion operations.
    private var motionsCompletedCount: Int = 0
    
    /**
     *  The number of `Moveable` objects which have finished one direction of a movement cycle and are now moving in a reverse direction. This property is used to sync motion operations when `reversing` and `syncMotionsWhenReversing` are both set to `true`.
     */
    private var motionsReversedCount: Int = 0
    
    
    
    
    // MARK: - Initialization
    
    /**
     *  Initializer.
     *
     *  - parameters:
     *      - motions: An array of `Moveable` objects which the MotionGroup should control.
     *      - options: An optional set of `MotionsOptions`.
     */
    public init(motions: [Moveable] = [], options: MotionOptions? = MotionOptions.none) {
        
        // unpack options values
        if let unwrappedOptions = options {
            repeating = unwrappedOptions.contains(.repeats)
            _reversing = unwrappedOptions.contains(.reverses)
        }
        
        motionState = .stopped
        motionDirection = .forward
        
        for motion: Moveable in motions {
            add(motion)
        }
        
        _tempo?.delegate = self
    }
    
    
    deinit {
        tempo?.delegate = nil
        
        for index in 0 ..< motions.count {
            motions[index].updateDelegate = nil
        }
    }
    
    
    // MARK: - Public methods
    
    /**
     *  Adds an object which conforms to the `Moveable` protocol to the group of motion 'children' this object controls.
     *
     *  - parameters:
     *      - motion: An object which adopts the `Moveable` protocol.
     *      - useChildTempo: When `true`, the child object should use its own tempo to update its motion progress, and thus the `update` method will not be called on the object by the MotionGroup instance. The default is `false`, meaning that the MotionGroup will use its own `Tempo` object to send updates to this child motion. This setting has no effect if the motion object does not conform to the `TempoDriven` protocol.
     *
     *
     *  - warning:
     *      - A NSInternalInconsistencyException will be raised if the provided object does not adopt the `Moveable` protocol.
     *      - This method should not be called after a MotionGroup has started moving.
     */
    @discardableResult public func add(_ motion: Moveable, useChildTempo: Bool = false) -> Self {
        
        if (reversing) { motion.reversing = true }
        
        if let tempo_beating = (motion as? TempoDriven) {
            if (!useChildTempo) { tempo_beating.stopTempoUpdates() }
        }
        
        motions.append(motion)
        tempoOverrides.append(!useChildTempo) // use the opposite Boolean value in order to represent which tempos should be overriden by the group
        
        // subscribe to this motion's status updates
        motion.updateDelegate = self
        
        
        return self
    }
    
    /**
     *  Adds an array of `Moveable` objects to the group of motion 'children' this object controls.
     *
     *  - parameter motions: An array of 'Moveable` objects.
     *
     *  - note: All objects added via this method which subscribe to the `TempoDriven` protocol will have their Tempo updates overriden. The MotionGroup will call the `update` method directly on all of them.
     *
     *  - warning:
     *      - A NSInternalInconsistencyException will be raised if the provided object does not adopt the `Moveable` protocol.
     *      - This method should not be called after a MotionGroup has started moving.
     *
     */
    @discardableResult public func add(_ motions: [Moveable]) -> Self {
    
        for motion in motions {
            _ = add(motion)
        }
    
        return self
    }
    
    /**
     *  Removes the specified motion object from the group.
     *
     *  - parameter motion: The motion object to remove.
     */
    public func remove(_ motion: Moveable) {
        
        // first grab the index of the object in the motions array so we can remove the corresponding tempoOverrides value
        let index = motions.firstIndex {
            $0 == motion
        }
        if let motion_index = index {
            motion.updateDelegate = nil
            motions.remove(at: motion_index)
            tempoOverrides.remove(at: motion_index)
        }
        
    }
    
    
    /**
     *  Adds a delay before the motion operation will begin.
     *
     *  - parameter amount: The number of seconds to wait.
     *  - returns: A reference to this MotionGroup instance, for the purpose of chaining multiple calls to this method.
     */
    @discardableResult public func afterDelay(_ amount: TimeInterval) -> MotionGroup {
        
        delay = amount
        
        return self
        
    }
    
    
    /**
     *  Specifies that a motion cycle should repeat and the number of times it should do so. When no value is provided, the motion will repeat infinitely.
     *
     *  - remark: When this method is used there is no need to specify `.Repeat` in the `options` parameter of the init method.
     *
     *  - parameter numberOfCycles: The number of motion cycles to repeat. The default value is `REPEAT_INFINITE`.
     *  - returns: A reference to this MotionGroup instance, for the purpose of chaining multiple calls to this method.
     *  - seealso: repeatCycles, repeating
     */
    @discardableResult public func repeats(_ numberOfCycles: UInt = REPEAT_INFINITE) -> MotionGroup {
        
        repeatCycles = numberOfCycles
        repeating = true
        
        return self
    }
    
    
    
    /**
     *  Specifies that the MotionGroup's child motions should reverse their movements back to their starting values after completing their forward movements.
     *
     *  - remark: When this method is used there is no need to specify `.Reverse` in the `options` parameter of the init method.
     *
     *  - parameter syncMotions: Determines whether the MotionGroup should synchronize when its `Moveable` objects reverse direction during each movement cycle.
     *  - returns: A reference to this MotionGroup instance, for the purpose of chaining multiple calls to this method.
     *  - seealso: reversing, syncMotionsWhenReversing
     */
    @discardableResult public func reverses(syncsChildMotions syncMotions: Bool) -> MotionGroup {
        
        reversing = true
        syncMotionsWhenReversing = syncMotions
        
        
        return self
    }
    
    
    
    
    
    // MARK: - Private methods
    
    /// Starts the group's next repeat cycle, if there is one.
    private func nextRepeatCycle() {
        
        motionDirection = .forward
        cyclesCompletedCount += 1
        if (repeatCycles == 0 || cyclesCompletedCount - 1 < repeatCycles) {
            motionsCompletedCount = 0
            _motionProgress = 0.0
            _cycleProgress = 0.0
            
            // call cycle closure
            weak var weak_self = self
            _cycleRepeated?(weak_self!)
            
            // send repeat status update
            sendStatusUpdate(.repeated)
            
            // restart motions of children for another cycle
            for motion in motions {
                _ = motion.start()
            }
        
        } else {
            groupCompleted()
        }
    }
    
    
    /// Called when all `Moveable` objects in the group have completed their motion operations.
    private func groupCompleted() {
        
        motionState = .stopped
        motionProgress = 1.0
        _cycleProgress = 1.0
        if (!repeating) { cyclesCompletedCount += 1 }

        // call update closure
        weak var weak_self = self
        _updated?(weak_self!)
        
        // call complete closure
        _completed?(weak_self!)
        
        // send completion status update
        sendStatusUpdate(.completed)
        
    }
    
    
    /// Reverses the direction of the motion.
    private func reverseMotionDirection() {
        
        if (motionDirection == .forward) {
            motionDirection = .reverse
            
        } else if (motionDirection == .reverse) {
            motionDirection = .forward
        }
        
        motionsReversedCount = 0
        
        // resume any paused motions
        for motion in motions {
            if (motion.motionState == .paused) {
                motion.resume()
            }
        }
        
        
        // call reverse closure
        weak var weak_self = self
        _reversed?(weak_self!)
        
        // send out 50% complete notification, used by MotionSequence in contiguous mode
        let half_complete = round(Double(repeatCycles) * 0.5)
        if (motionDirection == .reverse && (Double(cyclesCompletedCount) ≈≈ half_complete)) {
            sendStatusUpdate(.halfCompleted)
            
        } else {
            sendStatusUpdate(.reversed)
        }

    }
    

    
    /**
     *  Dispatches a status update to the `MotionUpdateDelegate` delegate assigned to the object, if there is one.
     *
     *  - parameter status: The `MoveableStatus` enum value to send to the delegate.
     */
    private func sendStatusUpdate(_ status: MoveableStatus) {
        
        weak var weak_self = self
        updateDelegate?.motionStatusUpdated(forMotion: weak_self!, updateType: status)
    }
    
    
    /**
     *  Calculates the current progress of the motion.
     *
     */
    private func calculateProgress() {

        // add up all the totalProgress values for each child motion, then clamp it to 1.0
        var children_progress = 0.0
        
        for motion in motions {
            children_progress += motion.totalProgress
        }
        children_progress /= Double(motions.count)
        children_progress = min(children_progress, 1.0)
        cycleProgress = children_progress
        
    }
    
    
    
    
    // MARK: - Moveable protocol methods
    
    public func update(withTimeInterval currentTime: TimeInterval) {
        
        self.currentTime = currentTime
        if (motionState == .moving) {
            for (index, motion) in motions.enumerated() {
                if (index < tempoOverrides.count) {
                    // only call tempo update on motions that were not specified to override
                    let should_override = tempoOverrides[index]
                    if should_override {
                        motion.update(withTimeInterval: currentTime)
                    }
                }
            }
            
            // update progress
            calculateProgress()
            
            // call update closure, but only if this group is still moving
            if (motionState == .moving) {
                weak var weak_self = self
                _updated?(weak_self!)
            }

            
        } else if (motionState == .delayed) {
            
            if (startTime == 0.0) {
                // a start time of 0 means we need to initialize the motion times
                startTime = currentTime
                endTime = startTime + delay
            }
            
            if (self.currentTime >= endTime) {
                // delay is done, time to move
                motionState = .moving
                
                for motion in motions {
                    _ = motion.start()
                }
                
                // call start closure
                weak var weak_self = self
                _started?(weak_self!)
                
                // send start status update
                sendStatusUpdate(.started)
            }
        }
    }
    
    
    @discardableResult public func start() -> Self {
        
        if (motionState == .stopped) {
            reset()
            if (delay == 0.0) {
                motionState = .moving
                for motion in motions {
                    motion.start()
                }
                
                // call start closure
                weak var weak_self = self as MotionGroup
                _started?(weak_self!)
                
                // send start status update
                sendStatusUpdate(.started)
            
            } else {
                motionState = .delayed
            }
        }
        
        return self
    }
    
    
    public func stop() {
        
        if (motionState == .moving || motionState == .paused || motionState == .delayed) {
            motionState = .stopped
            _motionProgress = 0.0
            _cycleProgress = 0.0
            
            for motion in motions {
                motion.stop()
            }
            
            // call stop closure
            weak var weak_self = self as MotionGroup
            _stopped?(weak_self!)
            
            // send stop status update
            sendStatusUpdate(.stopped)
        }
    }
    
    
    public func pause() {
        
        if (motionState == .moving) {
            motionState = .paused
            
            for motion in motions {
                motion.pause()
            }
            
            // call pause closure
            weak var weak_self = self as MotionGroup
            _paused?(weak_self!)
            
            // send pause status update
            sendStatusUpdate(.paused)
        }
        
    }
    
    
    public func resume() {
        
        if (motionState == .paused) {
            motionState = .moving

            for motion in motions {
                motion.resume()
            }
            
            // call resume closure
            weak var weak_self = self as MotionGroup
            _resumed?(weak_self!)
            
            // send resume status update
            sendStatusUpdate(.resumed)
        }
    }
    
    
    /// Resets the group and all child motions to its initial state.
    public func reset() {
        motionState = .stopped
        motionsCompletedCount = 0
        cyclesCompletedCount = 0
        motionDirection = .forward
        motionsReversedCount = 0
        _motionProgress = 0.0
        _cycleProgress = 0.0
        startTime = 0.0
        
        // reset all child motions
        for motion in motions {
            motion.reset()
        }
        
    }
    
    
    
    
    // MARK: - MotionUpdateDelegate methods
    
    public func motionStatusUpdated(forMotion motion: Moveable, updateType status: MoveableStatus) {
        
        switch status {
        case .halfCompleted:
            if (reversing && motionDirection == .forward) {
                motionsReversedCount += 1

                if (syncMotionsWhenReversing && motionsReversedCount >= motions.count) {
                    reverseMotionDirection()
                    
                } else if (syncMotionsWhenReversing) {
                    // pause this motion until all of the group's motions are ready to reverse
                    motion.pause()
                }
                
                if (!syncMotionsWhenReversing && motionDirection == .forward && (Double(motionsReversedCount) / Double(motions.count) >= 0.5)) {
                    reverseMotionDirection()
                }

            }
        case .completed:
            motionsCompletedCount += 1
            if (motionsCompletedCount >= motions.count) {
                if (repeating) {
                    nextRepeatCycle()
                } else {
                    groupCompleted()
                }
            }
        default: break
            
        }
    }
    
    
    // MARK: - TempoDriven methods
    
    public func stopTempoUpdates() {
        
        tempo?.delegate = nil
        tempo = nil
        
    }
    
    
    // MARK: - TempoDelegate methods
    
    public func tempoBeatUpdate(_ timestamp: TimeInterval) {
        update(withTimeInterval: timestamp)
        
    }
    
    
}
