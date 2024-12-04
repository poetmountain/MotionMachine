//
//  Tempo.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  `Tempo` is an abstract class that provides a basic structure for sending update beats. `Moveable` classes use these beats to calculate new motion interpolation values. Concrete subclasses should call `tempoBeatUpdate` with incremental timestamps as necessary.
 
    - warning: This class should not be instantiated directly, as it provides no updates on its own.
 */
@MainActor public class Tempo {
    /// A delegate to subscribe to for tempo updates.
    public weak var delegate: TempoDelegate?

    /// Calling this method on subclasses should cleanup any resources to prepare for deallocation.
    public func cleanupResources() {}
}
