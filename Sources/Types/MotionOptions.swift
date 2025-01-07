//
//  MotionOptions.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An integer options set providing possible initialization options for a `Moveable` object.
public struct MotionOptions : OptionSet, Sendable {
    public let rawValue: UInt
    
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    /// No options are specified.
    public static let none                     = MotionOptions([])
    
    /// Specifies that a motion should repeat.
    public static let repeats                   = MotionOptions(rawValue: 1 << 0)
    
    /// Specifies that a motion should reverse directions after moving in the forward direction.
    public static let reverses                  = MotionOptions(rawValue: 1 << 1)
    
    /// Specifies that a motion's property (or parent, if property is not KVC-compliant) should be reset to its starting value on repeats or restarts.
    ///
    /// > Note: `Motion` and `PhysicsMotion` are the only MotionMachine classes that currently accept this option.
    public static let resetsStateOnRepeat       = MotionOptions(rawValue: 1 << 2)
    
    /// Specifies that a motion's value interpolations should be additive in nature.
    ///
    /// > Note: `Motion` and `PhysicsMotion` are the only MotionMachine classes that currently accept this option.
    public static let additive                  = MotionOptions(rawValue: 1 << 3)
}

