//
//  EasingBack.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  EasingBack provides easing equations which move beyond the specified starting and ending values and snap back, as if attached to a rubber band. With modest overshoot values, this easing type can provide a more organic feel when animating visual elements like UIViews and UI.
 *
 *  - remark: See http://easings.net for visual examples.
 *  - warning: These equations produce easing values extending beyond the starting and ending values, which may produce unpredictable results for properties which have strict bounds limits.
 */
public struct EasingBack {
    
    private static let magic100 = 1.70158 * 10
    
    /// Provides an easing equation in which the value moves beyond the starting value before moving to the ending value.
    /// - Parameter overshoot: Provides a way to modify how far the starting value will be overshot. 0.0 to 1.0 is a reasonable range to use.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeIn(overshoot: Double=0.1) -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let time = elapsedTime / duration
            let overshoot = overshoot * magic100
            let easing_value = valueRange * time*time*((overshoot + 1.0)*time - overshoot) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation in which the value moves beyond the ending value before moving to the ending value.
    /// - Parameter overshoot: Provides a way to modify how far the starting value will be overshot. 0.0 to 1.0 is a reasonable range to use.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeOut(overshoot: Double=0.1) -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let time = elapsedTime / duration - 1
            let overshoot = overshoot * magic100
            let easing_value = valueRange * (time*time * ((overshoot+1.0) * time + overshoot) + 1.0) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /// Provides an easing equation in which the value moves beyond both the starting and ending values.
    /// - Parameter overshoot: Provides a way to modify how far the starting value will be overshot. 0.0 to 1.0 is a reasonable range to use.
    /// - Returns: Returns a closure containing the easing equation.
    public static func easeInOut(overshoot: Double=0.1) -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var easing_value = 0.0
            var time = elapsedTime / (duration * 0.5)
            let overshoot = (overshoot * magic100) * 1.525
            
            if (time < 1.0) {
                easing_value = (valueRange * 0.5) * (time*time*((overshoot + 1.0)*time - overshoot)) + startValue;
            } else {
                time -= 2.0;
                easing_value = (valueRange * 0.5) * (time*time*((overshoot + 1.0)*time + overshoot) + 2.0) + startValue;
            }
            
            
            return easing_value
        }
        
        return easing
    }
    
}
