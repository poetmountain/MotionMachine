//
//  EasingExpo.swift
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
 *  EasingExpo provides exponential easing equations.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingExpo {
    
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let easing_value = (elapsedTime == 0) ? startValue : valueRange * pow(2, 10 * (elapsedTime/duration - 1)) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
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
