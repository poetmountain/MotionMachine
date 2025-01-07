//
//  PropertyCollection.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

/// This protocol represents an object that holds a collection of `PropertyData` objects, such as a ``Motion`` class.
@MainActor public protocol PropertyCollection<TargetType>: AnyObject {
    
    associatedtype TargetType: AnyObject
    
    /// A collection of `PropertyData` instances.
    var properties: [PropertyData<TargetType>] { get }
    
    /// An object conforming to the `ValueAssistant` protocol which acts as an interface for retrieving and updating value types.
    var valueAssistant: any ValueAssistant<TargetType> { get set }
}


public extension PropertyCollection {
    
    /**
     *  Builds `PropertyData` objects for the supplied MotionState objects.
     *
     *  - parameter forObject: The object to be modified, and the base object for the paths of the `MotionState` objects.
     *  - parameter states: An Array of `MotionState` objects that define how the `PropertyData` objects are constructed.
     *  - remark: This method is used internally by the initializer when the `states` convenience method is used, but you can also call it directly to build an array of `PropertyData` objects.
     *  - returns: An Array of `PropertyData` objects.
     */
    func buildPropertyData<each StateType>(forObject targetObject: Any, states: repeat MotionState<TargetType, each StateType>) -> [PropertyData<TargetType>] {
        var data: [PropertyData<TargetType>] = []
                        
        for state in repeat each states {
            do {
                if let targetObject = targetObject as? TargetType {
                    
                    let generated = try valueAssistant.generateProperties(targetObject: targetObject, state: state)
                    data.append(contentsOf: generated)
                }
                
            } catch ValueAssistantError.typeRequirement(let valueType) {
                ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)
                
            } catch {
                // any other errors
            }

        }
        
        return data
    }
    
    
    func setupProperty(property: PropertyData<TargetType>, for targetObject: TargetType) {
                
        property.targetObject = targetObject
        if let parentValue = property.retrieveParentValue(from: targetObject) {
            property.target = parentValue as AnyObject
        }
        
        if let startValue = property.retrieveValue(from: targetObject) {
            if property.useExistingStartValue {
                if let startValue = startValue as? any BinaryFloatingPoint, let convertedValue = startValue.toDouble() {
                    property.start = convertedValue
                    if property.target == nil {
                        property.target = convertedValue as AnyObject
                    }
                } else if let startValue = startValue as? any BinaryInteger, let convertedValue = startValue.toDouble() {
                    property.start = convertedValue
                    if property.target == nil {
                        property.target = convertedValue as AnyObject
                    }
                } else {
                    property.target = startValue as AnyObject
                }
                
            } else {
                property.target = startValue as AnyObject
            }
        }
    }
    
}
