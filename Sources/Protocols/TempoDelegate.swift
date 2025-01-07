//
//  TempoDelegate.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol defines methods that are called on delegate objects which listen for update beats from a ``TempoProviding`` object.
@MainActor public protocol TempoDelegate: AnyObject {
    
    /**
     *  Sends an update beat that should prompt motion classes to recalculate movement values.
     *
     *  - parameter timestamp: A timestamp by which motion classes can calculate new delta values.
     */
    func tempoBeatUpdate(_ timestamp: TimeInterval)
}
