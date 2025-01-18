//
//  TestingSupport.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

struct Math {
    
    static func fuzzyCompare(a: Double, b: Double, errorLimit: Double=0.0001) -> Bool {
                
        let fabs_a = fabs(a)
        let fabs_b = fabs(b)
        let diff = fabs(fabs_a - fabs_b)

        if (a == b) {
            return true
        }
        
        if (a == 0.0 || b == 0.0 || diff < Double.leastNormalMagnitude) {
            // a or b is zero or both are extremely close to it
            // relative error is less meaningful here
            return diff < (Double.ulpOfOne * Double.leastNormalMagnitude)
        } else {
            return (diff <= errorLimit) // Double.ulpOfOne
        }
    }
}

extension PhysicsSystem {
    func updateLastTimestamp(timestamp: TimeInterval) {
        self.lastTimestamp = timestamp
    }
}

public extension Motion {
    func test_updatePropertyValues(properties: [PropertyData<TargetType>]) {
        updatePropertyValues(properties: properties)
    }
}
