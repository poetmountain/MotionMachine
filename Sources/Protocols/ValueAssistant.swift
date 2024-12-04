//
//  ValueAssistant.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol defines methods and properties that must be adopted for any value assistant.
@MainActor public protocol ValueAssistant {
        
    /**
     *  This method returns an array of PropertyData instances based on the values of the provided object.
     *
     *  - Parameters:
     *      - targetObject:   A supported object to generate PropertyData instances from.
     *      - propertyStates: A model object representing property states for this value transformation.
     *
     *  - returns: An array of PropertyData instances representing the values of the provided object.
     */
    func generateProperties(targetObject target: AnyObject, propertyStates: PropertyStates) throws -> [PropertyData]
    
    /**
     *  This method replaces an element of an AnyObject subclass by assigning new values.
     *
     *  - parameters:
     *      - object:   The object that should be updated.
     *      - newValues:    A dictionary of keyPaths and associated values of the object to be updated.
     *
     *  - returns: An updated version of the object, if the object property was found and is supported.
     */
    func updateValue(inObject object: Any, newValues: Dictionary<String, Double>) -> NSObject?
    
    /**
     *  This method retrieves the current value of the target object being moved (as opposed to the saved value within a `PropertyData` instance).
     *
     *  - parameters:
     *      - property: The `PropertyData` instance whose target object's value should be queried.
     *
     *  - returns: The retrieved value of the target object.
     */
    func retrieveCurrentObjectValue(forProperty property: PropertyData) -> Double?
    
    /**
     *  This method retrieves the value of a supported AnyObject type.
     *
     *  - parameters:
     *      - object:   The object whose property value should be retrieved.
     *      - path:    The key path of the object property to be updated. If `object` is an NSValue instance, the path should correspond to an internal struct value path. E.g. a NSValue instance containing a NSRect might have a path property of "origin.x".
     *
     *  - returns: The retrieved value, if the object property was found and is supported.
     */
    func retrieveValue(inObject object: Any, keyPath path: String) throws -> Double?
    
    /**
     *  This method calculates a new value an object property.
     *
     *  - parameters:
     *      - property:   The PropertyData instance whose property should be calculated.
     *      - newValue: The new value to be applied to the object property.
     *
     *  - returns: An updated version of the object, if the object property was found and is supported.
     */
    func calculateValue(forProperty property: PropertyData, newValue: Double) -> NSObject?

    
    /**
     *  Verifies whether this class can update the specified object type.
     *
     *  - parameters:
     *      - object: An object to verify support for.
     *
     *  - returns: A Boolean value representing whether the object is supported by this class.
     */
    func supports(_ object: AnyObject) -> Bool
    
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
    var additive: Bool { get set }
    
    /**
     *  A weighting between 0.0 and 1.0 which is applied to a value updates when the ValueAssistant is updating additively. The higher the weighting amount, the more that a new value will be applied in the `updateValue` method. A value of 1.0 will apply the full value to the existing value, and a value of 0.0 will apply nothing to it.
     *
     *  - note: This value only has an effect when `additive` is set to `true`. The default value is 1.0.
     *  - seealso: additive
     */
    var additiveWeighting: Double { get set }
    
}
