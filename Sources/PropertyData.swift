//
//  PropertyData.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This class represents a single property and information about the state of its value interpolation, as well as metadata such as the KeyPath which allows a motion class to get and set these values.
@MainActor public final class PropertyData<RootType>: Identifiable {
    
    /// A unique identifier.
    public let id = UUID()
    
    /// A placeholder default value when a start value is not provided.
    public let DEFAULT_START = Double.infinity
    
    /// A function that applies a property value to the target object.
    var applicator: ((_ target: RootType, _ propertyValue: any BinaryFloatingPoint) -> Void)?
    
    /// A function that applies a property value to a SIMD type.
    var simdApplicator: ((_ target: RootType, _ propertyValue: any BinaryFloatingPoint) -> Void)?

    /// A function that applies a property value to the object specified by the ``parentPath`` KeyPath.
    var parentApplicator: ((_ target: RootType, _ property: Any) -> Void)?

    /// The starting value of the motion operation.
    internal(set) public var start: Double {
    
        didSet {
            current = start
            delegate?.didUpdate(start)
        }
    }
    
    /// The current value of the motion operation. (read-only)
    internal(set) public var current: Double = 0.0
    
    /// The ending value of the motion operation.
    internal(set) public var end: Double = 0.0
    
    /**
     *   If `true`, a Moveable class should use the object's property's current value as the starting value.
     *
     *  - remark: This is set to `true` when no value is passed into the initializer's start property.
     */
    internal(set) public var useExistingStartValue: Bool = false
    
    /// The target object whose property should be modified.
    public var targetObject: RootType?
    
    /// A string field only used internally by some ``ValueAssistant`` objects to provide support for some object types whose properties cannot be expressed directly with a `KeyPath`.
    ///
    /// > Warning: This property should not be set directly, except by your own custom ``ValueAssistant``.
    public var stringPath: String = ""
    
    /// A `KeyPath` object representing the property to be transformed.
    public var keyPath: AnyKeyPath?
    
    /// A `KeyPath` object representing the parent object of the property to be transformed. This keypath is used in cases where object properties are read-only or otherwise not directly modifiable.
    public var parentPath: AnyKeyPath?

    
    /**
     *  The property to be modified.
     */
    public var target: AnyObject?

    
    /// The change in value from the last property value update.
    internal(set) public var delta: Double = 0.0
    
    /// Boolean representing whether parent property should be replaced, instead of the target property directly.
    var replaceParentProperty: Bool = false
    
    /// Used to reset the parent object state when `resetObjectStateOnRepeat` is `true`.
    weak var startingParentProperty: AnyObject?
    
    /// A delegate that listens for property updates from this instance.
    public weak var delegate: PropertyDataDelegate?
    
 
    /// An initializer.
    /// - Parameters:
    ///   - stringPath: A string field only used internally to provide support for some object types whose properties cannot be expressed directly with a `KeyPath`.
    ///   - start: The starting property value for a motion operation.
    ///   - end: The ending property value for a motion operation.
    public convenience init<ParentType>(stringPath: String?, parentPath: KeyPath<RootType, ParentType>? = nil, start: Double? = nil, end: Double) {
        
        self.init(keyPath: nil, stringPath: stringPath, start: start, end: end)

        
        self.parentPath = parentPath
            
        parentApplicator = { (target, property) in
            if let keyPath = parentPath as? ReferenceWritableKeyPath<RootType, ParentType>, let property = property as? ParentType {
                target[keyPath: keyPath] = property
            }
            
        }
        
        if parentPath != nil {
            replaceParentProperty = true
        }

    }
    
    
    /// An initializer.
    /// - Parameters:
    ///   - keyPath: A `KeyPath` used to point to the property this object holds value states for.
    ///   - stringPath: A string field only used internally to provide support for some object types whose properties cannot be expressed directly with a `KeyPath`.
    ///   - start: The starting property value for a motion operation.
    ///   - end: The ending property value for a motion operation.
    private init<PropertyType: BinaryFloatingPoint>(keyPath: KeyPath<RootType, PropertyType>? = nil, stringPath: String? = nil, start: PropertyType? = nil, end: PropertyType? = nil) {
        
        applicator = { (target, propertyValue) in
            let convertedValue = PropertyType(propertyValue)
            if let keyPath = keyPath as? ReferenceWritableKeyPath<RootType, PropertyType> {
                target[keyPath: keyPath] = convertedValue
            }
            
        }
        
        self.keyPath = keyPath
        
        // optional start param allows a Motion to use an object property's current value as the starting value
        // instead of explicitly specifying it
        if let start {
            self.start = Double(start)
        } else {
            useExistingStartValue = true
            self.start = 0.0
        }
        
        if let end {
            self.end = Double(end)
        } else {
            self.end = self.start
        }
        
        if let stringPath {
            self.stringPath = stringPath
        }
    }
    
