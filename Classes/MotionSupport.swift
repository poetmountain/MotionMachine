//
//  MotionSupport.swift
//  MotionMachine
//
//  Created by Brett Walker on 4/20/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
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
    static var motions = NSHashTable.weakObjectsHashTable()
    
    static var operationID: UInt = 0
    
    
    /**
     *  Registers an `Additive` motion. Any custom classes that conform to the `Additive` protocol should register their motion object.
     *
     *  - parameter additiveMotion: The `Additive` object to register.
     *  - returns: An operation ID that should be assigned to the `Additive` object's `operationID` property.
     */
    public static func register(additiveMotion motion: Additive) -> UInt {
        if !(MotionSupport.motions.containsObject(motion)) {
            MotionSupport.motions.addObject(motion)
        }
        
        return MotionSupport.currentAdditiveOperationID()
    }
    
    /**
     *  Removes an `Additive` motion from the registered list. Any custom classes that conform to the `Additive` protocol should call this method when it has completed its motion.
     *
     *  - parameter additiveMotion: The `Additive` object to remove.
     */
    public static func unregister(additiveMotion motion: Additive) {
        MotionSupport.motions.removeObject(motion)
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
        let sorted_motions = motions_array.sort( { (motion1, motion2) -> Bool in
            var test: Bool = false
            if let m1 = motion1 as? Additive, m2 = motion2 as? Additive {
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
    
    public static func cast(number: AnyObject) -> Double? {
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
        
        let does_match: Bool = value.dynamicType == matchType || value is NSNumber
        
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
        let capped_first_letter = String(name[name.startIndex]).capitalizedString
        let replace_range: Range = selector_name.startIndex ..< selector_name.startIndex.successor()
        selector_name.replaceRange(replace_range, with: capped_first_letter)
        let setter_string = String.localizedStringWithFormat("%@%@:", "set", selector_name)
        let selector = NSSelectorFromString(setter_string)
        
        return selector
    }
    
}

// MARK: - Declarations

/// An enum representing NSValue-encoded structs supported by MotionMachine.
public enum ValueStructTypes {
    case Number
    case Point
    case Size
    case Rect
    case Vector
    case AffineTransform
    case Transform3D
    #if os(iOS) || os(tvOS)
    case UIEdgeInsets
    case UIOffset
    #endif
    case Unsupported
    
    static var valueTypes: [ValueStructTypes: UnsafePointer<Int8>] = [ValueStructTypes.Number : NSNumber.init(int: 0).objCType,
                                                                  ValueStructTypes.Point : NSValue(CGPoint: CGPointZero).objCType,
                                                                  ValueStructTypes.Size : NSValue(CGSize: CGSizeZero).objCType,
                                                                  ValueStructTypes.Rect : NSValue(CGRect: CGRectZero).objCType,
                                                                  ValueStructTypes.Vector : NSValue(CGVector: CGVectorMake(0.0, 0.0)).objCType,
                                                                  ValueStructTypes.AffineTransform : NSValue(CGAffineTransform: CGAffineTransformIdentity).objCType,
                                                                  ValueStructTypes.Transform3D : NSValue.init(CATransform3D: CATransform3DIdentity).objCType
    ]
    
    
    /**
     *  Provides a C string returned by Foundation's `objCType` method for a specific ValueStructTypes type; this represents a specific Objective-C type. This is useful for Foundation structs which can't be used with Swift's `as` type checking.
     */
    func toObjCType() -> UnsafePointer<Int8> {
        guard let type_value = ValueStructTypes.valueTypes[self] else { return NSNumber(bool: false).objCType }
        
        return type_value
    }
    
}
