//
//  PropertyStates.swift
//  MotionMachine
//
//  Created by Brett Walker on 3/17/18.
//  Copyright © 2018 Poet & Mountain, LLC. All rights reserved.
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
 * This struct represents the states of a single object property, to be used in a motion operation. Because the `start` and `end` properties can represent any value type, it is used to create `Motion` objects that conveniently handle many property value interpolations by simply passing in representations of that object at its starting and ending points.
 *
 * - remark: These state values must be of the same object type as the property located at the keypath. For instance, if the `path` property points to a CGRect object, you must provide CGRect objects for the `start` and `end` properties.
 
 **/
public struct PropertyStates {
    
    /**
     *  The keyPath of the property to be transformed. The keyPath must be a valid, KVC-compliant keyPath of `targetObject`. For your own classes, you must flag the property with `@objc` for Swift to find it.
     *
     *  - seealso: targetObject
     */
    public let path: String
    
    /**
     *  An optional starting value of the motion operation.
     *
     *  - remark: In typical cases, not specifying a starting value will result in the Motion class using the property's current value at the time the Motion is created. Note that for non-numeric properties like structs this may affect multiple values, such as the x and y properties of CGPoint.
     *  - warning: This value must be of the same object type as the property located at the specified path. For instance, if you're modifying a CGRect object, you must provide a CGRect object here.
     *
     *  - seealso: end
     */
    public var start: Any?
    
    /**
     *  The ending value of the motion operation.
     *
     *  - remark: Note that for non-numeric properties like structs this may affect multiple values, such as the x and y properties of CGPoint.
     *  - warning: This value must be of the same object type as the property located at the specified path. For instance, if you're modifying a CGRect object, you must provide a CGRect object here.
     */
    public var end: Any
    
    
    /**
     *  Initializer.
     *
     *  - parameters:
     *      - path: The keypath of the property to modify, relative to the target object provided to a Motion.
     *      - start: An optional starting value for the motion.
     *      - end: The ending value of the motion.
     */
    public init(path: String, start: Any?=nil, end: Any) {
        
        self.path = path
        
        if let unwrapped_start = start {
            self.start = unwrapped_start
        }
        
        self.end = end
    }
    
    
}
