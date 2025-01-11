//
//  MotionSupport.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if canImport(QuartzCore)
import QuartzCore
#endif

#if os(iOS) || os(tvOS)
import UIKit
#endif


/// This struct provides utility methods for Motion classes.
@MainActor public struct MotionSupport {

    // MARK: Additive utility methods
    
    /// Holds weak references to all currently active Additive-conforming instances
    static var motions: [WeakAdditiveContainer] = []
    
    /// An incrementing counter which represents the most recently-created Motion operation. For internal use only.
    static var operationID: UInt = 0
    
    /**
     *  Registers an `Additive` motion. Any custom classes that conform to the `Additive` protocol should register their motion object.
     *
     *  - parameter additiveMotion: The `Additive` object to register.
     *  - returns: An operation ID that should be assigned to the `Additive` object's `operationID` property.
     */
    public static func register(additiveMotion motion: any Additive) -> UInt {
        let weakReference = WeakAdditiveContainer(value: motion, identifier: motion.id)
        MotionSupport.motions.append(weakReference)
        
        return MotionSupport.currentAdditiveOperationID()
    }
    
    /**
     *  Removes an `Additive` motion from the registered list. Any custom classes that conform to the `Additive` protocol should call this method when it has completed its motion.
     *
     *  - parameter additiveMotion: The `Additive` object to remove.
     */
    public static func unregister(additiveMotion motion: any Additive) {
        if let index = MotionSupport.motions.firstIndex(where:  { $0.object?.id == motion.id }) {
            MotionSupport.motions.remove(at: index)
        }
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
        `if let lastTargetValue = MotionSupport.targetValue(forObject: targetObject, targetProperty: property, requestingID: self.operationID) {
            properties[index].start = lastTargetValue
        }`
     *
     *  - parameters:
     *      - forObject: The object whose property value should be queried.
     *      - keyPath: The keypath of the target property, relative to the object.
     *
     *  - returns: The ending value. Returns `nil` if no `Additive` object is targeting this property.
     */
    public static func targetValue<TargetType: AnyObject>(forObject object: TargetType, targetProperty: PropertyData<TargetType>, requestingID: UInt) -> Double? {
        
        var targetValue: Double?
        
        // create a sorted array from the operations Array, using the Motion's operationID as sort key
        let sortedMotions = motions.compactMap { $0.object }.sorted( by: { (model1, model2) -> Bool in
            let test: Bool = model1.operationID < model2.operationID
            
            return test
        })

        // find the most recent motion operation that's modifying this object property
        for motion in sortedMotions {
            if let motion = motion as? any Moveable, motion.operationID == requestingID {
                continue
            }
            if let additive = motion as? any Additive<TargetType> {
                for property in additive.properties {
                    if ((property.target === object || property.targetObject === object) && ((targetProperty.keyPath != nil && property.keyPath == targetProperty.keyPath) || (!targetProperty.stringPath.isEmpty && property.stringPath == targetProperty.stringPath))) {
                        targetValue = property.start + ((property.end - property.start) * additive.additiveWeighting)

                        break
                    }
                }
            }
        }

        
        return targetValue
    }
    
    
    // MARK: Utility methods
        
    /// Builds and returns a `PropertyData` object using the supplied values.
    ///
    /// A `PropertyData` object will be created if the values you supply pass one of the following tests:
    /// 1) there's a specified start value and that value is different than either the original value or the ending value, or
    /// 2) there's just an original value and that value is different than the ending value, or
    /// 3) there's no start value passed in, which will return a `PropertyData` object with only an end value. In cases 1 and 2, a `PropertyData` object with both start and end values will be returned. In the third case, a `PropertyData` object that only has an ending value will be returned. If all those tests fail, no object will be returned.
    ///
    /// - Parameters:
    ///   - keyPath: A base `KeyPath` to be used for the `PropertyData`'s `keyPath` property.
    ///   - originalValue: An optional value representing the current value of the target object property.
    ///   - startValue: An optional value to be supplied to the `PropertyData`'s `start` property.
    ///   - endValue: A value to be supplied to the `PropertyData`'s `end` property.
    ///   - isAdditive: Denotes whether this ``PropertyData`` will be used with an additive Motion. If `true`, optimizations that prevent the ``PropertyData`` from being built will not occur as it would result in incorrect additive calculations.
    ///  - Returns: An optional `PropertyData` object using the supplied values.
    ///
    public static func buildPropertyData<TargetType, PropertyType: BinaryFloatingPoint>(keyPath: KeyPath<TargetType, PropertyType>, originalValue: PropertyType?=nil, startValue: PropertyType?, endValue: PropertyType, isAdditive: Bool = false) -> PropertyData<TargetType>? {
        var data: PropertyData<TargetType>?
        
        if let startValue {
            if let originalValue, (startValue !≈ originalValue || isAdditive) {
                data = PropertyData<TargetType>(keyPath: keyPath, start: startValue, end: endValue)
            } else if (endValue !≈ startValue || isAdditive) {
                data = PropertyData<TargetType>(keyPath: keyPath, start: startValue, end: endValue)

            }

        } else if let originalValue {
            if (endValue !≈ originalValue || isAdditive) {
                data = PropertyData<TargetType>(keyPath: keyPath, start: originalValue, end: endValue)
            }
        } else {
            data = PropertyData<TargetType>(keyPath: keyPath, end: endValue)

        }
        
        return data
    }
    
    /// Builds and returns a `PropertyData` object using the supplied values.
    ///
    /// A `PropertyData` object will be created if the values you supply pass one of the following tests:
    /// 1) there's a specified start value and that value is different than either the original value or the ending value, or
    /// 2) there's just an original value and that value is different than the ending value, or
    /// 3) there's no start value passed in, which will return a `PropertyData` object with only an end value. In cases 1 and 2, a `PropertyData` object with both start and end values will be returned. In the third case, a `PropertyData` object that only has an ending value will be returned. If all those tests fail, no object will be returned.
    ///
    /// - Parameters:
    ///   - keyPath: A base `KeyPath` to be used for the `PropertyData`'s `keyPath` property.
    ///   - parentPath: A `KeyPath` referencing the parent object to the value being updated.
    ///   - originalValue: An optional value representing the current value of the target object property.
    ///   - startValue: An optional value to be supplied to the `PropertyData`'s `start` property.
    ///   - endValue: A value to be supplied to the `PropertyData`'s `end` property.
    ///   - isAdditive: Denotes whether this ``PropertyData`` will be used with an additive Motion. If `true`, optimizations that prevent the ``PropertyData`` from being built will not occur as it would result in incorrect additive calculations.
    ///  - Returns: An optional `PropertyData` object using the supplied values.
    ///
    public static func buildPropertyData<TargetType, PropertyType: BinaryFloatingPoint, ParentType>(keyPath: KeyPath<TargetType, PropertyType>, parentPath: KeyPath<TargetType, ParentType>? = nil, originalValue: PropertyType? = nil, startValue: PropertyType?, endValue: PropertyType, isAdditive: Bool = false) -> PropertyData<TargetType>? {
        var data: PropertyData<TargetType>?
        
        if let startValue {
            if let originalValue, (startValue !≈ originalValue || isAdditive) {
                data = PropertyData<TargetType>(keyPath: keyPath, parentPath: parentPath, start: startValue, end: endValue)
            } else if (endValue !≈ startValue || isAdditive) {
                data = PropertyData<TargetType>(keyPath: keyPath, parentPath: parentPath, start: startValue, end: endValue)

            }

        } else if let originalValue {
            if (endValue !≈ originalValue || isAdditive) {
                data = PropertyData<TargetType>(keyPath: keyPath, parentPath: parentPath, start: originalValue, end: endValue)
            }
        } else {
            data = PropertyData<TargetType>(keyPath: keyPath, end: endValue)

        }
        
        return data
    }
}

// MARK: - Declarations

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS) || os(watchOS)
/// An enum representing value types supported by MotionMachine.
@MainActor public enum ValueStructTypes {
    
