//
//  EasingBounce.swift
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
 *  EasingBounce provides easing equations that have successively smaller value peaks, like a bouncing ball.
 *
 *  - remark: See http://easings.net for visual examples.
 *
 */
public struct EasingBounce {
    
    static let magic100 = 1.70158 * 10
    
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {

            let easing_closure = EasingBounce.easeOut()
            let time = duration - elapsedTime
            let easing_value = valueRange - easing_closure(time, 0.0, valueRange, duration) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
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
