//
//  PhysicsSystem.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/16/16.
//  Copyright © 2016-2018 Poet & Mountain, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public protocol PhysicsSolving {
    
    /**
     *  The velocity value to use in physics calculations.
     */
    var velocity: Double { get set }
    
    /**
     *  The friction value to be applied in physics calculations.
     */
    var friction: Double { get set }
    
    /**
     *  This method updates 1D positions using physics calculations.
     *
     *  - parameters:
     *      - positions: The current positions of the physics object being modeled.
     *      - currentTime: The current timestamp.
     *
     *  - returns: An array of updated positions in the same order as the array passed in.
     */
    func solve(forPositions positions: [Double], timestamp: TimeInterval) -> [Double]
    
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
     *  This method should reverse the direction of the velocity.
     */
    func reverseDirection()
    
}


public class PhysicsSystem: PhysicsSolving {
    
    // default timestep for accumulator
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
     *  The friction value to be applied in physics calculations.
     */
    public var friction: Double {
        get {
            return _friction
        }
        set(newValue) {
            // if we allowed 0.0, we'd get divide by zero errors
            // besides with 0.0 friction our value would sail to the stars with a constant velocity
            _friction = (newValue > 0.0) ? newValue : 0.000001;
            _friction = min(1.0, _friction)

            // pow is used here to compensate for floating point errors over time
            frictionMultiplier = pow(1 - _friction, PhysicsSystem.TIMESTEP)
        }
    }
    private var _friction: Double = 0.0
    
    public var timestamp: TimeInterval = 0.0
    
    // MARK: Private properties
    
    /// The initial velocity value set. Used when resetting the system.
    private var initialVelocity: Double = 0.0

    /// The last timestamp sent via the `solve` method.
    private var lastTimestamp: TimeInterval = 0.0
    
    /// Boolean value representing whether the physics system is currently paused.
    private var paused: Bool = false

    /// Multiplier to apply to velocity for each time step.
    private var frictionMultiplier: Double = 0.0
    
    
    // MARK: Initialization
    
    /**
     *  Initializer.
     *
     *  - parameters:
     *      - velocity: The velocity used to calculate new values in physics system. Any values are accepted due to the differing ranges of velocity magnitude required for various motion applications. Experiment to see what suits your needs best.
     *      - friction: The friction used to calculate new values in the physics system. Acceptable values are 0.0 (no friction) to 1.0 (no movement); values outside of this range will be clamped to the nearest edge.
     */
    public init(velocity: Double, friction: Double) {
        
        self.velocity = velocity
        self.friction = friction
        initialVelocity = velocity
    }
    
    
    // MARK: PhysicsSolving methods
    
    public func solve(forPositions positions: [Double], timestamp: TimeInterval) -> [Double] {
        var time_delta = timestamp - lastTimestamp
        
        time_delta = max(0.0, time_delta)
        time_delta = min(0.2, time_delta)
        var new_positions: [Double] = []
        
        if (!paused && time_delta > 0.0) {
            for position in positions {
                var new_position = position
                var previous_position = position
                
                    if (lastTimestamp > 0.0) { // only run system after first timestamp
                        var accumulator: Double = time_delta
                        
                        while (accumulator >= PhysicsSystem.TIMESTEP) {
                            previous_position = new_position
                            
                            _velocity *= frictionMultiplier
                            
                            // add just the portion of current velocity that occurred during this time delta
                            new_position += (_velocity * PhysicsSystem.TIMESTEP);
                            
                            // decrement the accumulator by the fixed timestep amount
                            accumulator -= PhysicsSystem.TIMESTEP;
                            
                        }
                        // interpolate the remaining time delta to get the final state of position value
                        let blending = accumulator / PhysicsSystem.TIMESTEP;
                        new_position = new_position * blending + (previous_position * (1.0 - blending));
                        
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
