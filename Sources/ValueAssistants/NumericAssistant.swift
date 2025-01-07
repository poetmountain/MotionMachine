//
//  NumericAssistant.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// NumericAssistant provides support for top-level properties on the target object which are numeric values. This class supports all numeric types which conform to either `BinaryFloatingPoint` or `BinaryInteger`, as well as `NSNumber`.
public final class NumericAssistant<TargetType: AnyObject>: ValueAssistant {

    public var isAdditive: Bool = false
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
        }
    }
    
    public func generateProperties<StateType>(targetObject target: TargetType, state: MotionState<TargetType, StateType>) throws -> [PropertyData<TargetType>] {
        
        var properties: [PropertyData<TargetType>] = []
        
        guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, Double> else { return properties }

        let nestedObject = target[keyPath: state.keyPath]

        let startValue = state.start
        let endValue = state.end
        
        var startState: Double?
        var originalState: Double?
        
        if let startValue {
            startState = doubleValue(for: startValue)
        }
        
        if let originalValue = nestedObject as? any BinaryFloatingPoint {
            originalState = originalValue.toDouble()
        } else if let originalValue = nestedObject as? any BinaryInteger {
            originalState = originalValue.toDouble()
        } else if let originalValue = nestedObject as? NSNumber {
            originalState = originalValue.doubleValue
        }

        if let endState = doubleValue(for: endValue), let property = MotionSupport.buildPropertyData(keyPath: keyPath, originalValue: originalState, startValue: startState, endValue: endState, isAdditive: isAdditive) {
            properties.append(property)
        }
        
        return properties
        
    }
    
    @discardableResult public func update(property: PropertyData<TargetType>, newValue: Double) -> Any? {
        guard let targetObject = property.targetObject else { return nil }
        
        var newPropertyValue = newValue
        
        let currentValue = property.retrieveValue(from: targetObject)
        
        if (isAdditive) {
            if let currentValue = currentValue as? any BinaryFloatingPoint, let current = currentValue.toDouble() {
                newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
            } else if let currentValue = currentValue as? any BinaryInteger, let current = currentValue.toDouble() {
                newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
            } else if let currentValue = currentValue as? NSNumber {
                let current = currentValue.doubleValue
                newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
            }
        }
        
        property.apply(value: newPropertyValue, to: targetObject)
        
        return newPropertyValue
    }
    
    public func supports(_ object: Any) -> Bool {
        return (object is any BinaryFloatingPoint || object is any BinaryInteger || object is NSNumber)
    }
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        return false
    }
    

    func doubleValue(for value: Any) -> Double? {
        var doubleValue: Double?
        
        if let value = value as? any BinaryInteger {
            doubleValue = value.toDouble()
        } else if let value = value as? any BinaryFloatingPoint {
            doubleValue = value.toDouble()
        } else if let value = value as? NSNumber {
            doubleValue = value.doubleValue
        }
        
        return doubleValue
    }
    
}
