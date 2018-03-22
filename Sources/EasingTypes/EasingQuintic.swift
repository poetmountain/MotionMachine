//
//  EasingQuintic.swift
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
 *  EasingQuintic provides quintic easing equations.
 *
 *  - remark: See http://easings.net for visual examples.
 */
public struct EasingQuintic {
    
    public static func easeIn() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let time = elapsedTime / duration
            let easing_value = valueRange * (time*time*time*time*time) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    public static func easeOut() -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var time = elapsedTime / duration
            time -= 1
            let easing_value = valueRange * (time*time*time*time*time + 1) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
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
