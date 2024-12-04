//
//  PropertyData.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Provides delegate updates when property values change.
@MainActor public protocol PropertyDataDelegate: AnyObject {
    
    /// Called when the `start` property of a PropertyData instance is updated.
    func didUpdate(_ startValue: Double)
}

/// This struct represents a single property or object and information about the state of its value interpolation, as well as metadata which allows a Motion instance to get and set these values.
@MainActor public struct PropertyData {
    
    /**
     *  The starting value of the motion operation.
     *
     *  - remark: Note that for non-numeric properties like structs this may affect multiple values, such as the x and y properties of CGPoint.
     *
     *  - seealso: current, end
     */
    internal(set) public var start: Double {
    
        didSet {
            current = start
            delegate?.didUpdate(start)
        }
    }
    
    /**
     *  The current value of the motion operation. (read-only)
     *
     *  - remark: Note that for non-numeric properties like structs this may affect multiple values, such as the x and y properties of CGPoint.
     *
     *  - seealso: start, end
     */
    internal(set) public var current: Double = 0.0
    
    /**
     *  The ending value of the motion operation.
     *
     *  - remark: Note that for non-numeric properties like structs this may affect multiple values, such as the x and y properties of CGPoint.
     */
    internal(set) public var end: Double = 0.0
    /**
     *   If `true`, a Moveable class should use the object's property's current value as the starting value.
     *
     *  - remark: This is set to `true` when no value is passed into the initializer's start property.
     */
    internal(set) public var useExistingStartValue: Bool = false
    
    /**
     *  The target object whose property should be modified.
     *
     *  - remark: If the object passed in to the Motion instance is an NSValue instance, this value will be nil. In that case, the `target` property will contain the current NSValue.
     *  - seealso: target
     *
     */
    public var targetObject: NSObject?
    
    /**
     *  The keyPath of the property to be transformed. The keyPath must be a valid, KVC-compliant keyPath of `targetObject`. For your own classes, you must flag the property with `@objc` for Swift to find it.
     *
     *  - seealso: targetObject
     */
    public var path: String = ""

    /**
     *  The property to be modified.
     */
    public var target: AnyObject?

    
    /// Cache of the getter selector for the property.
    var getter: Selector?
    
    /// Cache of the setter selector for the property.
    var setter: Selector?
    
    /// The change in value from the last property value update.
    internal(set) public var delta: Double = 0.0
    
    /// Key path for the parent of the target property. Used when `targetProperty` is a numeric value.
    var parentKeyPath: String = ""
    
    /// Boolean representing whether parent property should be replaced, instead of the target property directly.
    var replaceParentProperty: Bool = false
    
    /// Used to reset the parent object state when `resetObjectStateOnRepeat` is `true`.
    weak var startingParentProperty: AnyObject?
    
    /// A delegate that listens for property updates from this instance.
    public weak var delegate: PropertyDataDelegate?
    
    /**
     *  Initializer.
     *
     *  - parameters:
     *      - path: The keypath of the property to modify, relative to the `targetObject`.
     *      - start: An optional starting value for the motion. If none is provided, `useExistingStartValue` will be set to `true`.
     *      - end: The ending value of the motion.
     */
    public init(path: String?, start: Double? = nil, end: Double? = nil) {
        if let unwrapped_path = path {
            self.path = unwrapped_path
        }
        
        // optional start param allows a Motion to use an object property's current value as the starting value
        // instead of explicitly specifying it
        if let start_param = start {
            self.start = start_param
        } else {
            useExistingStartValue = true
            self.start = 0.0
        }
        
        if let end {
            self.end = end
        } else {
            self.end = self.start
        }
        
    }

    
    /// A convenience initializer.
    /// - Parameters:
    ///   - _path: The keypath of the property to modify, relative to the `targetObject`.
    ///   - _end: The ending value of the motion.
    public init(_  _path: String?, _ _end: Double) {
        self.init(path: _path, start: nil, end: _end)
    }
    
    /// A convenience initializer.
    /// - Parameters:
    ///   - _path: The keypath of the property to modify, relative to the `targetObject`.
    public init(_ path: String?) {
        self.init(path: path, start: nil, end: nil)
    }
    
    /// A convenience initializer.
    /// - Parameters:
    ///   - _end: The ending value of the motion.
    public init(end: Double) {
        self.init(path: nil, start: nil, end: end)
    }
    
    
}
