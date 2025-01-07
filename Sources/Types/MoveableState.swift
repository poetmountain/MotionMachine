//
//  MoveableState.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An enum representing the state of a motion operation.
public enum MoveableState {
    /// The state of a motion operation when it is moving.
    case moving
    
    /// The state of a motion operation when it is stopped.
    case stopped
    
    /// The state of a motion operation when it is paused.
    case paused
    
    /// The state of a motion operation when it is delayed.
    case delayed
}
