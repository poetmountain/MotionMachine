//
//  ValueAssistantGroup.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// The `ValueAssistantGroup` class enables multiple `ValueAssistant` objects to be attached to a single motion class.
public final class ValueAssistantGroup : ValueAssistant {
    
    public var additive: Bool = false {
        didSet {
            for index in 0 ..< assistants.count {
                var assistant = assistants[index]
                assistant.additive = additive
                assistants[index] = assistant
            }
        }
    }
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
            
            for index in 0 ..< assistants.count {
                assistants[index].additiveWeighting = additiveWeighting
            }
        }
    }
    
    
    /// Updates the `additive` state of all child ``ValueAssistant`` objects in this group.
    /// - Parameter isAdditive: The new `additive` state to assign.
    public func updateAdditive(isAdditive: Bool) {
        self.additive = isAdditive
        for index in 0 ..< assistants.count {
            assistants[index].additive = additive
        }
    }
    
    /// An array of ``ValueAssistant`` objects that this group manages.
    private(set) public var assistants: [ValueAssistant] = []
    
    /**
     *  Initializer.
     *
     *  - parameters:
     *      - assistants: An optional array of `ValueAssistant` objects to which the ValueAssistantGroup should delegate `ValueAssistant` method calls.
     */
    public init(assistants: [ValueAssistant]? = []) {
        if let unwrapped_assists = assistants {
            self.assistants = unwrapped_assists
        }
        
    }
    

    // MARK: Public Methods
    
    /**
     *  Adds a `ValueAssistant` to the group.
     *
     *  - parameter assistant: A `ValueAssistant` object.
     *  - note: The added assistant will be assigned the same values for `additive` and `additiveWeighting` as this group's values.
     *  - seealso: additive, additiveWeighting
     */
    public func add(_ assistant: ValueAssistant) {
        var assist = assistant

        assist.additive = additive
        assist.additiveWeighting = additiveWeighting
        assistants.append(assist)
    }
    
    
    // MARK: ValueAssistant methods
    
    public func generateProperties(targetObject target: AnyObject, propertyStates: PropertyStates) throws -> [PropertyData] {
        
        var properties: [PropertyData] = []
        
        for assistant in assistants {
            if (assistant.supports(propertyStates.end as AnyObject)) {
                if let generated = try? assistant.generateProperties(targetObject: target, propertyStates: propertyStates) {
                    properties += generated
                    break
                }
            }
            
        }
        
        return properties
    }
    
    
    public func retrieveValue(inObject object: Any, keyPath path: String) -> Double? {
        var retrievedValue: Double?
        
        for assistant in assistants {
            if (assistant.supports(object as AnyObject)) {
                if let retrieved = try? assistant.retrieveValue(inObject: object, keyPath: path) {
                    retrievedValue = retrieved
                    break
                }
            }
        }
        
        if (retrievedValue == nil), let pathValue = (object as AnyObject).value(forKeyPath: path) {
            
            // cast numeric value to a double
            retrievedValue = MotionSupport.cast(pathValue as AnyObject)
            
            let components = path.components(separatedBy: ".")
            
            if let first_component = components.first {
                let child_object = (object as AnyObject).value(forKey: first_component)
                if let unwrapped_child = child_object as AnyObject? {
                    if (acceptsKeypath(unwrapped_child)) {
                        
                    }
                }
            }
        }
        
        return retrievedValue
    }
    
    
    public func updateValue(inObject object: Any, newValues: Dictionary<String, Double>) -> NSObject? {
        
        guard newValues.count > 0 else { return nil }
        
        var new_parent_value:NSObject?
        
        for assistant in assistants {
            if (assistant.supports(object as AnyObject)) {
                new_parent_value = assistant.updateValue(inObject: object, newValues: newValues)
                break
            }
        }
     
        return new_parent_value
    }
    
    
    public func retrieveCurrentObjectValue(forProperty property: PropertyData) -> Double? {
        
        guard let unwrapped_target = property.target else { return nil }

        var current_value: Double?
        
        for assistant in assistants {
            if (assistant.supports(unwrapped_target)) {
                current_value = assistant.retrieveCurrentObjectValue(forProperty: property)
                break
            }
        }

    
        return current_value
        
    }
    
    
    
    public func calculateValue(forProperty property: PropertyData, newValue: Double) -> NSObject? {
        
        guard let unwrapped_target = property.target else { return nil }
        
        var new_prop: NSObject? = NSNumber.init(value: property.current)
        
        // this code path will execute if the object passed in was an NSValue
        // as such we must replace the value object directly
        if ((property.targetObject == nil || property.targetObject === unwrapped_target) && unwrapped_target is NSValue) {
            for assistant in assistants {
                if (assistant.supports(unwrapped_target)) {
                    new_prop = assistant.calculateValue(forProperty: property, newValue: newValue)
                    if (new_prop != nil) { break }
                }
            }
            
            return new_prop
        }
        
        
        if (property.targetObject != nil) {
            // we have a normal object whose property is being changed
            for assistant in assistants {
                if (assistant.supports(unwrapped_target)) {
                    new_prop = assistant.calculateValue(forProperty: property, newValue: newValue)
                    break
                }
            }
            
            return new_prop
        
        } else {
            
            // we have no base object as it's not a NSValue, so find assistant that supports target
            // this will typically be a UIColor
            for assistant in assistants {
                if (assistant.supports(unwrapped_target)) {
                    new_prop = assistant.calculateValue(forProperty: property, newValue: newValue)
                    break
                }
            }
        }
        
        
        return new_prop
    }
    
    
    
    public func supports(_ object: AnyObject) -> Bool {
        var is_supported: Bool = false
        
        for assistant in assistants {
            is_supported = assistant.supports(object)
            
            if (is_supported) { break }
        }
        
        return is_supported
    }
    
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        var accepts = true
        
        for assistant in assistants {
            if (!assistant.acceptsKeypath(object) && assistant.supports(object)) {
                accepts = false
                break
            }
        }
        return accepts
    }
    
}
