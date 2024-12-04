//
//  PhysicsSystem.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents physics solving systems that calculate the positions of values over time, and is used in ``PhysicsMotion`` and ``PathPhysicsMotion`` to update property values.
public protocol PhysicsSolving {
    
    /**
     *  The velocity value to use in physics calculations.
     */
    var velocity: Double { get set }
    
    /**
     *  The friction value between 0.0 and 1.0, to be applied in physics calculations. Provided values outside of that range should be clamped to the closest minimum or maximum value by classes conforming to this protocol.
     */
    var friction: Double { get set }
    
    /// The restitution value from 0.0 to 1.0 which represents the elasticity of the object and used in collision calculations, with 0.0 representing a perfectly inelastic collision (in which the object does not rebound at all during a collision), and 1.0 representing a perfectly elastic collision (in which the object rebounds with no loss of velocity). Provided values outside of that range should be clamped to the closest minimum or maximum value by classes conforming to this protocol.
    var restitution: Double { get set }
    
    /// This Boolean represents whether collision detections are active in the physics simulation. If `true`, collisions will be checked using the `start` and `end` properties of each ``PropertyData`` object passed in to the ``solve(forPositions:timestamp:)`` method.
    var useCollisionDetection: Bool { get set }
    
    /// This method updates 1D positions using physics calculations.
    /// - Parameters:
    ///   - properties: An array of ``PropertyData`` objects representing the current property values are being modified by the physics calculations. Their `current` property represents the current value being modified. The `start` and `end` properties are unused, except if this object's `areCollisionsActive` property is `true`, in which case they represent collision boundaries for each property.
    ///   - timestamp: The current timestamp.
    /// - Returns: An array of updated positions in the same order as the array passed in.
    func solve(forPositions properties: [PropertyData], timestamp: TimeInterval) -> [Double]
    
    /**
     *  This method should reset the physics system to its initial velocity and clear the timestamp used to calculate the current step.
     */
    func reset()
    
    /**
     *  This method should pause the physics system, preventing any new calculations.
     */
    func pause()
    
    /**
     *  This method should resume the physics system.
     */
    func resume()
    
    /**
     *  This method should reverse the current direction of the velocity.
     */
    func reverseDirection()
    
}

/// A simple physics engine used with ``PhysicsMotion`` and ``PathPhysicsMotion`` to calculate values for motions. It primarily uses a constant ``velocity``, plus a ``friction`` component, to update movements of values over time. As of version 2.2.0 it also supports simple collision handling between two optional fixed start and end points, and a ``restitution`` value to control the value's elasticity when colliding.
public class PhysicsSystem: PhysicsSolving {
    
    /// The default timestep for the solving accumulator.
    static let TIMESTEP: Double = 0.0001

    /**
     *  The velocity value to use in physics calculations.
     */
    public var velocity: Double {
        get {
            return _velocity
        }
        set(newValue) {
            _velocity = newValue
            if (initialVelocity == 0.0 || _velocity != 0.0) {
                initialVelocity = _velocity
            }
        }
    }
    private var _velocity: Double = 0.0
    
    /**
     *  The friction value between 0.0 and 1.0, to be applied in physics calculations. Provided values outside of that range are clamped to the closest minimum or maximum value. A friction value of 0.0 is actually set internally to slightly above that in order to avoid divide by zero errors.
     */
    public var friction: Double {
        get {
            return _friction
        }
        set(newValue) {
            // if we allowed 0.0, we'd get divide by zero errors
            // besides with 0.0 friction our value would sail to the stars with a constant velocity
            _friction = (newValue > 0.0) ? newValue : 0.000001
            _friction = min(1.0, _friction)

            // pow is used here to compensate for floating point errors over time
            frictionMultiplier = pow(1 - _friction, PhysicsSystem.TIMESTEP)
        }
    }
    private var _friction: Double = 0.0
    
    /// The restitution value from 0.0 to 1.0 which represents the elasticity of the object and used in collision calculations, with 0.0 representing a perfectly inelastic collision (in which the object does not rebound at all during a collision), and 1.0 representing a perfectly elastic collision (in which the object rebounds with no loss of velocity). Provided values outside of that range are clamped to the closest minimum or maximum value. The default value is 0.75.
    public var restitution: Double {
        get {
            return _restitution
        }
        set {
            let clampedValue = max(min(newValue, 1.0), 0.0)
            _restitution = clampedValue
        }
    }
    private var _restitution: Double = 0.75
    
    /// This Boolean represents whether collision detections are active in the physics simulation. If `true`, collisions will be checked using the `start` and `end` properties of each ``PropertyData`` object passed in to the ``solve(forPositions:timestamp:)`` method. The default value is `false`.
    public var useCollisionDetection: Bool = false
    
    /// The last timestamp sent via the `solve` method.
    public internal(set) var lastTimestamp: TimeInterval = 0.0
    
    /// Boolean value representing whether the physics system is currently paused.
    public internal(set) var paused: Bool = false
    
    // MARK: Private properties
    
    /// The initial velocity value set. Used when resetting the system.
    private var initialVelocity: Double = 0.0

