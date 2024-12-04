//
//  PhysicsSystemTests.swift
//  MotionMachineTests
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor final class PhysicsSystemTests: XCTestCase {

    func test_solve() {
        let velocity = 1.0
        let friction = 0.1
        let system = PhysicsSystem(velocity: velocity, friction: friction)
        let property = PropertyData(path: "", start: 0.0, end: 1.0)
        let timeElapsed: TimeInterval = 0.1
        // d = (v*t) + 1/2at^2
        let expectedValue = property.start + (velocity * timeElapsed) + (0.5 * -friction * pow(timeElapsed,2))
        let startTimestamp = CFAbsoluteTimeGetCurrent()
        
        system.updateLastTimestamp(timestamp: startTimestamp - TimeInterval(timeElapsed))
                
        guard let value = system.solve(forPositions: [property], timestamp: startTimestamp).first else {
            XCTFail()
            return
        }
        print("value \(value) :: expected \(expectedValue)")
        XCTAssertEqual(value, expectedValue, accuracy: 0.001)
        
    }

    func test_object_should_collide_with_max_value_if_collisions_active() {
        let velocity = 10.0
        let friction = 0.01
        let restitution = 0.5
        let collisionValue = 0.8
        let system = PhysicsSystem(velocity: velocity, friction: friction, restitution: restitution, useCollisionDetection: true)
        var property = PropertyData(path: "", start: 0.0, end: collisionValue)
        let timeElapsed: TimeInterval = 0.05
        let startTimestamp = CFAbsoluteTimeGetCurrent()
        
        system.updateLastTimestamp(timestamp: startTimestamp - TimeInterval(timeElapsed*4))

        if let firstValue = system.solve(forPositions: [property], timestamp: startTimestamp - TimeInterval(timeElapsed*2)).first {
            let delta = abs(firstValue) - abs(property.current)
            property.delta = delta
            property.current = firstValue
        }
        
        guard let value = system.solve(forPositions: [property], timestamp: startTimestamp).first else {
            XCTFail()
            return
        }
        
        // object should hit collision area and bounce in opposite direction
        XCTAssertLessThan(value, collisionValue)
        
        // restitution should halve the velocity and bounce in opposite direction
        let expectedVelocity = (-velocity * restitution)
        XCTAssertEqual(system.velocity, expectedVelocity, accuracy: 0.1)
        
    }
    
    func test_object_should_collide_with_reversed_max_value_if_collisions_active() {
        let velocity = -10.0
        let friction = 0.01
        let restitution = 0.5
        let collisionValue = 0.8
        let system = PhysicsSystem(velocity: velocity, friction: friction, restitution: restitution, useCollisionDetection: true)
        var property = PropertyData(path: "", start: collisionValue, end: 0.0)
        let timeElapsed: TimeInterval = 0.05
        let startTimestamp = CFAbsoluteTimeGetCurrent()
        
        system.updateLastTimestamp(timestamp: startTimestamp - TimeInterval(timeElapsed*4))

        if let firstValue = system.solve(forPositions: [property], timestamp: startTimestamp - TimeInterval(timeElapsed*2)).first {
            let delta = abs(firstValue) - abs(property.current)
            property.delta = delta
            property.current = firstValue
        }
        
        guard let value = system.solve(forPositions: [property], timestamp: startTimestamp).first else {
            XCTFail()
            return
        }
        
        // object should hit collision area and bounce in opposite direction
        XCTAssertLessThan(value, collisionValue)
        
        // restitution should halve the velocity and bounce in opposite direction
        let expectedVelocity = (-velocity * restitution)
        XCTAssertEqual(system.velocity, expectedVelocity, accuracy: 0.1)
        
    }
    
    func test_object_should_collide_with_min_value_if_collisions_active() {
        let velocity = -10.0
        let friction = 0.01
        let restitution = 0.5
        let collisionValue = 0.2
        let system = PhysicsSystem(velocity: velocity, friction: friction, restitution: restitution, useCollisionDetection: true)
        var property = PropertyData(path: "", start: collisionValue, end: 1.0)
        property.current = 0.9
        let timeElapsed: TimeInterval = 0.05
        let startTimestamp = CFAbsoluteTimeGetCurrent()
        
        system.updateLastTimestamp(timestamp: startTimestamp - TimeInterval(timeElapsed*4))

        if let firstValue = system.solve(forPositions: [property], timestamp: startTimestamp - TimeInterval(timeElapsed*2)).first {
            let delta = abs(firstValue) - abs(property.current)
            property.delta = delta
            property.current = firstValue
        }
        
        guard let value = system.solve(forPositions: [property], timestamp: startTimestamp).first else {
            XCTFail()
            return
        }
        
        // object should hit collision area and bounce in opposite direction
        XCTAssertGreaterThan(value, collisionValue)
        
        // restitution should halve the velocity and bounce in opposite direction
        let expectedVelocity = (-velocity * restitution)
        XCTAssertEqual(system.velocity, expectedVelocity, accuracy: 0.1)
        
    }
}
