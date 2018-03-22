//
//  MotionSupport.swift
//  MotionMachine
//
//  Created by Brett Walker on 4/20/16.
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
import CoreGraphics
import QuartzCore

#if os(iOS) || os(tvOS)
import UIKit
#endif

/// This struct provides utility methods for Motion classes.
public struct MotionSupport {

    // MARK: Additive utility methods
    
    // Holds weak references to all currently-tweening Motion instances which are moving an object's property
    static var motions = NSHashTable<AnyObject>.weakObjects()
    
    static var operationID: UInt = 0
    
    
    /**
     *  Registers an `Additive` motion. Any custom classes that conform to the `Additive` protocol should register their motion object.
     *
     *  - parameter additiveMotion: The `Additive` object to register.
     *  - returns: An operation ID that should be assigned to the `Additive` object's `operationID` property.
     */
    public static func register(additiveMotion motion: Additive) -> UInt {
        if !(MotionSupport.motions.contains(motion)) {
            MotionSupport.motions.add(motion)
        }
        
        return MotionSupport.currentAdditiveOperationID()
    }
    
    /**
     *  Removes an `Additive` motion from the registered list. Any custom classes that conform to the `Additive` protocol should call this method when it has completed its motion.
     *
     *  - parameter additiveMotion: The `Additive` object to remove.
     */
    public static func unregister(additiveMotion motion: Additive) {
        MotionSupport.motions.remove(motion)
    }
    
    
    /// Internal method that returns an incremented operation id, used to sort the motions set
    static func currentAdditiveOperationID() -> UInt {
        operationID += 1
        
        return operationID
    }
    
    
    /**
     *  Returns the ending value of the most recently started `Additive` motion operation for the specified object and keyPath. In order to participate in additive motion with other `Additive` objects, custom objects should use this method to set a starting value.
     *
     *  **Example Usage**
     *
        `if let last_target_value = MotionSupport.targetValue(forObject: unwrapped_object, keyPath: property.path) {
            properties[index].start = last_target_value
        }`
     *
     *  - parameters:
     *      - forObject: The object whose property value should be queried.
     *      - keyPath: The keypath of the target property, relative to the object.
     *
     *  - returns: The ending value. Returns `nil` if no `Additive` object is targeting this property.
     */
    public static func targetValue(forObject object: AnyObject, keyPath path: String) -> Double? {
        
        var target_value: Double?
        
        // create an array from the operations NSSet, using the Motion's operationID as sort key
        let motions_array = MotionSupport.motions.allObjects
        let sorted_motions = motions_array.sorted( by: { (motion1, motion2) -> Bool in
            var test: Bool = false
            if let m1 = motion1 as? Additive, let m2 = motion2 as? Additive {
                test =  m1.operationID < m2.operationID
            }
            return test
        })

        // reverse through the array and find the most recent motion operation that's modifying this object property
        for motion in sorted_motions {
            let additive = motion as! Additive
            for property: PropertyData in additive.properties {
                if ((property.target === object || property.targetObject === object) && property.path == path) {
                    target_value =  property.start + ((property.end - property.start) * additive.additiveWeighting)
                    
                    break
                }
            }
            
        }
        
        return target_value
    }
    
    
    // MARK: Utility methods
    
    public static func cast(_ number: AnyObject) -> Double? {
        var value: Double?
        
        if (number is NSNumber) {
            value = (number as! NSNumber).doubleValue
        } else if (number is Double) {
            value = number as? Double
        } else if (number is CGFloat) {
            value = Double(number as! CGFloat)
        } else if (number is Int) {
            value = Double(number as! Int)
        } else if (number is UInt) {
            value = Double(number as! UInt)
        } else if (number is Float) {
            value = Double(number as! Float)
        }
        
        return value
    }
    

    
    /// Utility method which determines whether the value is of the specified type.
    public static func matchesType(forValue value: Any, typeToMatch matchType: Any.Type) -> Bool {
        
        let does_match: Bool = type(of: value) == matchType || value is NSNumber
        
        return does_match
    }
    
