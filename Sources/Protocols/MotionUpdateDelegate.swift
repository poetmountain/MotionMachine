//
//  MotionUpdateDelegate.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This delegate protocol defines a status update method in order for `Moveable` objects to communicate with one another. MotionMachine collection classes use this protocol method to keep track of child motion status changes. Any custom `Moveable` classes must send `MoveableStatus` status updates using this protocol.
@MainActor public protocol MotionUpdateDelegate: AnyObject {
    
    /**
     *  This delegate method is called when a `Moveable` object has updated its status.
     *
     *  - parameters:
     *      - mover: A `Moveable` object that calls this delegate method.
     *      - type: The type of status update being sent.
     */
    func motionStatusUpdated(forMotion motion: Moveable, updateType status: MoveableStatus)
    
}
