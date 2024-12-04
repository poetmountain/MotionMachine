//
//  EasingBounce.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingBounce provides easing equations that produces successively smaller value peaks, like a bouncing ball.
 *
 *  - remark: See http://easings.net for visual examples.
 *
 */
public struct EasingBounce {
    
    static let magic100 = 1.70158 * 10
    
    /// Provides an easing equation that produces successively smaller value peaks, like a bouncing ball. The effect is applied to the beginning of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {

            let easing_closure = EasingBounce.easeOut()
            let time = duration - elapsedTime
            let easing_value = valueRange - easing_closure(time, 0.0, valueRange, duration) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation that produces successively smaller value peaks, like a bouncing ball. The effect is applied to the end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var time = elapsedTime / duration
            let easing_value: Double
            if (time < (1/2.75)) {
                easing_value = valueRange * (7.5625 * time*time) + startValue;
            } else if (time < (2 / 2.75)) {
                time -= (1.5 / 2.75);
                easing_value = valueRange * (7.5625 * time*time + 0.75) + startValue;
            } else if (time < (2.5/2.75)) {
                time -= (2.25/2.75);
                easing_value = valueRange * (7.5625 * time*time + 0.9375) + startValue;
            } else {
                time -= (2.625/2.75);
                easing_value = valueRange * (7.5625 * time*time + 0.984375) + startValue;
            }
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation that produces successively smaller value peaks, like a bouncing ball. The effect is applied to the beginning and end of a motion.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeInOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value: Double
            let easing_closure = EasingBounce.easeOut()

            if (elapsedTime < (duration * 0.5)) {
                easing_value = easing_closure((elapsedTime*2), 0, valueRange, duration) * 0.5 + startValue;
            } else {
                easing_value = easing_closure((elapsedTime*2-duration), 0, valueRange, duration) * 0.5 + (valueRange*0.5) + startValue;
            }
            
            
            return easing_value
        }
        
        return easing
    }
    
}