    /// An initializer.
    /// - Parameters:
    ///   - keyPath: A `KeyPath` used to point to the property this object holds value states for.
    ///   - stringPath: A string field only used internally to provide support for some object types whose properties cannot be expressed directly with a `KeyPath`.
    ///   - start: The starting property value for a motion operation.
    ///   - end: The ending property value for a motion operation.
    private init<PropertyType: BinaryInteger>(keyPath: KeyPath<RootType, PropertyType>? = nil, stringPath: String? = nil, start: PropertyType? = nil, end: PropertyType? = nil) {
        
        applicator = { (target, propertyValue) in
            let convertedValue = PropertyType(propertyValue)
            if let keyPath = keyPath as? ReferenceWritableKeyPath<RootType, PropertyType> {
                target[keyPath: keyPath] = convertedValue
            }
            
        }
        
        self.keyPath = keyPath
        
        // optional start param allows a Motion to use an object property's current value as the starting value
        // instead of explicitly specifying it
        if let start {
            self.start = Double(start)
        } else {
            useExistingStartValue = true
            self.start = 0.0
        }
        
        if let end {
            self.end = Double(end)
        } else {
            self.end = self.start
        }
        
        if let stringPath {
            self.stringPath = stringPath
        }
    }

    /// An initializer specifically for `SIMD` object types.
    /// - Parameters:
    ///   - keyPath: A `KeyPath` used to point to the property this object holds value states for.
    ///   - parentPath: A `KeyPath` used to point to the parent `SIMD` object of the property targeted by this object.
    ///   - stringPath: A string field only used internally to provide support for some object types whose properties cannot be expressed directly with a `KeyPath`.
    ///   - scalarStart: The starting `SIMDScalar` property value for a motion operation.
    ///   - scalarEnd: The ending `SIMDScalar` property value for a motion operation.
    private init<PropertyType: SIMDScalar, ParentType: SIMD>(keyPath: KeyPath<RootType, PropertyType>? = nil, parentPath: KeyPath<RootType, ParentType>? = nil, stringPath: String? = nil, scalarStart: PropertyType? = nil, scalarEnd: PropertyType? = nil) {
        
        simdApplicator = { (target, propertyValue) in
            
            if let scalarEnd, let keyPath = keyPath as? ReferenceWritableKeyPath<RootType, PropertyType>, let property = propertyValue.toScalar(type: scalarEnd) {
                target[keyPath: keyPath] = property
            }
            
        }
        
        self.keyPath = keyPath
        self.parentPath = parentPath
        
        parentApplicator = { (target, property) in
            if let keyPath = parentPath as? ReferenceWritableKeyPath<RootType, ParentType>, let property = property as? ParentType {
                target[keyPath: keyPath] = property
            }
            
        }
        
        // optional start param allows a Motion to use an object property's current value as the starting value
        // instead of explicitly specifying it
        if let start = scalarStart as? any BinaryFloatingPoint {
            self.start = Double(start)
        } else if let start = scalarStart as? any BinaryInteger {
            self.start = Double(start)
        } else {
            useExistingStartValue = true
            self.start = 0.0
        }
        
        if let end = scalarEnd as? any BinaryFloatingPoint {
            self.end = Double(end)
        } else if let end = scalarEnd as? any BinaryInteger {
            self.end = Double(end)
        } else {
            self.end = self.start
        }
        
        if let stringPath {
            self.stringPath = stringPath
        }
    }

    /// A convenience initializer for `BinaryFloatingPoint` values that includes a parent keypath.
    /// - Parameters:
    ///   - keyPath: A `KeyPath` used to point to the property this object holds value states for.
    ///   - parentPath: A `KeyPath` used to point to the parent object of the property targeted by this object.
    ///   - start: The starting `BinaryFloatingPoint` property value for a motion operation.
    ///   - end: The ending `BinaryFloatingPoint` property value for a motion operation.
    public convenience init<PropertyType: BinaryFloatingPoint, ParentType>(keyPath: KeyPath<RootType, PropertyType>, parentPath: KeyPath<RootType, ParentType>? = nil, start: PropertyType? = nil, end: PropertyType) {
        
        self.init(keyPath: keyPath, stringPath: nil, start: start, end: end)

        self.parentPath = parentPath ?? keyPath
            
        parentApplicator = { (target, property) in
            if let keyPath = parentPath as? ReferenceWritableKeyPath<RootType, ParentType>, let property = property as? ParentType {
                target[keyPath: keyPath] = property
            }
            
        }
        
        if parentPath != nil {
            replaceParentProperty = true
        }
    }
    
    /// A convenience initializer for `BinaryFloatingPoint` values.
    /// - Parameters:
    ///   - keyPath: A `KeyPath` used to point to the property this object holds value states for.
    ///   - start: The starting `BinaryFloatingPoint` property value for a motion operation.
    ///   - end: The ending `BinaryFloatingPoint` property value for a motion operation.
    public convenience init<PropertyType: BinaryFloatingPoint>(keyPath: KeyPath<RootType, PropertyType>, start: PropertyType? = nil, end: PropertyType? = nil) {
        self.init(keyPath: keyPath, stringPath: nil, start: start, end: end)

    }
    
