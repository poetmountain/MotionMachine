//
//  EasingCircular.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingCircular provides easing equations based on circle calculations.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingCircular {
    
    /// Provides an easing equation based on circle calculations, applied to the beginning of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let time = elapsedTime / duration
            let easing_value = -valueRange * (sqrt(1 - time*time) - 1) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation based on circle calculations, applied to the end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var time = elapsedTime / duration
            time -= 1
            let easing_value = valueRange * sqrt(1 - time*time) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation based on circle calculations, applied to the beginning and end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeInOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var easing_value = 0.0
            var time = elapsedTime / (duration * 0.5)
            
            if (time < 1) {
                easing_value = (-valueRange * 0.5) * (sqrt(1 - time*time) - 1) + startValue;
            } else {
                time -= 2;
                easing_value = (valueRange * 0.5) * (sqrt(1 - time*time) + 1) + startValue;
            }
            
            
            return easing_value
        }
        
        return easing
    }
    
}
