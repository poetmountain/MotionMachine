//
//  ValueAssistant.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol defines methods and properties that must be adopted for any value assistant.
@MainActor public protocol ValueAssistant<TargetType> {
    
    associatedtype TargetType: AnyObject
    
    /**
     *  This method generates and returns an array of ``PropertyData`` instances based on the provided ``MotionState`` object.
     *
     *  - Parameters:
     *      - targetObject:   The root object of the key path which targets the state object.
     *      - state: Represents an object state and associated metadata from which this method should build ``PropertyData`` objects.
     *
     *  - returns: An array of ``PropertyData`` instances representing the state values of the provided object.
     */
    func generateProperties<StateType>(targetObject target: TargetType, state: MotionState<TargetType, StateType>) throws -> [PropertyData<TargetType>]
    

    /**
     *  This method updates an object property based on the supplied value.
     *
     *  - parameters:
     *      - property: The ``PropertyData`` instance whose property should be updated.
     *      - newValue: The new value to be applied to the object property.
     *
     *  - returns: An updated version of the property value, if the object property was found and is supported.
     */
    @discardableResult func update(property: PropertyData<TargetType>, newValue: Double) -> Any?
    
    /**
     *  Verifies whether this class can update the specified object type.
     *
     *  - parameters:
     *      - object: An object to verify support for.
     *
     *  - returns: A Boolean value representing whether the object is supported by this class.
     */
    func supports(_ object: Any) -> Bool
    
    /**
     *  Verifies whether this object can accept a keyPath.
     *
     *  - parameters:
     *      - object: An object to verify support for.
     *
     *  - returns: A Boolean value representing whether the object is supported by this class.
     */
    func acceptsKeypath(_ object: AnyObject) -> Bool
    
    
    /**
     *  A Boolean which determines whether to update a value using additive updates. When the value is `true`, values passed in to `updateValue` are added to the existing value instead of replacing it. The default is `false`.
     *
     *  - seealso: additiveWeighting
     */
    var isAdditive: Bool { get set }
    
    /**
     *  A weighting between 0.0 and 1.0 which is applied to a value updates when the ValueAssistant is updating additively. The higher the weighting amount, the more that a new value will be applied in the `updateValue` method. A value of 1.0 will apply the full value to the existing value, and a value of 0.0 will apply nothing to it.
     *
     *  - note: This value only has an effect when `additive` is set to `true`. The default value is 1.0.
     *  - seealso: additive
     */
    var additiveWeighting: Double { get set }
    
}


// utility methods for ValueAssistant
public extension ValueAssistant {
    
    /// Applies a new `BinaryFloatingPoint` value to an existing one and returns it, either adding to it if ``additive`` mode is active, or simply replacing it.
    /// - Parameters:
    ///   - value: The value to modify.
    ///   - newValue: The value used to modify the existing value.
    /// - Returns: The updated value.
    func applyAdditiveTo<ValueType: BinaryFloatingPoint>(value: ValueType, newValue: ValueType) -> ValueType {
        var updatedValue = value
        
        if (isAdditive) {
            updatedValue += (newValue * ValueType(additiveWeighting))
        } else {
            updatedValue = newValue
        }
        
        return updatedValue
    }
    
    /// Applies a new `BinaryInteger` value to an existing value and returns it, either adding to it if ``additive`` mode is active, or simply replacing it.
    /// - Parameters:
    ///   - value: The value to modify.
    ///   - newValue: The value used to modify the existing value.
    /// - Returns: The updated value.
    func applyAdditiveTo<ValueType: BinaryInteger>(value: inout ValueType, newValue: ValueType) -> ValueType {
        var updatedValue = value

        if (isAdditive) {
            updatedValue += (newValue * ValueType(additiveWeighting))
        } else {
            updatedValue = newValue
        }
        
        return updatedValue
    }
    
    /// Returns the last component in a period-delimited String path.
    /// - Parameter path: The String path to search.
    /// - Returns: The path component, if one was found.
    func lastComponent(forPath path: String) -> String? {
        return path.components(separatedBy: ".").last
    }
    
    /// Returns the last two components in a period-delimited String path.
    /// - Parameter path: The String path to search.
    /// - Returns: An array of path components, if any were found.
    func lastTwoComponents(forPath path: String) -> [String]? {
        let components = path.components(separatedBy: ".")
        var val: [String]?
        if (components.count > 1) {
            let strings = components[components.count-2...components.count-1]
            val = Array(strings)
        }
        
        return val
    }
    
}