    /// A convenience initializer specifically for `SIMD` object types and including a parent keypath pointing to the `SIMD` object.
    /// - Parameters:
    ///   - keyPath: A `KeyPath` used to point to the property this object holds value states for.
    ///   - parentPath: A `KeyPath` used to point to the parent `SIMD` object of the property targeted by this object.
    ///   - scalarStart: The starting `SIMDScalar` property value for a motion operation.
    ///   - scalarEnd: The ending `SIMDScalar` property value for a motion operation.
    convenience init<PropertyType: SIMDScalar, ParentType: SIMD>(keyPath: KeyPath<RootType, PropertyType>, parentPath: KeyPath<RootType, ParentType>? = nil, scalarStart: PropertyType? = nil, scalarEnd: PropertyType? = nil) {
        self.init(keyPath: keyPath, parentPath: parentPath, stringPath: nil, scalarStart: scalarStart, scalarEnd: scalarEnd)

    }
    
    /// A convenience initializer for `BinaryInteger` values that includes a parent keypath.
    /// - Parameters:
    ///   - keyPath: A `KeyPath` used to point to the property this object holds value states for.
    ///   - parentPath: A `KeyPath` used to point to the parent object of the property targeted by this object.
    ///   - start: The starting `BinaryInteger` property value for a motion operation.
    ///   - end: The ending `BinaryInteger` property value for a motion operation.
    public convenience init<PropertyType: BinaryInteger, ParentType>(keyPath: KeyPath<RootType, PropertyType>, parentPath: KeyPath<RootType, ParentType>? = nil, start: PropertyType? = nil, end: PropertyType? = nil) {
        
        self.init(keyPath: keyPath, stringPath: nil, start: start, end: end)

        if let parentPath {
            self.parentPath = parentPath
            
            parentApplicator = { (target, property) in
                if let keyPath = parentPath as? ReferenceWritableKeyPath<RootType, PropertyType>, let property = property as? PropertyType {
                    target[keyPath: keyPath] = property
                }
                
            }
            
            replaceParentProperty = true
        }

    }
    
    /// A convenience initializer for `BinaryInteger` values.
    /// - Parameters:
    ///   - keyPath: A `KeyPath` used to point to the property this object holds value states for.
    ///   - start: The starting `BinaryInteger` property value for a motion operation.
    ///   - end: The ending `BinaryInteger` property value for a motion operation.
    public convenience init<PropertyType: BinaryInteger>(keyPath: KeyPath<RootType, PropertyType>, start: PropertyType? = nil, end: PropertyType? = nil) {
        self.init(keyPath: keyPath, stringPath: nil, start: start, end: end)

    }
    
    
    /// Applies the provided value to the object referenced by the ``keyPath`` property.
    /// - Parameters:
    ///   - value: The value to set on the object.
    ///   - object: The root object for the keypath, used to apply the value to.
    public func apply(value: any BinaryFloatingPoint, to: RootType) {
        applicator?(to, value)
    }
    
    /// Applies the provided value to the `SIMD` type object referenced by the ``keyPath`` property.
    /// - Parameters:
    ///   - value: The value to set on the `SIMD` object.
    ///   - object: The root object for the keypath, used to apply the value to.
    /// - Returns: The resultant object's value, if one was set.
    public func applyToSIMD(value: any BinaryFloatingPoint, to object: RootType) {
        if let simdApplicator {
            simdApplicator(object, value)
        } else {
            applicator?(object, value)
        }
    }
    
    
    /// Applies the provided value to the parent object referenced by the ``parentPath`` keypath.
    /// - Parameters:
    ///   - value: The value to set on the parent object.
    ///   - object: The root object for the ``parentPath`` keypath, used to apply the value to.
    public func applyToParent(value: Any, to object: RootType) {
        parentApplicator?(object, value)
    }

    /// Retrieves a value from the provided object using the ``keyPath`` property.
    /// - Parameter target: The target object to retrieve a value from.
    /// - Returns: The result of the keypath retrieval, if one was found.
    public func retrieveValue(from target: RootType) -> Any? {
        if let keyPath {
            return target[keyPath: keyPath]
        } else {
            return nil
        }
    }
    
    /// Retrieves a value from the provided object using the ``parentPath`` property.
    /// - Parameter target: The target object to retrieve a value from.
    /// - Returns: The result of the keypath retrieval, if one was found.
    public func retrieveParentValue(from target: RootType) -> Any? {
        if let parentPath {
            return target[keyPath: parentPath]
        } else {
            return nil
        }
    }
    
}

extension PropertyData: Equatable {
    nonisolated public static func == (lhs: PropertyData, rhs: PropertyData) -> Bool {
        return (lhs.id == rhs.id)
    }
}

extension PropertyData: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
