//
//  EasingSine.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingSine provides easing equations based on sine calculations.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingSine {
    
    /// Provides an easing equation based on sine, applied to the beginning of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value = -valueRange * cos((elapsedTime / duration) * MotionUtils.MM_PI_2) + valueRange + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation based on sine, applied to the end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value = valueRange * sin((elapsedTime / duration) * MotionUtils.MM_PI_2) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation based on sine, applied to the beginning and end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeInOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var easing_value = (-valueRange * 0.5) * (cos(Double.pi * (elapsedTime / duration)) - 1)
            easing_value += startValue
            
            return easing_value
        }
        
        return easing
    }
    
}
