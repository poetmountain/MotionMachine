//
//  ValueAssistantGroup.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// The `ValueAssistantGroup` class enables multiple `ValueAssistant` objects to be attached to a single motion class.
public final class ValueAssistantGroup<TargetType: AnyObject>: ValueAssistant {
    
    public var isAdditive: Bool = false {
        didSet {
            for index in 0 ..< assistants.count {
                var assistant = assistants[index]
                assistant.isAdditive = isAdditive
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
        self.isAdditive = isAdditive
        for index in 0 ..< assistants.count {
            assistants[index].isAdditive = isAdditive
        }
    }
    
    /// An array of ``ValueAssistant`` objects that this group manages.
    private(set) public var assistants: [any ValueAssistant<TargetType>] = []
    
    /**
     *  Initializer.
     *
     *  - parameters:
     *      - assistants: An optional array of `ValueAssistant` objects to which the ValueAssistantGroup should delegate `ValueAssistant` method calls.
     */
    public init(assistants: [any ValueAssistant<TargetType>]? = []) {
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
    public func add(_ assistant: any ValueAssistant<TargetType>) {
        var assist = assistant

        assist.isAdditive = isAdditive
        assist.additiveWeighting = additiveWeighting
        assistants.append(assist)
    }
    
    
    // MARK: ValueAssistant methods
    
    public func generateProperties<StateType>(targetObject target: TargetType, state: MotionState<TargetType, StateType>) throws -> [PropertyData<TargetType>] {
        
        var properties: [PropertyData<TargetType>] = []
        
        for assistant in assistants {
            if (assistant.supports(state.end as AnyObject)) {
                if let generated = try? assistant.generateProperties(targetObject: target, state: state) {
                    properties += generated
                    break
                }
            }
            
        }
        
        return properties
    }
    
    
    
    public func update(properties: [PropertyData<TargetType>: Double], targetObject: TargetType) {
        
        if let parentObject = properties.keys.first?.target {
            // we have a special or supported object whose property is being changed
            for assistant in assistants {
                if (assistant.supports(parentObject)) {
                    assistant.update(properties: properties, targetObject: targetObject)
                    break
                }
            }
                    
        } else if let propertyValue = properties.keys.first?.end {
            // we have no base object path, so find assistant that directly supports target property value
            for assistant in assistants {
                if (assistant.supports(propertyValue)) {
                    assistant.update(properties: properties, targetObject: targetObject)
                    break
                }
            }
        }
        
        
    }
    
    
    public func supports(_ object: Any) -> Bool {
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
