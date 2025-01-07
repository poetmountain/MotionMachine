//
//  TempoProviding.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an object that sends a tempo of updates to motion objects. ``Moveable`` classes use these beats to calculate new motion interpolation values. Objects that conform to this protocol should use the ``TempoDelegate``'s method `tempoBeatUpdate` to send incremental timestamps as necessary.
@MainActor public protocol TempoProviding {
    
    /// A delegate to subscribe to for tempo updates. Concrete implementations of this property should be marked as a `weak` reference.
    var delegate: TempoDelegate? { get set }
    
    /// When this method is called, objects conforming to this protocol should cleanup any resources to prepare for deallocation.
    func cleanupResources()
}