    /// Represents a `CGPoint` type.
    case point
    
    /// Represents a `CGSize` type.
    case size
    
    /// Represents a `CGRect` type.
    case rect
    
    /// Represents a `CGVector` type.
    case vector
    
    /// Represents a `CGAffineTransform` type.
    case affineTransform
    
    #if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
    /// Represents a `CATransform3D` type.
    case transform3D
    #endif
    
    #if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
    /// Represents a `UIEdgeInsets` type.
    case uiEdgeInsets
    
    /// Represents a `UIOffset` type.
    case uiOffset
    #endif
    
    /// Represents an unsupported type.
    case unsupported
#if os(iOS) || os(tvOS) || os(visionOS)
    static var valueTypes: [ValueStructTypes: Any] = [ValueStructTypes.point : CGPoint.zero,
                                                      ValueStructTypes.size : CGSize.zero,
                                                      ValueStructTypes.rect : CGRect.zero,
                                                      ValueStructTypes.vector : CGVector(dx: 0.0, dy: 0.0),
                                                      ValueStructTypes.affineTransform : CGAffineTransform.identity,
                                                      ValueStructTypes.transform3D : CATransform3DIdentity
    ]
#endif

#if os(watchOS)
    static var valueTypes: [ValueStructTypes: Any] = [ValueStructTypes.point : CGPoint.zero,
                                                      ValueStructTypes.size : CGSize.zero,
                                                      ValueStructTypes.rect : CGRect.zero,
                                                      ValueStructTypes.vector : CGVector(dx: 0.0, dy: 0.0),
                                                      ValueStructTypes.affineTransform : CGAffineTransform.identity
    ]
#endif
    
}
#endif
