//
//  EasingElastic.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingElastic provides easing equations that behave in an elastic fashion.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingElastic {
    
    static let M_PI2 = Double.pi * 2
    
    /// Provides an easing equation that behaves in an elastic fashion, applied to the beginning of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var time = elapsedTime
            var easing_value = 0.0

            if (time ≈≈ 0.0) {
                return startValue
            }
            
            time /= duration
            if (time ≈≈ 1.0) {
                easing_value = startValue + valueRange
            } else {
                let amplitude = valueRange
                let period = duration * 0.3
                let overshoot = (period / M_PI2) * asin(valueRange / amplitude)
                
                time -= 1
                easing_value = -(amplitude*pow(2, 10*time) * sin( (time*duration-overshoot) * M_PI2/period)) + startValue
            }
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation that behaves in an elastic fashion, applied to the end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var time = elapsedTime
            var easing_value = 0.0
            if (time ≈≈ 0.0) {
                return startValue
            }
            
            time /= duration
            if (time ≈≈ 1.0) {
                easing_value = startValue + valueRange
            } else {
                let amplitude = valueRange
                let period = duration * 0.3
                let overshoot = (period / M_PI2) * asin(valueRange / amplitude)
                
                easing_value = amplitude*pow(2,-10*time) * sin( (time*duration-overshoot) * M_PI2/period ) + valueRange + startValue
            }
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation that behaves in an elastic fashion, applied to the beginning and end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeInOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var time = elapsedTime
            var easing_value = 0.0
            
            if (time ≈≈ 0.0) {
                return startValue
            }
            
            time /= duration * 0.5
            if (time ≈≈ 2.0) {
                easing_value = startValue + valueRange
            } else {
                let amplitude = valueRange
                let period = duration * (0.3 * 1.5)
                let overshoot = (period / M_PI2) * asin(valueRange / amplitude)
                
                if (time < 1) {
                    time -= 1
                    easing_value = -0.5 * (amplitude*pow(2, 10*time) * sin( (time*duration-overshoot) * M_PI2/period )) + startValue
                } else {
                    
                    time -= 1
                    easing_value = amplitude*pow(2, -10*time) * sin( (time*duration-overshoot) * M_PI2/period ) * 0.5
                    easing_value += valueRange + startValue
                }
            }
            
            
            return easing_value
        }
        
        return easing
    }
    
}
