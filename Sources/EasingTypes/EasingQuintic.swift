//
//  EasingQuintic.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingQuintic provides quintic easing equations.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingQuintic {
    
    /// Provides a quintic easing equation applied to the beginning of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let time = elapsedTime / duration
            let easing_value = valueRange * (time*time*time*time*time) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides a quintic easing equation applied to the end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var time = elapsedTime / duration
            time -= 1
            let easing_value = valueRange * (time*time*time*time*time + 1) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides a quintic easing equation applied to the beginning and end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeInOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var time = elapsedTime / (duration * 0.5)
            
            var easing_value = 0.0
            if (time < 1) {
                easing_value = (valueRange * 0.5) * time*time*time*time*time + startValue
                
            } else {
                time -= 2
                easing_value = (valueRange * 0.5) * (time*time*time*time*time + 2) + startValue
            }
            
            return easing_value
        }
        
        return easing
    }
    
}
