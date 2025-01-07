//
//  MotionState.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This struct represents the states of a single object to be used in a motion operation, used to create ``PropertyData`` objects for each object property. Because the ``start`` and ``end`` properties can represent any value type, it is used by ``ValueAssistant`` classes to internally generate ``PropertyData`` objects for each property value of the object. As such, it is a convenient way to set up many property value interpolations for an object by simply passing in representations of that object at its starting and ending points.
///
/// > Note: These state values must be of the same object type as the property located at the `keyPath`. For instance, if the ``keyPath`` property points to a CGRect object, you must provide CGRect objects for the ``start`` and ``end`` properties.
public struct MotionState<RootClass, PropertyType> {
    
    /// An optional starting state for the motion operation, used to generate ``PropertyData`` objects for each object property. If no value is supplied, the existing object's state will be used.
    ///
    /// > Note: Depending on the state object being used for property generation, multiple ``PropertyData`` objects may result, such as the x and y properties of CGPoint. ``ValueAssistant`` classes make a best attempt at ignoring the generation of properties whose values do not change between the starting and ending states.
    public var start: PropertyType?
    
    /// An ending state for the motion operation, used to generate ``PropertyData`` objects for each object property. If no value is supplied, the existing object's state will be used.
    ///
    /// > Note: Depending on the state object being used for property generation, multiple ``PropertyData`` objects may result, such as the x and y properties of CGPoint. ``ValueAssistant`` classes make a best attempt at ignoring the generation of properties whose values do not change between the starting and ending states.
    public let end: PropertyType
    
    /// A `KeyPath` object representing the object to be transformed.
    public let keyPath: AnyKeyPath

    
    /// The initializer.
    /// - Parameters:
    ///   - keyPath: A KeyPath which points to an object of the same type as the provided states.
    ///   - start: A state representing the starting property values of the motion operation.
    ///   - end: A stte representing the ending property values of the motion operation.
    public init(keyPath: KeyPath<RootClass, PropertyType>, start: PropertyType? = nil, end: PropertyType) {

        self.keyPath = keyPath
        
        if let start {
            self.start = start
        }
        
        self.end = end
        
    }
    
    /// Retrieves a value from the provided object using the ``keyPath`` property.
    /// - Parameter target: The target object to retrieve a value from.
    /// - Returns: The result of the keypath retrieval, if one was found.
    public func retrieveValue(from target: RootClass) -> (Any)? {
        return target[keyPath: keyPath]

    }

    
}
