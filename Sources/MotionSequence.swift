//
//  MotionSequence.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/11/16.
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

public typealias SequenceUpdateClosure = (_ sequence: MotionSequence) -> Void

/**
 *  This notification closure should be called when the `start` method starts a motion operation. If a delay has been specified, this closure is called after the delay is complete.
 *
 *  - seealso: start
 */
public typealias SequenceStarted = SequenceUpdateClosure

/**
 *  This notification closure should be called when the `stop` method starts a motion operation.
 *
 *  - seealso: stop
 */
public typealias SequenceStopped = SequenceUpdateClosure


/**
 *  This notification closure should be called when the `update` method is called while a Moveable object is currently moving.
 *
 *  - seealso: update
 */
public typealias SequenceUpdated = SequenceUpdateClosure


/**
 *  This notification closure should be called when a motion operation reverses its movement direction.
 *
 */
public typealias SequenceReversed = SequenceUpdateClosure

/**
 *  This notification closure should be called when a motion has started a new repeat cycle.
 *
 */
public typealias SequenceRepeated = SequenceUpdateClosure

/**
 *  This notification closure should be called when calling the `pause` method pauses a motion operation.
 *
 */
public typealias SequencePaused = SequenceUpdateClosure

/**
 *  This notification closure should be called when calling the `resume` method resumes a motion operation.
 *
 */
public typealias SequenceResumed = SequenceUpdateClosure

/**
 *  This notification closure should be called when a motion operation has fully completed.
 *
 *  - remark: This closure should only be executed when all activity related to the motion has ceased. For instance, if a Moveable class allows a motion to be repeated multiple times, this closure should be called when all repetitions have finished.
 *
 */
public typealias SequenceCompleted = SequenceUpdateClosure

/**
 *  This notification closure should be called when a sequence's movement has advanced to its next sequence step.
 *
 */
public typealias SequenceStepped = SequenceUpdateClosure


/**
 *  MotionSequence moves a collection of objects conforming to the `Moveable` protocol in sequential order. MotionSequence provides a powerful and easy way of chaining together individual motions to create complex animations.
 */
public class MotionSequence: Moveable, MoveableCollection, TempoDriven, MotionUpdateDelegate {

    // MARK: - Public Properties
    
    ///-------------------------------------
    /// Setting Up a MotionSequence
    ///-------------------------------------
    
    /**
     *  The delay, in seconds, before the sequence begins.
     *
     *  - warning: Setting this parameter after a sequence has begun has no effect.
     */
    public var delay: TimeInterval = 0.0
    
    /**
     *  A Boolean which determines whether the sequence should repeat. When set to `true`, the sequence repeats for the number of times specified by the `repeatCycles` property. The default value is `false`.
     *
     *  - note: By design, setting this value to `true` without changing the `repeatCycles` property from its default value (0) will cause the sequence to repeat infinitely.
     *  - seealso: repeatCycles
     */
    public var repeating: Bool = false
    
    
    /**
     *  The number of complete sequence cycle operations to repeat.
     *
     *  - remark: This property is only used when `repeating` is set to `true`. Assigning `REPEAT_INFINITE` to this property signals an infinite amount of motion cycle repetitions. The default value is `REPEAT_INFINITE`.
     *
     *  - seealso: repeating
     */
    public var repeatCycles: UInt = REPEAT_INFINITE
    
    

    // MOTION STATE
    
    /**
     *  An array of `Moveable` objects controlled by this MotionSequence object, determining each step of the sequence. (read-only)
     *
     *  - remark: The order of objects in this array represents the sequence order in which each will be moved.
     */
    private(set) public var steps: [Moveable] = []
    

    
    /// A `MotionDirection` enum which represents the current direction of the motion operation. (read-only)
    private(set) public var motionDirection: MotionDirection

