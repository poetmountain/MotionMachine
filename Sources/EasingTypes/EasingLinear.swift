//
//  EasingLinear.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingLinear provides a linear easing equation, which increments by a constant value over time.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingLinear {
    
    /// Provides a purely linear easing equation.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeNone() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value = valueRange * (elapsedTime / duration) + startValue
            
            return easing_value
        }
        
        return easing
    }
        
    
}
