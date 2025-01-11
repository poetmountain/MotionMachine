//
//  Moveable.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol declares methods and properties that must be adopted by custom motion classes in order to participate in the MotionMachine ecosystem. All standard MotionMachine motion classes conform to this protocol.
@MainActor public protocol Moveable: AnyObject {
    
    /// Represents an infinite number of repeat motion cycles.
    static var REPEAT_INFINITE: UInt { get }
    
    // Controlling a motion
    
    /**
     *  Stops a motion that is currently moving. (required)
     *
     *  - remark: When this method is called, a motion should only enter a stopped state if it currently moving.
     */
    func stop()
    
    /**
     *  Starts a motion that is currently stopped. (required)
     *
     *  - remark: This method can be chained when initializing the object.
     *  - note: When this method is called, a motion should only start moving if it is stopped.
     *  - returns: A reference to the Moveable instance; used to method chain initialization methods when the Moveable instance is created.
     */
    @discardableResult func start() -> Self
    
    /**
     *  Pauses a motion that is currently moving. (required)
     *
     *  - remark: When this method is called, a motion should only enter a paused state if it is currently moving.
     */
    func pause()
    
    /**
     *  Resumes a motion that is currently paused. (required)
     *
     *  - remark: When this method is called, a motion should only resume moving if it is currently paused.
     */
    func resume()
    
    /**
     *  Resets a motion to its initial state. Custom classes implementing this method must reset all relevant properties, including `totalProgress`.  (required)
     *
     *  - remark: This method is used by `Moveable` collection classes to properly reset child motions for new movement cycles and when starting a motion again using the `start` method.
     */
    func reset()
    
    /**
     *  An enum which represents the current state of the motion operation. This state should be updated by the class implementing this protocol.
     */
    var motionState: MoveableState { get }
    
    
    /**
     *  A Boolean which determines whether a motion operation, when it has moved to the ending value, should move from the ending value back to the starting value.
     *
     *  - remark: When set to `true`, the motion plays in reverse after completing a forward motion. In this state, a motion cycle represents the combination of the forward and reverse motions. The default value should be `false`.
     */
    var isReversing: Bool { get set }

    /**
     *  A Boolean which determines whether the sequence should repeat. When set to `true`, the sequence repeats for the number of times specified by the ``repeatCycles`` property. The default value is `false`.
     *
     *  - note: By design, setting this value to `true` without changing the ``repeatCycles`` property from its default value (0) will cause the sequence to repeat infinitely.
     */
    var isRepeating: Bool { get set }
    
    /**
     *  The number of complete sequence cycle operations to repeat.
     *
     *  - remark: This property is only used when ``isRepeating`` is set to `true`. Assigning `REPEAT_INFINITE` to this property signals an infinite amount of motion cycle repetitions. The default value is `REPEAT_INFINITE`.
     *
     */
    var repeatCycles: UInt { get set }
    
    /**
     *  A value between 0.0 and 1.0, which represents the current overall progress of a motion. This value should include all reversing and repeat motion cycles. (read-only)
     *
     */
    var totalProgress: Double { get }

    /**
     *  Provides a delegate for sending `MoveableStatus` updates from a `Moveable` object. This property is used by `Moveable` collection classes. Any custom `Moveable` classes must send status updates using this delegate.
     *
     *  - warning: This delegate is only used by `Moveable` objects to communicate with other `Moveable` objects. End-users should not assign their own delegate to this property. If you need status updates for a `Moveable` object, please use the provided callback closures.
     */
    var updateDelegate: MotionUpdateDelegate? { get set }
    
    /// An internal property used to track Moveable objects globally. This value is set by MotionMachine and should not be altered.
    var operationID: UInt { get }

    
    // Updating a motion
    
    /**
     *  This method is called to prompt a motion class to update its current movement values.
     *
     *  - parameter currentTime: A timestamp that can be used in easing calculations.
     */
    func update(withTimeInterval currentTime: TimeInterval)
    
    /// Calling this method on the conforming object should cleanup any resources to prepare for deallocation.
    func cleanupResources()
}

public extension Moveable {
    // Default implementation
    func cleanupResources() {}
    
}

public extension Moveable {
    
    nonisolated static var REPEAT_INFINITE: UInt {
        return 0
    }
}
