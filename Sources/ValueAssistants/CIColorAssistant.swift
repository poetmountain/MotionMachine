//
//  CIColorAssistant.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
#if canImport(CoreImage)
import CoreImage
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
/// CIColorAssistant provides support for Core Image's `CIColor` type.
public final class CIColorAssistant<TargetType: AnyObject>: ValueAssistant {

    public enum CIColorPropertyType: String {
        case red
        case green
        case blue
        case alpha
    }
    
    public var isAdditive: Bool = false
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
        }
    }
    
    // MARK: ValueAssistant methods
    
    public func generateProperties<StateType>(targetObject target: TargetType, state: MotionState<TargetType, StateType>) throws -> [PropertyData<TargetType>] {
        
        var properties: [PropertyData<TargetType>] = []
        
        guard let keyPath = state.keyPath as? KeyPath<TargetType, CIColor> else { return properties }

        if let newColor = state.end as? CIColor {
            
            var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
            
            var add_alpha = false
            var add_red = false
            var add_green = false
            var add_blue = false
            
            let nestedObject = target[keyPath: state.keyPath]
            
            if let targetColor = target as? CIColor {
                red = targetColor.red
                blue = targetColor.blue
                green = targetColor.green
                alpha = targetColor.alpha
            }
            
            var startColor: CIColor?
            if let unwrapped_start = state.start {
                if (state.start is CIColor) {
                    startColor = unwrapped_start as? CIColor
                    // we need to save start color values so we can compare to new color below
                    if let scolor = unwrapped_start as? CIColor {
                        red = scolor.red
                        blue = scolor.blue
                        green = scolor.green
                        alpha = scolor.alpha
                    }
                }
                
            } else if let originalColor = nestedObject as? CIColor {
                startColor = originalColor
                red = originalColor.red
                blue = originalColor.blue
                green = originalColor.green
                alpha = originalColor.alpha
            }
            
            // check each component to avoid building PropertyData objects for color components whose start and end values are the same
            if (Double(red) !≈ Double(newColor.red) || isAdditive) { add_red = true }
            if (Double(blue) !≈ Double(newColor.blue) || isAdditive) { add_blue = true }
            if (Double(green) !≈ Double(newColor.green) || isAdditive) { add_green = true }
            if (Double(alpha) !≈ Double(newColor.alpha) || isAdditive) { add_alpha = true }
            
            if (add_red) {
                var startValue: CGFloat?
                if let startColor {
                    startValue = startColor.red
                }
                let propertyPath: KeyPath<TargetType, CGFloat> = keyPath.appending(path: \CIColor.red)
                let prop = PropertyData<TargetType>(keyPath: propertyPath, parentPath: keyPath, start: startValue, end: newColor.red)
                prop.stringPath = CIColorPropertyType.red.rawValue
                properties.append(prop)
            }
            if (add_green) {
                var startValue: CGFloat?
                if let startColor {
                    startValue = startColor.green
                }
                let propertyPath: KeyPath<TargetType, CGFloat> = keyPath.appending(path: \CIColor.green)
                let prop = PropertyData<TargetType>(keyPath: propertyPath, parentPath: keyPath, start: startValue, end: newColor.green)
                prop.stringPath = CIColorPropertyType.green.rawValue
                properties.append(prop)
            }
            if (add_blue) {
                var startValue: CGFloat?
                if let startColor {
                    startValue = startColor.blue
                }
                let propertyPath: KeyPath<TargetType, CGFloat> = keyPath.appending(path: \CIColor.blue)
                let prop = PropertyData<TargetType>(keyPath: propertyPath, parentPath: keyPath, start: startValue, end: newColor.blue)
                prop.stringPath = CIColorPropertyType.blue.rawValue
                properties.append(prop)
            }
            if (add_alpha) {
                var startValue: CGFloat?
                if let startColor {
                    startValue = startColor.alpha
                }
                let propertyPath: KeyPath<TargetType, CGFloat> = keyPath.appending(path: \CIColor.alpha)
                let prop = PropertyData<TargetType>(keyPath: propertyPath, parentPath: keyPath, start: startValue, end: newColor.alpha)
                prop.stringPath = CIColorPropertyType.alpha.rawValue
                properties.append(prop)
            }
            
        }

        
        return properties
    }
    

    /**
     *  This method replaces an element by assigning new values.
     *
     *  - parameters:
     *      - object:   The object that should be updated.
     *      - property: A ``PropertyData`` object to use for keyPath information.
     *      - newValue:    The value to update with.
     *
     *  - returns: An updated version of the object, if the object property was found and is supported.
     */
    func updateColor(color: CIColor, property: PropertyData<TargetType>, newValue: Double) -> CIColor {
                
        var newColor = color
        
        let changed = newValue
                
        if (property.stringPath == CIColorPropertyType.alpha.rawValue) {
            newColor = CIColor(red: color.red, green: color.green, blue: color.blue, alpha: changed)
            
        } else if (property.stringPath == CIColorPropertyType.red.rawValue) {
            newColor = CIColor(red: changed, green: color.green, blue: color.blue, alpha: color.alpha)
            
        } else if (property.stringPath == CIColorPropertyType.green.rawValue) {
            newColor = CIColor(red: color.red, green: changed, blue: color.blue, alpha: color.alpha)
            
        } else if (property.stringPath == CIColorPropertyType.blue.rawValue) {
            newColor = CIColor(red: color.red, green: color.green, blue: changed, alpha: color.alpha)
        }
        
        return newColor
    }
    
    
    @discardableResult public func update(property: PropertyData<TargetType>, newValue: Double) -> Any? {
        
        return calculateValue(forProperty: property, newValue: newValue)
        
    }
    
    public func calculateValue(forProperty property: PropertyData<TargetType>, newValue: Double) -> Any? {
        
        guard let targetObject = property.targetObject else { return nil }
        
        var newPropertyValue = newValue
        var currentValue: Any?
        
        currentValue = property.retrieveValue(from: targetObject)
        
        // use additive method to update value if additive is true
        if (isAdditive), let currentValue = currentValue as? any BinaryFloatingPoint, let current = currentValue.toDouble() {
            newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
        }
        
        // replace the top-level struct of the property we're trying to alter
        var updatedParent: CIColor?
        if let parentValue = property.retrieveParentValue(from: targetObject) as? CIColor {
            updatedParent = updateColor(color: parentValue, property: property, newValue: newPropertyValue)
        }
        
        if let targetObject = property.targetObject, let updated = updatedParent {
            property.applyToParent(value: updated, to: targetObject)
        }

        return newPropertyValue
        
    }
    
    
    
    public func supports(_ object: Any) -> Bool {
        var is_supported: Bool = false
        
        if (object is CIColor) {
            is_supported = true
        }
        
        return is_supported
    }
    
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        return false
    }
    


}
#endif