    /**
     *  A value between 0.0 and 1.0, which represents the current progress of a movement between two value destinations. (read-only)
     *
     *  - remark: Be aware that if this motion is `reversing` or `repeating`, this value will only represent one movement. For instance, if a Motion has been set to repeat once, this value will move from 0.0 to 1.0, then reset to 0.0 again as the new repeat cycle starts. Similarly, if a Motion is set to reverse, this progress will represent each movement; first in the forward direction, then again when reversing back to the starting values.
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
     *  A value between 0.0 and 1.0, which represents the current overall progress of the sequence. This value should include all reversing and repeat motion cycles. (read-only)
     *
     *  - remark: If a sequence is not repeating, this value will be equivalent to the value of `cycleProgress`.
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
    
    /**
     *  Specifies that the MotionSequence's child motions should reverse their movements back to their starting values after completing their forward movements. When each child motion should reverse is determined by the MotionSequence's `reversingMode`.
     *
     *  - important: The previous state of `reversing` on any of this sequence's `Moveable` objects will be overridden with the value you assign to this property!
     */
    public var reversing: Bool {
        get {
            return _reversing
        }
        
        set(newValue) {
            _reversing = newValue
            
            // change the `reversing` property on each `Moveable` object sequence step to reflect the sequence's new state
            if (reversingMode == .contiguous) {
                for step in steps {
                    step.reversing = _reversing
                }
            }
            
            motionsReversedCount = 0
        }

    }
    private var _reversing: Bool = false
    
    
    /// A `MotionState` enum which represents the current movement state of the motion operation. (read-only)
    private(set) public var motionState: MotionState
    
    /// Provides a delegate for updates to a Moveable object's status, used by Moveable collections.
    public weak var updateDelegate: MotionUpdateDelegate?
    
    
    // MARK: MoveableCollection protocol properties
    
