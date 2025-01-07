//
//  EasingQuadratic.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingQuadratic provides quadratic easing equations.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingQuadratic {
    
    /// Provides a quadratic easing equation applied to the beginning of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value = valueRange * (elapsedTime*elapsedTime) / (duration*duration) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides a quadratic easing equation applied to the end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value = -valueRange * ((elapsedTime*elapsedTime) / (duration*duration)) + (2*valueRange * (elapsedTime/duration)) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides a quadratic easing equation applied to the beginning and end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeInOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value: Double
            if (elapsedTime < duration*0.5) {
                easing_value = 2*valueRange * (elapsedTime*elapsedTime) / (duration*duration) + startValue
            } else {
                let time = elapsedTime - (duration*0.5)
                easing_value = -2*valueRange * (time*time)/(duration*duration) + 2*valueRange*(time/duration) + (valueRange*0.5) + startValue
            }
            
            return easing_value
        }
        
        return easing
    }
    
}
