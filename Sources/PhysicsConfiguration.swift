//
//  PhysicsData.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This model is used to configure a ``PhysicsSystem`` object.
public struct PhysicsConfiguration {
    
    /// The velocity value to use in physics calculations. An appropriate value should be chosen based on the property you wish to modify.
    public var velocity: Double

    /// The friction value to be applied in physics calculations. Valid values are between 0.0 and 1.0, with 0.0 denoting almost no friction, and 1.0 causing no movement to occur. Any values outside that range will be clamped by the motion object.
    public var friction: Double
    
    /// An optional restitution value from 0.0 to 1.0 which represents the elasticity of an object and is used in collision calculations, with 0.0 representing a perfectly inelastic collision (in which the object does not rebound at all during a collision), and 1.0 representing a perfectly elastic collision (in which the object rebounds with no loss of velocity). Provided values outside of that range are clamped to the closest minimum or maximum value.
    public var restitution: Double?
    
    
    /// This Boolean denotes whether a ``PhysicsSystem`` object should handle collisions between an object and the specified collision points.
    public var useCollisionDetection: Bool?
    
    
    /// Initializer.
    /// - Parameters:
    ///   - velocity: The velocity value to use in physics calculations.
    ///   - friction: The friction value to be applied in physics calculations. Valid values are between 0.0 and 1.0, with 0.0 denoting almost no friction, and 1.0 causing no movement to occur.
    ///   - restitution: An optional restitution value from 0.0 to 1.0 which represents the elasticity of an object during collisions.
    ///   - useCollisionDetection: This Boolean denotes whether a ``PhysicsSystem`` object should handle collisions between an object and the specified collision points.
    public init(velocity: Double, friction: Double, restitution: Double? = nil, useCollisionDetection: Bool? = nil) {
        self.velocity = velocity
        self.friction = friction
        self.restitution = restitution
        if let useCollisionDetection {
            self.useCollisionDetection = useCollisionDetection
        }
    }
}