    /**
     *  A `CollectionReversingMode` enum which defines the behavior of a `Moveable` class when its `reversing` property is set to `true`. In the standard MotionMachine classes only `MotionSequence` currently uses this property to alter its behavior.
     *
     *  - note: While including this property in custom classes which implement the `MoveableCollection` protocol is required, implementation of behavior based on the property's value is optional.
     *  - remark: The default value is `Sequential`. Please see the documentation for `CollectionReversingMode` for more information on these modes.
     */
    public var reversingMode: CollectionReversingMode = .sequential {
        didSet {
            if (reversingMode == .contiguous && reversing) {
                for step in steps {
                    step.reversing = true
                    if var collection = step as? MoveableCollection {
                        // by default, setting a .Contiguous reversingMode will cascade down to sub-collections
                        // since usually a user would expect a contiguous movement from each sub-motion when setting this value
                        collection.reversingMode = .contiguous
                    }
                }
            } else if (reversingMode == .sequential && reversing) {
                for step in steps {
                    step.reversing = false
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
            
            // tell sequence steps conforming to the `TempoDriven` protocol that don't want their tempo used to stop their tempo updates
            for (index, step) in steps.enumerated() {
                if let driven = step as? TempoDriven {
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
     *  This closure is called when a motion operation starts.
     *
     *  - seealso: start
     */
    @discardableResult public func started(_ closure: @escaping SequenceStarted) -> Self {
        _started = closure
        
        return self
    }
    private var _started: SequenceStarted?
    
    /**
     *  This closure is called when a motion operation is stopped by calling the `stop` method.
     *
     *  - seealso: stop
     */
    @discardableResult public func stopped(_ closure: @escaping SequenceStopped) -> Self {
        _stopped = closure
        
        return self
    }
    private var _stopped: SequenceStopped?
    
    /**
     *  This closure is called when a motion operation update occurs and this instance's `motionState` is `.Moving`.
     *
     *  - seealso: update(withTimeInterval:)
     */
    @discardableResult public func updated(_ closure: @escaping SequenceUpdated) -> Self {
        _updated = closure
        
        return self
    }
    private var _updated: SequenceUpdated?
    
    /**
     *  This closure is called when a motion cycle has completed.
     *
     *  - seealso: repeating, cyclesCompletedCount
     */
    @discardableResult public func cycleRepeated(_ closure: @escaping SequenceRepeated) -> Self {
        _cycleRepeated = closure
        
        return self
    }
    private var _cycleRepeated: SequenceRepeated?
    
    /**
     *  This closure is called when the `motionDirection` property changes to `.Reversing`.
     *
     *  - seealso: motionDirection, reversing
     */
    @discardableResult public func reversed(_ closure: @escaping SequenceReversed) -> Self {
        _reversed = closure
        
        return self
    }
    private var _reversed: SequenceReversed?
    
    /**
     *  This closure is called when calling the `pause` method on this instance causes a motion operation to pause.
     *
     *  - seealso: pause
     */
    @discardableResult public func paused(_ closure: @escaping SequencePaused) -> Self {
        _paused = closure
        
        return self
    }
    private var _paused: SequencePaused?
    
    /**
     *  This closure is called when calling the `resume` method on this instance causes a motion operation to resume.
     *
     *  - seealso: resume
     */
    @discardableResult public func resumed(_ closure: @escaping SequenceResumed) -> Self {
        _resumed = closure
        
        return self
    }
    private var _resumed: SequenceResumed?
    
    /**
     *  This closure is called when a motion operation has completed (or when all motion cycles have completed, if `repeating` is set to `true`).
     *
     */
    @discardableResult public func completed(_ closure: @escaping SequenceCompleted) -> Self {
        _completed = closure
        
        return self
    }
    private var _completed: SequenceCompleted?
    
    /**
     *  This notification closure is called when the sequence's movement has advanced to its next sequence step.
     *
     */
    @discardableResult public func stepCompleted(_ closure: @escaping SequenceStepped) -> Self {
        _stepCompleted = closure
        
        return self
    }
    private var _stepCompleted: SequenceStepped?
    
    
    
    // MARK: - Private Properties
    
    /// The starting time of the current sequence's delay. A value of 0 means that no motion is currently in progress.
    private var startTime: TimeInterval = 0.0
    
    /// The most recent update timestamp, as sent by the `update` method.
    private var currentTime: TimeInterval = 0.0
    
    /// The ending time of the delay, which is determined by adding the delay to the starting time.
    private var endTime: TimeInterval = 0.0
    
    /// Timestamp when the `pause` method is called, to track amount of time paused.
    private var pauseTimestamp: TimeInterval = 0.0
    
    
    /**
     *  An array of Boolean values representing whether a `Moveable` object should 'override' the MotionSequence's `Tempo` object and use its own instead. The positions of the array correspond to the positions of the `Moveable` objects in the `steps` array.
     */
    private var tempoOverrides: [Bool] = []
    
    /// An integer representing the position of the current sequence step.
    private var currentSequenceIndex: Int = 0
    
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
     *      - steps: An array of `Moveable` objects the MotionSequence should control. The positions of the objects in the Array will determine the order in which the child motions should move.
     *      - options: An optional set of `MotionsOptions`.
     */
    public init(steps: [Moveable] = [], options: MotionOptions? = MotionOptions.none) {
        
        // unpack options values
        if let unwrappedOptions = options {
            repeating = unwrappedOptions.contains(.repeats)
            _reversing = unwrappedOptions.contains(.reverses)
        }
        
        motionState = .stopped
        motionDirection = .forward
        
        for step: Moveable in steps {
            add(step)
        }
        
        _tempo?.delegate = self
    }
    
    
    deinit {
        tempo?.delegate = nil
        
        for index in 0 ..< steps.count {
            steps[index].updateDelegate = nil
        }
    }
    
    
    // MARK: - Public methods
    
    /**
     *  Adds a sequence step to the end of the current sequence.
     *
     *  - parameters:
     *      - sequenceStep: An object which adopts the `Moveable` protocol.
     *      - useChildTempo: When `true`, the child object should use its own tempo to update its motion progress, and thus the `update` method will not be called on the object by the MotionSequence instance. The default is `false`, meaning that the MotionSequence will use its own `Tempo` object to send updates to this child motion. This setting has no effect if the motion object does not conform to the `TempoDriven` protocol.
     *
     *
     *  - warning:
     *      - A NSInternalInconsistencyException will be raised if the provided object does not adopt the `Moveable` protocol.
     *      - This method should not be called after a MotionSequence has started moving.
     */
    @discardableResult public func add(_ sequenceStep: Moveable, useChildTempo: Bool = false) -> Self {
        
        if (reversing && reversingMode == .contiguous) {
            sequenceStep.reversing = true
        }
        
        if let tempo_beating = (sequenceStep as? TempoDriven) {
            if (!useChildTempo) { tempo_beating.stopTempoUpdates() }
        }
        
        steps.append(sequenceStep)
        tempoOverrides.append(!useChildTempo) // use the opposite Boolean value in order to represent which tempos should be overriden by the sequence
        
        // subscribe to this motion's status updates
        sequenceStep.updateDelegate = self
        
        
        return self
    }
    
    /**
     *  Adds an array of sequence steps to the current sequence.
     *
     *  - parameter steps: An array of 'Moveable` objects.
     *
     *  - note: All objects added via this method which subscribe to the `TempoDriven` protocol will have their Tempo updates overriden. The MotionSequence will call the `update` method directly on all of them.
     *
     *  - warning:
     *      - A NSInternalInconsistencyException will be raised if the provided object does not adopt the `Moveable` protocol.
     *      - This method should not be called after a MotionGroup has started moving.
     *
     */
    @discardableResult public func add(_ steps: [Moveable]) -> Self {
        
        for step in steps {
            _ = add(step)
        }
        
        return self
    }
    
    /**
     *  Removes the specified motion object from the sequence.
     *
     *  - parameter sequenceStep: The sequence step to remove.
     */
    public func remove(_ sequenceStep: Moveable) {
        
        // first grab the index of the object in the motions array so we can remove the corresponding tempoOverrides value
        let index = steps.firstIndex {
            $0 == sequenceStep
        }
        
        if let motion_index = index {
            sequenceStep.updateDelegate = nil
            steps.remove(at: motion_index)
            tempoOverrides.remove(at: motion_index)
        }
        
    }
    
    
    /**
     *  Adds a delay before the motion operation will begin.
     *
     *  - parameter amount: The number of seconds to wait.
     *  - returns: A reference to this MotionSequence instance, for the purpose of chaining multiple calls to this method.
     */
    @discardableResult public func afterDelay(_ amount: TimeInterval) -> MotionSequence {
        
        delay = amount
        
        return self
        
    }
    
    /**
     *  Specifies that a motion cycle should repeat and the number of times it should do so. When no value is provided, the motion will repeat infinitely.
     *
     *  - remark: When this method is used there is no need to specify `.Repeat` in the `options` parameter of the init method.
     *
     *  - parameter numberOfCycles: The number of motion cycles to repeat. The default value is `REPEAT_INFINITE`.
     *  - returns: A reference to this MotionSequence instance, for the purpose of chaining multiple calls to this method.
     *  - seealso: repeatCycles, repeating
     */
    @discardableResult public func repeats(_ numberOfCycles: UInt = REPEAT_INFINITE) -> MotionSequence {
        
        repeatCycles = numberOfCycles
        repeating = true
        
        return self
    }
    
    
    
    /**
     *  Specifies that the MotionSequence's child motions should reverse their movements back to their starting values after completing their forward movements.
     *
     *  - remark: When this method is used there is no need to specify `.Reverse` in the `options` parameter of the init method.
     *
     *  - parameter mode: Defines the `CollectionReversingMode` used when reversing.
     *  - returns: A reference to this MotionSequence instance, for the purpose of chaining multiple calls to this method.
     *  - seealso: reversing, reversingMode
     */
    @discardableResult public func reverses(_ mode: CollectionReversingMode = .sequential) -> MotionSequence {
        
        reversing = true
        reversingMode = mode
        
        return self
    }
    
    
    
    /**
     *  Either the sequence step which is currently moving, or the first sequence step if this instance's `motionState` is currently `Stopped`.
     *
     *  - returns: The current sequence step.
     */
    public func currentStep() -> Moveable? {
        
        var sequence_step: Moveable?
        
        if (currentSequenceIndex < steps.count && currentSequenceIndex >= 0) {
            sequence_step = steps[currentSequenceIndex]
        }
        
        return sequence_step
    }
    
    
    
    
    // MARK: Private methods
    
    /// Starts the sequence's next repeat cycle, if there is one.
    private func nextRepeatCycle() {
        
        cyclesCompletedCount += 1
        if (repeatCycles == 0 || cyclesCompletedCount - 1 < repeatCycles) {
            // reset sequence for another cycle
            currentSequenceIndex = 0
            _motionProgress = 0.0
            _cycleProgress = 0.0
            
            // reset all sequence steps
            for step in steps {
                step.reset()
            }
            
            // call cycle closure
            weak var weak_self = self
            _cycleRepeated?(weak_self!)
            
            if (reversing) {
                if (motionDirection == .forward) {
                    motionDirection = .reverse
                    
                } else if (motionDirection == .reverse) {
                    motionDirection = .forward
                }
                
                motionsReversedCount = 0
            }
            
            // send repeat status update
            sendStatusUpdate(.repeated)
            
            if (reversing && reversingMode == .sequential) {
                currentSequenceIndex += 1
            }
            
            // start first sequence step
            if let step = currentStep() {
                if (step.motionState == .paused) {
                    step.resume()
                }
                _ = step.start()
            }
        
        } else {
            sequenceCompleted()
        }
        
    }
    
    
    /// Starts the next sequence step if the sequence is not yet complete.
    private func nextSequenceStep() {
        
        if (
            (!reversing && currentSequenceIndex + 1 < steps.count)
            || (reversing && (motionDirection == .forward && currentSequenceIndex + 1 < steps.count))
            || (reversing && (motionDirection == .reverse && currentSequenceIndex - 1 >= 0))
            ) {
            
            if (!reversing || (reversing && motionDirection == .forward)) {
                currentSequenceIndex += 1
            } else if (reversing && motionDirection == .reverse) {
                currentSequenceIndex -= 1
            }
            
            // call step closure
            weak var weak_self = self
            _stepCompleted?(weak_self!)
            
            // send step status update
            sendStatusUpdate(.stepped)
            
            // start the next sequence step
            if let next_step = currentStep() {

                if (!reversing
                    || (reversing && reversingMode == .contiguous && motionDirection == .forward)
                    || (reversing && reversingMode == .sequential)) {
                    _ = next_step.start()
                    
                } else {
                    if (next_step.motionState == .paused) {
                        next_step.resume()
                    }
                }
            }
            

        }
        
        
    }

    
    /// Reverses the direction of the sequence.
    private func reverseMotionDirection() {
        if (motionDirection == .forward) {
            motionDirection = .reverse
            
        } else if (motionDirection == .reverse) {
            motionDirection = .forward
        }
        
        motionsReversedCount = 0
        
        // call reverse closure
        weak var weak_self = self
        _reversed?(weak_self!)
        
        let half_complete = round(Double(repeatCycles) * 0.5)
        if (motionDirection == .reverse && (Double(cyclesCompletedCount) ≈≈ half_complete)) {
            sendStatusUpdate(.halfCompleted)
            
        } else {
            sendStatusUpdate(.reversed)
        }
    }
    
    
    /// Called when the sequence has completed its movement.
    private func sequenceCompleted() {
        
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
     *  Calculates the current progress of the sequence.
     *
     */
    private func calculateProgress() {
        
        // add up all the totalProgress values for each child motion, then clamp it to 1.0
        var children_progress = 0.0
        
        for step in steps {
            children_progress += step.totalProgress
        }
        children_progress /= Double(steps.count)
        if (reversing && reversingMode == .sequential) {
            children_progress *= 0.5
            
            if (motionDirection == .reverse) {
                children_progress += 0.5
            }
        }
        children_progress = min(children_progress, 1.0)
        cycleProgress = children_progress
        
    }
    
    
    
    
    // MARK: Moveable methods
    
    public func update(withTimeInterval currentTime: TimeInterval) {
    
        self.currentTime = currentTime
        
        if (motionState == .moving) {
            
            if (startTime == 0.0 && cyclesCompletedCount == 0) { startTime = currentTime }
            
            if (currentSequenceIndex < tempoOverrides.count) {
                if let step = currentStep() {
                    let should_send_tempo = tempoOverrides[currentSequenceIndex]
                    if should_send_tempo {
                        step.update(withTimeInterval: currentTime)
                    }
                }
            }
            
            // update progress
            calculateProgress()
            
            // call update closure, but only if this sequence is still moving
            if (motionState == .moving) {
                weak var weak_self = self as MotionSequence
                _updated?(weak_self!)
            }
            
        } else if (motionState == .delayed) {
            
            if (startTime == 0.0) {
                // a start time of 0.0 means we need to initialize the motion times
                startTime = currentTime
                endTime = startTime + delay
            }
            
            if (currentTime >= endTime) {
                // delay is done, time to move
                motionState = .moving
                
                if let step = currentStep() {
                    _ = step.start()
                }
                
                // call start closure
                weak var weak_self = self as MotionSequence
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
               
                if let sequence_step = currentStep() {
                    _ = sequence_step.start()
                }
                
                // call start closure
                weak var weak_self = self as MotionSequence
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
            
            if let sequence_step = currentStep() {
                sequence_step.stop()
            }
            
            // call stop closure
            weak var weak_self = self as MotionSequence
            _stopped?(weak_self!)
            
            // send stop status update
            sendStatusUpdate(.stopped)
        }
    }
    
    
    public func pause() {
        
        if (motionState == .moving) {
            motionState = .paused
            
            if let sequence_step = currentStep() {
                sequence_step.pause()
            }
            
            // call pause closure
            weak var weak_self = self as MotionSequence
            _paused?(weak_self!)
            
            // send pause status update
            sendStatusUpdate(.paused)
        }
        
    }
    
    
    public func resume() {
        if (motionState == .paused) {
            motionState = .moving
            
            if let sequence_step = currentStep() {
                sequence_step.resume()
            }
            
            // call resume closure
            weak var weak_self = self as MotionSequence
            _resumed?(weak_self!)
            
            // send resume status update
            sendStatusUpdate(.resumed)
        }
    }
    
    
    
    /// Resets the sequence and all child motions to its initial state.
    public func reset() {
        
        motionState = .stopped
        currentSequenceIndex = 0
        motionsCompletedCount = 0
        cyclesCompletedCount = 0
        motionDirection = .forward
        motionsReversedCount = 0
        _motionProgress = 0.0
        _cycleProgress = 0.0
        startTime = 0.0
        
        // reset all sequence steps
        for step in steps {
            step.reset()
        }
        
    }
    
    
    
    // MARK: - MotionUpdateDelegate methods
    
    public func motionStatusUpdated(forMotion motion: Moveable, updateType status: MoveableStatus) {
        
        calculateProgress()
        
        switch status {
            
        case .halfCompleted:
            
            if (reversing && reversingMode == .contiguous && motionDirection == .forward) {
                motionsReversedCount += 1
                if (motionsReversedCount >= steps.count) {
                    
                    // the last sequence step has reversed, so we need to unpause each step backwards in sequence
                    reverseMotionDirection()
                } else {
                    // pause this motion step until we're ready for it to complete the back half of its motion cycle
                    motion.pause()
                    
                    nextSequenceStep()
                }
            }
            
        case .completed:

            if ((motionDirection == .reverse && currentSequenceIndex - 1 >= 0) || (motionDirection == .forward && currentSequenceIndex + 1 < steps.count)
                ) {
                // if there is another sequence step in the direction of movement, then move to the next step
                nextSequenceStep()
            
            } else {
                if (reversing && reversingMode == .sequential && ((motionDirection == .forward && currentSequenceIndex + 1 >= steps.count)
                    || (motionDirection == .reverse && currentSequenceIndex - 1 == 0))) {
                    // if the sequence is set to reverse its motion and mode is noncontiguous
                    // + if the sequence has no more steps left
                    // then flip the motion direction and play the sequence again
                    
                    if (steps.count > 1) {
                        reverseMotionDirection()
                        
                        // reset all step progress so totalProgress and cycleProgress remain accurate
                        for step in steps {
                            step.reset()
                        }
                        
                        // start the same clip again
                        if (!reversing || (reversing && motionDirection == .forward)) {
                            currentSequenceIndex -= 1
                        } else if (reversing && motionDirection == .reverse) {
                            currentSequenceIndex += 1
                        }
                        
                        nextSequenceStep()

                    } else {
                        // if there's only one step, just end the sequence
                        sequenceCompleted()
                    }
                
                } else if (repeating) {
                    nextRepeatCycle()
                } else {
                    sequenceCompleted()
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