    /// Multiplier to apply to velocity for each time step.
    private(set) var frictionMultiplier: Double = 0.0
    
    
    // MARK: Initialization

    /// A convenience initializer.
    /// - Parameter configuration: A configuration model containing data to set up the system to provide physics calculations.
    public convenience init(configuration: PhysicsConfiguration) {
        
        self.init(velocity: configuration.velocity, friction: configuration.friction, restitution: configuration.restitution, useCollisionDetection: configuration.useCollisionDetection)
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - velocity: The velocity used to calculate new values in physics system. Any values are accepted due to the differing ranges of velocity magnitude required for various motion applications. Experiment to see what suits your needs best.
    ///   - friction: The friction used to calculate new values in the physics system. Acceptable values are 0.0 (almost no friction) to 1.0 (no movement); values outside of this range will be clamped to the nearest edge.
    ///   - restitution: The restitution value from 0.0 to 1.0 which represents the elasticity of the object and used in collision calculations, with 0.0 representing a perfectly inelastic collision (in which the object does not rebound at all during a collision), and 1.0 representing a perfectly elastic collision (in which the object rebounds with no loss of velocity).
    ///   - useCollisionDetection: Determines whether collision detections are checked and acted on with the object being moved. The default value is `false`.
    public init(velocity: Double, friction: Double, restitution: Double? = nil, useCollisionDetection: Bool? = nil) {
        
        self.velocity = velocity
        self.friction = friction
        if let restitution {
            self.restitution = restitution
        }
        
        if let useCollisionDetection {
            self.useCollisionDetection = useCollisionDetection
        }
        
        initialVelocity = velocity
    }
    
    
    // MARK: PhysicsSolving methods
    
    public func solve(forPositions positions: [PropertyData], timestamp: TimeInterval) -> [Double] {
        var timeDelta = timestamp - lastTimestamp
        timeDelta = max(0.0, timeDelta)
        timeDelta = min(0.2, timeDelta)
        var new_positions: [Double] = []
        
        if (!paused && timeDelta > 0.0) {
            
            for propertyData in positions {
                var new_position = propertyData.current
                var previous_position = propertyData.current
                
                    if (lastTimestamp > 0.0) { // only run system after first timestamp
                        var accumulator: Double = timeDelta
                        
                        let hasVelocityChanged: Bool = (_velocity != initialVelocity)
                        let areCollisionEdgesValid = (propertyData.start != propertyData.end)
                        var didCollideWithStart = false
                        var didCollideWithEnd = false
                        // handle cases where start value is bigger than end (if we're traversing the path backwards in a "forward" motion)
                        if (propertyData.end > propertyData.start) {
                            didCollideWithStart = new_position <= propertyData.start
                            didCollideWithEnd = new_position >= propertyData.end
                        } else {
                            didCollideWithStart = new_position >= propertyData.start
                            didCollideWithEnd = new_position <= propertyData.end
                        }
                        let didCollide = (useCollisionDetection && hasVelocityChanged && areCollisionEdgesValid && (didCollideWithStart || didCollideWithEnd))
                        
                        if didCollide {
                            
                            // reverse the velocity direction and apply restitution to simulate object elasticity
                            _velocity = (_velocity * -1) * restitution
                            
                            var direction: Double = 1
                            if (propertyData.end < propertyData.start) {
                                direction = -1
                            }
                            
                            // object has moved beyond collision boundary, so move it back and offset it in the other direction
                            // to avoid getting stuck
                            if (didCollideWithStart) {
                                new_position = propertyData.start + (abs(_velocity * PhysicsSystem.TIMESTEP) * direction)
                            } else if (didCollideWithEnd) {
                                new_position = propertyData.end - (abs(_velocity * PhysicsSystem.TIMESTEP) * direction)
                            }
                        }
                        
                        //print("did collide \(didCollide) AFTER :: current \(new_position) :: velocity \(_velocity) :: delta \(propertyData.delta)")
                        
                        while (accumulator >= PhysicsSystem.TIMESTEP) {
                            previous_position = new_position
                            
                            _velocity *= frictionMultiplier
                            
                            // add just the portion of current velocity that occurred during this time delta
                            new_position += (_velocity * PhysicsSystem.TIMESTEP)
                            
                            // decrement the accumulator by the fixed timestep amount
                            accumulator -= PhysicsSystem.TIMESTEP
                            
                        }
                        // interpolate the remaining time delta to get the final state of position value
                        let blending = accumulator / PhysicsSystem.TIMESTEP
                        new_position = new_position * blending + (previous_position * (1.0 - blending))
                        
                        new_positions.append(new_position)

                    }
                    lastTimestamp = timestamp
            }
        }
        
        return new_positions
    }
    
    
    public func reset() {
        _velocity = initialVelocity
        resume()
    }
    
    public func pause() {
        paused = true
    }
    
    public func resume() {
        lastTimestamp = 0.0
        paused = false
    }
    
    public func reverseDirection() {
        initialVelocity *= -1
        _velocity *= -1
    }
    
}
