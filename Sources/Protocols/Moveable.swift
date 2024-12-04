//
//  Moveable.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  This protocol declares methods and properties that must be adopted by custom motion classes in order to participate in the MotionMachine ecosystem. All standard MotionMachine motion classes conform to this protocol.
 */
@MainActor public protocol Moveable: AnyObject {
    
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
     *  A `MotionState` enum which represents the current state of the motion operation. This state should be updated by the class implementing this protocol.
     */
    var motionState: MotionState { get }
    
    
    /**
     *  A Boolean which determines whether a motion operation, when it has moved to the ending value, should move from the ending value back to the starting value.
     *
     *  - remark: When set to `true`, the motion plays in reverse after completing a forward motion. In this state, a motion cycle represents the combination of the forward and reverse motions. The default value should be `false`.
     */
    var reversing: Bool { get set }
    
    
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
