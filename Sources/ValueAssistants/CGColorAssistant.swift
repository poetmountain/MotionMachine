//
//  CGColorAssistant.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS) || os(watchOS)
/// CGColorAssistant provides support for the `CGColor` type.
public final class CGColorAssistant<TargetType: AnyObject>: ValueAssistant {

    public var isAdditive: Bool = false
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
        }
    }
    
    // MARK: ValueAssistant methods
    
    public func generateProperties<StateType>(targetObject target: TargetType, state: MotionState<TargetType, StateType>) throws -> [PropertyData<TargetType>] {
        
        guard isObjectCGColor(object: state.end) else { return [] }
        
        var properties: [PropertyData<TargetType>] = []
                        
        guard let parentPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, CGColor>, let endColor = castToCGColor(object: state.end) else { return properties }

        var originalColor: CGColor?
        
        // first check if target is a UIColor, and if so use that as the ocolor base
        if isObjectCGColor(object: target) {
            originalColor = castToCGColor(object: target)
        }
        
        // if there's a start value in the MotionState object and it's a CGColor then use that instead
        if let startState = state.start {
            if isObjectCGColor(object: startState) {
                originalColor = castToCGColor(object: startState)
            }
            
        } else if let retrievedValue = state.retrieveValue(from: target) {
            originalColor = castToCGColor(object: retrievedValue)
        }

        
        for x in 0..<endColor.numberOfComponents {
            var startValue: CGFloat?
            if let components = originalColor?.components {
                startValue = components[x]
            }
            
            let finalPath: KeyPath<TargetType, CGFloat> = parentPath.appending(path: \CGColor.components[default: [CGFloat]()][x])
            
            if let endValue = endColor.components?[x], let prop = buildPropertyData(keyPath: finalPath, parentPath: parentPath, originalValue: originalColor?.components?[x], startValue: startValue, endValue: endValue, isAdditive: isAdditive) {
                prop.stringPath = "\(x)"
                properties.append(prop)
            }
                
        }
        
        
        return properties
    }
    
    
    public func update(properties: [PropertyData<TargetType>: Double], targetObject: TargetType) {
        let parentObject = properties.keys.first?.retrieveParentValue(from: targetObject)
        guard let parentObject, let color = castToCGColor(object: parentObject) else { return }
        
        // copy the current color components to a new array
        var newComponents: [CGFloat] = color.components?.map { $0 } ?? []

        // for each property, update the associated component with the new value
        for (property, newValue) in properties {
            var newPropertyValue = newValue
            if let componentIndex = Int(property.stringPath) {
                if isAdditive {
                    let currentComponentValue = newComponents[componentIndex]
                    newPropertyValue = applyAdditiveTo(value: currentComponentValue, newValue: newValue)
                }
                newComponents[componentIndex] = newPropertyValue
            }

        }
        
        // now use the new components array to update the existing color and apply it to the target object
        if let colorSpace = color.colorSpace, let newColor = CGColor(colorSpace: colorSpace, components: newComponents) {
            properties.keys.first?.applyToParent(value: newColor, to: targetObject)
        }

    }
    
    
    public func supports(_ object: Any) -> Bool {
        return isObjectCGColor(object: object)
    }
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        return true
    }

    
    func buildPropertyData<PropertyType: BinaryFloatingPoint, ParentType: CGColor>(keyPath: KeyPath<TargetType, PropertyType>, parentPath: ReferenceWritableKeyPath<TargetType, ParentType>? = nil, originalValue: PropertyType?=nil, startValue: PropertyType?, endValue: PropertyType, isAdditive: Bool = false) -> PropertyData<TargetType>? {
        var data: PropertyData<TargetType>?
        
        if let startValue {
            if let originalValue, (startValue !≈ originalValue || isAdditive) {
                data = PropertyData(keyPath: keyPath, parentPath: parentPath, start: startValue, end: endValue)
            } else if (endValue !≈ startValue) {
                data = PropertyData(keyPath: keyPath, parentPath: parentPath, start: startValue, end: endValue)

            }

        } else if let originalValue {
            if (endValue !≈ originalValue || isAdditive) {
                data = PropertyData(keyPath: keyPath, parentPath: parentPath, start: originalValue, end: endValue)
            }
        } else {
            data = PropertyData(keyPath: keyPath, parentPath: parentPath, end: endValue)

        }
        
        return data
    }
    
    /// Determines whether an object is a `CGColor`.
    ///
    /// Due to a lack of Swift's knowledge about this type due to it being an opaque CF type, simple equality checks using `is` do not work and thus a more involved approach is needed.
    /// - Parameter object: The object to check.
    /// - Returns: A Bool representing whether the object is a `CGColor`.
    func isObjectCGColor(object: Any) -> Bool {
        let cfObject = object as CFTypeRef
        return CFGetTypeID(cfObject) == CGColor.typeID
    }
    
    /// This method attempts to cast an object to `CGColor`.
    /// - Parameter object: The object to cast.
    /// - Returns: The object cast as a `CGColor`, if the cast was successful.
    func castToCGColor(object: Any) -> CGColor? {
        guard isObjectCGColor(object: object) else { return nil }
        
        return (object as! CGColor)
    }

}
#endif