    /// Utility method which determines whether the value is of the specified Objective-C type.
    public static func matchesObjCType(forValue value: NSValue, typeToMatch matchType: UnsafePointer<Int8>) -> Bool {
        var matches: Bool = false
        
        let value_type: UnsafePointer<Int8> = value.objCType
        
        matches = (strcmp(value_type, matchType)==0)
        
        return matches
    }

    /// Utility method that returns a getter method selector for a property name string.
    static func propertyGetter(forName name: String) -> Selector {
        
        let selector = NSSelectorFromString(name)
        
        return selector
        
    }
    
    /// Utility method that returns a setter method selector for a property name string.
    static func propertySetter(forName name: String) -> Selector {
        
        var selector_name = name
        let capped_first_letter = String(name[name.startIndex]).capitalized
        let replace_range: Range = selector_name.startIndex ..< selector_name.index(after: selector_name.startIndex)
        selector_name.replaceSubrange(replace_range, with: capped_first_letter)
        let setter_string = String.localizedStringWithFormat("%@%@:", "set", selector_name)
        let selector = NSSelectorFromString(setter_string)
        
        return selector
    }
    
    /**
     *  Builds and returns a `PropertyData` object if the values you supply pass one of the following tests: 1) there's a specified start value and that value is different than either the original value or the ending value, or 2) there's just an original value and that value is different than the ending value, or 3) there's no start value passed in, which will return a `PropertyData` object with only an end value. In cases 1 and 2, a `PropertyData` object with both start and end values will be returned. In the third case, a `PropertyData` object that only has an ending value will be returned. If all those tests fail, no object will be returned.
     *
     *  - parameter path: A base path to be used for the `PropertyData`'s `path` property.
     *  - parameter originalValue: An optional value representing the current value of the target object property.
     *  - parameter startValue: An optional value to be supplied to the `PropertyData`'s `start` property.
     *  - parameter endValue: A value to be supplied to the `PropertyData`'s `end` property.
     *  - returns: An optional `PropertyData` object using the supplied values.
     */
    public static func buildPropertyData(path: String, originalValue: Double?=nil, startValue: Double?, endValue: Double) -> PropertyData? {
        var data: PropertyData?
        
        if let unwrapped_start = startValue {
            if ((originalValue != nil && unwrapped_start !≈ originalValue!) || endValue !≈ unwrapped_start) {
                data = PropertyData(path: path, start: unwrapped_start, end: endValue)
            }
        } else if let unwrapped_org = originalValue {
            if (endValue !≈ unwrapped_org) {
                data = PropertyData(path: path, start: unwrapped_org, end: endValue)
            }
        } else {
            data = PropertyData(path: path, end: endValue)

        }
        
        return data
    }
    
}

// MARK: - Declarations

/// An enum representing NSValue-encoded structs supported by MotionMachine.
public enum ValueStructTypes {
    case number
    case point
    case size
    case rect
    case vector
    case affineTransform
    case transform3D
    #if os(iOS) || os(tvOS)
    case uiEdgeInsets
    case uiOffset
    #endif
    case unsupported
    
    static var valueTypes: [ValueStructTypes: NSValue] = [ValueStructTypes.number : NSNumber.init(value: 0),
                                                                  ValueStructTypes.point : NSValue(cgPoint: CGPoint.zero),
                                                                  ValueStructTypes.size : NSValue(cgSize: CGSize.zero),
                                                                  ValueStructTypes.rect : NSValue(cgRect: CGRect.zero),
                                                                  ValueStructTypes.vector : NSValue(cgVector: CGVector(dx: 0.0, dy: 0.0)),
                                                                  ValueStructTypes.affineTransform : NSValue(cgAffineTransform: CGAffineTransform.identity),
                                                                  ValueStructTypes.transform3D : NSValue.init(caTransform3D: CATransform3DIdentity)
    ]
    
    
    /**
     *  Provides a C string returned by Foundation's `objCType` method for a specific ValueStructTypes type; this represents a specific Objective-C type. This is useful for Foundation structs which can't be used with Swift's `as` type checking.
     */
    func toObjCType() -> UnsafePointer<Int8> {
        guard let type_value = ValueStructTypes.valueTypes[self]?.objCType else { return NSNumber(value: false).objCType }
        
        return type_value
    }
    
}
