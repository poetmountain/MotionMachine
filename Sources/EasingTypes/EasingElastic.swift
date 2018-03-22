//
//  EasingElastic.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/3/16.
//  Copyright © 2016-2018 Poet & Mountain, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/**
 *  EasingElastic provides easing equations that behave in an elastic fashion.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingElastic {
    
    static let M_PI2 = Double.pi * 2
    
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
