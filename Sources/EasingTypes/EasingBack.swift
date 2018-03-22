//
//  EasingBack.swift
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
 *  EasingBack provides easing equations which move beyond the specified starting and ending values and snap back, as if attached to a rubber band. With modest overshoot values, this easing type can provide a more organic feel when animating visual elements like UIViews and UI.
 *
 *  - remark: See http://easings.net for visual examples.
 *  - warning: These equations produce easing values extending beyond the starting and ending values, which may produce unpredictable results for properties which have strict bounds limits.
 */
public struct EasingBack {
    
    private static let magic100 = 1.70158 * 10
    
    /**
     *  This function provides an equation in which the value moves beyond the starting value before moving to the ending value.
     *
     *  - parameter overshoot: Provides a way to modify how far the starting value will be overshot. 0.0 to 1.0 is a reasonable range to use.
     */
    public static func easeIn(overshoot over: Double=0.1) -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let time = elapsedTime / duration
            let overshoot = over * magic100
            let easing_value = valueRange * time*time*((overshoot + 1.0)*time - overshoot) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /**
     *  This function provides an equation in which the value moves beyond the ending value before moving to the ending value.
     *
     *  - parameter overshoot: Provides a way to modify how far the ending value will be overshot. 0.0 to 1.0 is a reasonable range to use.
     */
    public static func easeOut(overshoot over: Double=0.1) -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            let time = elapsedTime / duration - 1
            let overshoot = over * magic100
            let easing_value = valueRange * (time*time * ((overshoot+1.0) * time + overshoot) + 1.0) + startValue
            
            return easing_value
        }
        
        return easing
    }
    
    /**
     *  This function provides an equation in which the value moves beyond both the starting and ending values.
     *
     *  - parameter overshoot: Provides a way to modify how far the starting and ending values will be overshot. 0.0 to 1.0 is a reasonable range to use.
     */
    public static func easeInOut(overshoot over: Double=0.1) -> EasingUpdateClosure {
        
        func easing (_ elapsedTime: TimeInterval, startValue: Double, valueRange: Double, duration: TimeInterval) -> Double {
            var easing_value = 0.0
            var time = elapsedTime / (duration * 0.5)
            let overshoot = (over * magic100) * 1.525
            
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
