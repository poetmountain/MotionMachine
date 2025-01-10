//
//  Additive.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol declares methods and properties that must be adopted by custom ``Moveable`` classes who participate in additive animations with other MotionMachine classes.
@MainActor public protocol Additive<TargetType>: PropertyCollection, Identifiable, Equatable {
    
    /**
     *  A Boolean which determines whether this motion object should change its object values additively. Additive animation allows multiple motions to produce a compound effect, creating smooth transitions and blends between different ending value targets. Additive animation has been the default behavior for UIKit animations since iOS 8 and is great for making user interface animations fluid and responsive. MotionMachine uses its own implementation of additive movement, so you can use additive motions on any supported object properties.
     *
     *   By default, each Additive object should apply a strong influence on the movement of a property towards its ending value. This means that two Additive objects with the same duration and moving the same object property to different ending values will fight, and the "winning" value will be the last Additive object to start its movement. If the durations or starting times are different, a transition between the values will occur. If you wish to create additive motions that apply weighted value updates, you can adjust the ``additiveWeighting`` property. Setting values to that property that are less than 1.0 will create compound additive motions that are blends of each motion object's ending values.
     *
     *
     */
    var isAdditive: Bool { get }
    
    var id: UUID { get }
    
    /**
     *  A weighting between 0.0 and 1.0 which is applied to this Motion's object value updates when it is using an additive movement. The higher the weighting amount, the more its additive updates apply to the properties being moved. A value of 1.0 will mean the motion will reach the specific `end` value of each ``PropertyData`` being moved, while a value of 0.0 will not move towards the `end` value at all. When multiple motions participating in additive motion are moving the same object properties, adjusting this weighting on each Motion can create complex composite motions.
     *
     *  - note: This value only has an effect when ``isAdditive`` is set to `true`.
     */
    var additiveWeighting: Double { get set }
    
    /**
     *  An operation identifier is assigned to an Additive instance when it is moving an object's property and its motion operation is currently in progress. (read-only)
     *
     */
    var operationID: UInt { get }
    
    
}

extension Additive {
    public static func == (lhs: any Additive, rhs: any Additive) -> Bool {
        return (lhs.id == rhs.id)
    }
}
