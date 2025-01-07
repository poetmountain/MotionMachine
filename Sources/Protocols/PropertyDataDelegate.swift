//
//  PropertyDataDelegate.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Provides delegate updates when property values change.
@MainActor public protocol PropertyDataDelegate: AnyObject {
    
    /// Called when the `start` property of a PropertyData instance is updated.
    func didUpdate(_ startValue: Double)
}
