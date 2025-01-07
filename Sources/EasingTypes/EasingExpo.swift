//
//  EasingExpo.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingExpo provides exponential easing equations.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingExpo {
    
    /// Provides an exponential easing equation, applied to the beginning of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value = (elapsedTime == 0) ? startValue : valueRange * pow(2, 10 * (elapsedTime/duration - 1)) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an exponential easing equation, applied to the end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var easing_value = 0.0
            if (elapsedTime == duration) {
                easing_value = startValue+valueRange
            } else {
                easing_value = valueRange * (-pow(2, -10 * elapsedTime/duration) + 1) + startValue
            }
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an exponential easing equation, applied to the beginning and end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeInOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var easing_value = 0.0
            var time = elapsedTime
            
            if (time == 0) {
                easing_value = startValue
            
            } else if (time == duration) {
                easing_value = startValue + valueRange
            
            } else {
                time /= (duration * 0.5)
                if (time < 1) {
                    easing_value = (valueRange * 0.5) * pow(2, 10 * (time - 1)) + startValue;
                    
                } else {
                    time -= 1;
                    easing_value = (valueRange * 0.5) * (-pow(2, -10 * time) + 2) + startValue;
                }
            }
            
            
            return easing_value
        }
        
        return easing
    }
    
}
