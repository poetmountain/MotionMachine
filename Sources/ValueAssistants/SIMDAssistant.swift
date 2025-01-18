//
//  SIMDAssistant.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// SIMDAssistant provides support for all current `SIMD` types.
public final class SIMDAssistant<TargetType: AnyObject>: ValueAssistant {

    public var isAdditive: Bool = false
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
        }
    }
    
    
    public func generateProperties<StateType>(targetObject target: TargetType, state: MotionState<TargetType, StateType>) throws -> [PropertyData<TargetType>] {
        var properties: [PropertyData<TargetType>] = []

        guard let endValue = state.end as? any SIMD else { throw ValueAssistantError.typeRequirement("SIMD") }
        let endType = SIMDAssistant.simdType(for: endValue)
        
        if let value = endValue as? any SIMD<Float> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)

        } else if let value = endValue as? any SIMD<Double> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)

        } else if let value = endValue as? any SIMD<Float16> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)

        } else if let value = endValue as? any SIMD<Int> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        } else if let value = endValue as? any SIMD<Int16> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        } else if let value = endValue as? any SIMD<Int32> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        } else if let value = endValue as? any SIMD<Int64> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        } else if let value = endValue as? any SIMD<Int8> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)

            
        } else if let value = endValue as? any SIMD<UInt> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        } else if let value = endValue as? any SIMD<UInt8> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        } else if let value = endValue as? any SIMD<UInt16> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        } else if let value = endValue as? any SIMD<UInt32> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        } else if let value = endValue as? any SIMD<UInt64> {
            properties = propertyDatas(for: state, target: target, endState: value, simdType: endType)
        }

        return properties
    }

    func propertyDatas<ScalarType: SIMDScalar, StateType>(for state: MotionState<TargetType, StateType>, target: TargetType, endState: any SIMD<ScalarType>, simdType: SIMDType) -> [PropertyData<TargetType>] {
        
        var properties: [PropertyData<TargetType>] = []
        
        let nestedObject = target[keyPath: state.keyPath]
        
        guard let endState = state.end as? any SIMD else { return [] }

        var startValue: Any?
        if let statesStart = state.start {
            startValue = statesStart
            
        }
        
        switch simdType {
            case .simd2:
                
                guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, SIMD2<ScalarType>> else { return properties }
                guard let originalSIMD = nestedObject as? SIMD2<ScalarType>, let endState = endState as? SIMD2<ScalarType> else { return properties }
                
                var startStateX: ScalarType?
                var startStateY: ScalarType?

                if let startState = startValue as? SIMD2<ScalarType> {
                    startStateX = startState.x
                    startStateY = startState.y
                }
                
                let xPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.x)
                if let propX = buildPropertyData(keyPath: xPath, parentPath: keyPath, originalValue: originalSIMD.x, startValue: startStateX, endValue: endState.x, isAdditive: isAdditive) {
                    properties.append(propX)
                }
                
                let yPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.y)
                if let propY = buildPropertyData(keyPath: yPath, parentPath: keyPath, originalValue: originalSIMD.y, startValue: startStateY, endValue: endState.y, isAdditive: isAdditive) {
                    properties.append(propY)
                }
                
               
            case .simd3:
                
                guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, SIMD3<ScalarType>> else { return properties }
                guard let originalSIMD = nestedObject as? SIMD3<ScalarType>, let endState = endState as? SIMD3<ScalarType> else { return properties }
                
                var startStateX: ScalarType?
                var startStateY: ScalarType?
                var startStateZ: ScalarType?
                
                if let startState = startValue as? SIMD3<ScalarType> {
                    startStateX = startState.x
                    startStateY = startState.y
                    startStateZ = startState.z
                }
                
                let xPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.x)
                if let propX = buildPropertyData(keyPath: xPath, parentPath: keyPath, originalValue: originalSIMD.x, startValue: startStateX, endValue: endState.x, isAdditive: isAdditive) {
                    properties.append(propX)
                }
                
                let yPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.y)
                if let propY = buildPropertyData(keyPath: yPath, parentPath: keyPath, originalValue: originalSIMD.y, startValue: startStateY, endValue: endState.y, isAdditive: isAdditive) {
                    properties.append(propY)
                }
                
                let zPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.z)
                if let propZ = buildPropertyData(keyPath: zPath, parentPath: keyPath, originalValue: originalSIMD.z, startValue: startStateZ, endValue: endState.z, isAdditive: isAdditive) {
                    properties.append(propZ)
                }

               
            case .simd4:

                guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, SIMD4<ScalarType>> else { return properties }
                guard let originalSIMD = nestedObject as? SIMD4<ScalarType>, let endState = endState as? SIMD4<ScalarType> else { return properties }
                
                var startStateX: ScalarType?
                var startStateY: ScalarType?
                var startStateZ: ScalarType?
                var startStateW: ScalarType?
                
                if let startState = startValue as? SIMD4<ScalarType> {
                    startStateX = startState.x
                    startStateY = startState.y
                    startStateZ = startState.z
                    startStateW = startState.w
                }
                
                let xPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.x)
                
                if let propX = buildPropertyData(keyPath: xPath, parentPath: keyPath, originalValue: originalSIMD.x, startValue: startStateX, endValue: endState.x, isAdditive: isAdditive) {
                    properties.append(propX)
                }
                
                let yPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.y)
                if let propY = buildPropertyData(keyPath: yPath, parentPath: keyPath, originalValue: originalSIMD.y, startValue: startStateY, endValue: endState.y, isAdditive: isAdditive) {
                    properties.append(propY)
                }
                
                let zPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.z)
                if let propZ = buildPropertyData(keyPath: zPath, parentPath: keyPath, originalValue: originalSIMD.z, startValue: startStateZ, endValue: endState.z, isAdditive: isAdditive) {
                    properties.append(propZ)
                }
                
                let wPath: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \.w)
                if let propW = buildPropertyData(keyPath: wPath, parentPath: keyPath, originalValue: originalSIMD.w, startValue: startStateW, endValue: endState.w, isAdditive: isAdditive) {
                    properties.append(propW)
                }
                
            case .simd8:
                guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, SIMD8<ScalarType>> else { return properties }
                guard let originalSIMD = nestedObject as? SIMD8<ScalarType>, let endState = endState as? SIMD8<ScalarType> else { return properties }
                
                for x in 0..<8 {
                    var startState: ScalarType?
                    if let startValue = startValue as? SIMD8<ScalarType> {
                        startState = startValue[x]
                    }
                    
                    let path: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \SIMD8<ScalarType>[x])
                    
                    if let prop = buildPropertyData(keyPath: path, parentPath: keyPath, originalValue: originalSIMD[x], startValue: startState, endValue: endState[x], isAdditive: isAdditive) {
                        properties.append(prop)
                    }
                }
                
            case .simd16:
                guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, SIMD16<ScalarType>> else { return properties }
                guard let originalSIMD = nestedObject as? SIMD16<ScalarType>, let endState = endState as? SIMD16<ScalarType> else { return properties }
                
                for x in 0..<16 {
                    var startState: ScalarType?
                    if let startValue = startValue as? SIMD16<ScalarType> {
                        startState = startValue[x]
                    }
                    
                    let path: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \SIMD16<ScalarType>[x])
                    
                    if let prop = buildPropertyData(keyPath: path, parentPath: keyPath, originalValue: originalSIMD[x], startValue: startState, endValue: endState[x], isAdditive: isAdditive) {
                        properties.append(prop)
                    }
                }
                
            case .simd32:
                guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, SIMD32<ScalarType>> else { return properties }
                guard let originalSIMD = nestedObject as? SIMD32<ScalarType>, let endState = endState as? SIMD32<ScalarType> else { return properties }
                
                for x in 0..<32 {
                    var startState: ScalarType?
                    if let startValue = startValue as? SIMD32<ScalarType> {
                        startState = startValue[x]
                    }
                    
                    let path: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \SIMD32<ScalarType>[x])
                    
                    if let prop = buildPropertyData(keyPath: path, parentPath: keyPath, originalValue: originalSIMD[x], startValue: startState, endValue: endState[x], isAdditive: isAdditive) {
                        properties.append(prop)
                    }
                }
                
            case .simd64:
                guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, SIMD64<ScalarType>> else { return properties }
                guard let originalSIMD = nestedObject as? SIMD64<ScalarType>, let endState = endState as? SIMD64<ScalarType> else { return properties }
                
                for x in 0..<64 {
                    var startState: ScalarType?
                    if let startValue = startValue as? SIMD64<ScalarType> {
                        startState = startValue[x]
                    }
                    
                    let path: ReferenceWritableKeyPath<TargetType, ScalarType> = keyPath.appending(path: \SIMD64<ScalarType>[x])
                    
                    if let prop = buildPropertyData(keyPath: path, parentPath: keyPath, originalValue: originalSIMD[x], startValue: startState, endValue: endState[x], isAdditive: isAdditive) {
                        properties.append(prop)
                    }
                }
                
            case .unsupported:
                break
        }
        
        return properties
    }
    
    func buildPropertyData<PropertyType: SIMDScalar, ParentType: SIMD>(keyPath: ReferenceWritableKeyPath<TargetType, PropertyType>, parentPath: ReferenceWritableKeyPath<TargetType, ParentType>? = nil, originalValue: PropertyType?=nil, startValue: PropertyType?, endValue: PropertyType, isAdditive: Bool = false) -> PropertyData<TargetType>? {
        var data: PropertyData<TargetType>?
        
        if let startValue {
            if let originalValue, (startValue !≈ originalValue || isAdditive) {
                data = PropertyData(keyPath: keyPath, parentPath: parentPath, scalarStart: startValue, scalarEnd: endValue)
            } else if (endValue !≈ startValue) {
                data = PropertyData(keyPath: keyPath, parentPath: parentPath, scalarStart: startValue, scalarEnd: endValue)

            }

        } else if let originalValue {
            if (endValue !≈ originalValue || isAdditive) {
                data = PropertyData(keyPath: keyPath, parentPath: parentPath, scalarStart: originalValue, scalarEnd: endValue)
            }
        } else {
            data = PropertyData(keyPath: keyPath, parentPath: parentPath, scalarEnd: endValue)

        }
        
        return data
    }
    
    
    
    public func update(properties: [PropertyData<TargetType>: Double], targetObject: TargetType) {
        
        for (property, newValue) in properties {
            var newPropertyValue = newValue

            if isAdditive, let path = property.keyPath {
                let currentValue = targetObject[keyPath: path]

                if let currentValue = currentValue as? any BinaryFloatingPoint, let current = currentValue.toDouble() {
                    newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
                } else if let currentValue = currentValue as? any BinaryInteger, let current = currentValue.toDouble() {
                    newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
                }
                
            }
            
            property.applyToSIMD(value: newPropertyValue, to: targetObject)
        }
        
    }
    
    
    public func supports(_ object: Any) -> Bool {
        var is_supported: Bool = false
        
        if (object is any SIMD) {
            is_supported = true
        }
        
        return is_supported
    }
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        var accepts = false
        
        if (object is any SIMD) {
            accepts = true
        }
        
        return accepts
    }

    public static func simdType(for simd: any SIMD) -> SIMDType {
        let simdType: SIMDType
        switch simd.scalarCount {
            case 2:
                simdType = .simd2
            case 3:
                simdType = .simd3
            case 4:
                simdType = .simd4
            case 8:
                simdType = .simd8
            case 16:
                simdType = .simd16
            case 32:
                simdType = .simd32
            case 64:
                simdType = .simd64
            default:
                simdType = .unsupported
        }
        
        return simdType
    }
    
}


public enum SIMDType: String {
    case simd2
    case simd3
    case simd4
    case simd8
    case simd16
    case simd32
    case simd64
    
    case unsupported
}
