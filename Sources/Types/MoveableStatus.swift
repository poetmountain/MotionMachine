//
//  MoveableStatus.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An enum representing possible status types being sent by a ``Moveable`` object to its ``MotionUpdateDelegate`` delegate.
public enum MoveableStatus {
    
    /// A ``Moveable`` object's motion operation has started.
    case started
    
    /// A ``Moveable`` object's motion operation has been stopped manually (when the stop() method is called) prior to completion.
    case stopped
    
    /**
     *  A ``Moveable`` object's motion operation has completed 50% of its total movement.
     *
     *  - remark: This status should only be sent when half of the activity related to the motion has ceased. For instance, if a ``Moveable`` class is set to repeat two times and its ``isReversing`` property is set to `true`, it should send this status after the second reversal of direction.
     */
    case halfCompleted
    
    /**
     *  A ``Moveable`` object's motion operation has fully completed.
     *
     *  - remark: This status should only be posted when all activity related to the motion has ceased. For instance, if a ``Moveable`` class allows a movement to be repeated multiple times, this status should only be sent when all repetitions have finished.
     */
    case completed
    
    /// A ``Moveable`` object's motion operation has updated the properties it is moving.
    case updated
    
    /// A ``Moveable`` object's motion operation has reversed its movement direction.
    case reversed
    
    /// A ``Moveable`` object's motion operation has started a new repeat cycle.
    case repeated
    
    /// A ``Moveable`` object's motion operation has paused.
    case paused
    
    /// A ``Moveable`` object's motion operation has resumed.
    case resumed
    
    /// A ``Moveable`` object sequence collection (such as ``MotionSequence``) when its movement has advanced to the next sequence step.
    case stepped
}
