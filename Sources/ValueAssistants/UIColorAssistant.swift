//
//  UIColorAssistant.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS) || os(tvOS) || os(visionOS)
/// UIColorAssistant provides support for the `UIColor` type.
public final class UIColorAssistant<TargetType: AnyObject>: ValueAssistant {
    
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

        guard let keyPath = state.keyPath as? KeyPath<TargetType, UIColor> else { return properties }
        
        if let endProperty = state.end as? UIColor {
            
            let newColor = endProperty
            var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
            var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
            var white: CGFloat = 0.0, walpha: CGFloat = 0.0
            
            var add_hue = false
            var add_sat = false
            var add_brightness = false
            var add_alpha = false
            var add_red = false
            var add_green = false
            var add_blue = false
            var add_white = false
            
            var currentColor: UIColor?
            
            // first check if target is a UIColor, and if so use that as the ocolor base
            if (target is UIColor) {
                currentColor = target as? UIColor
            }
            
            // if there's a start value in the MotionState object and it's a UIColor then use that instead
            if let start = state.start {
                if (state.start is UIColor) {
                    currentColor = start as? UIColor
                }
            } else {
                currentColor = state.retrieveValue(from: target) as? UIColor
            }

            var ohue: CGFloat = 0.0, osaturation: CGFloat = 0.0, obrightness: CGFloat = 0.0, oalpha: CGFloat = 0.0
            var ored: CGFloat = 0.0, ogreen: CGFloat = 0.0, oblue: CGFloat = 0.0
            var owhite: CGFloat = 0.0, owalpha: CGFloat = 0.0
            
            if let currentColor {
                currentColor.getHue(&ohue, saturation: &osaturation, brightness: &obrightness, alpha: &oalpha)
                currentColor.getRed(&ored, green: &ogreen, blue: &oblue, alpha: &oalpha)
                currentColor.getWhite(&owhite, alpha: &owalpha)
            }
            
            newColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            newColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            newColor.getWhite(&white, alpha: &walpha)
            
            if (currentColor != nil) {
                // check each component to avoid building PropertyData objects for color components whose start and end values are the same
                if (Double(red) !≈ Double(ored) || isAdditive) { add_red = true }
                if (Double(blue) !≈ Double(oblue) || isAdditive) { add_blue = true }
                if (Double(green) !≈ Double(ogreen) || isAdditive) { add_green = true }
                
                if (!add_red && !add_green && !add_blue) {
                    if (Double(hue) !≈ Double(ohue) || isAdditive) { add_hue = true }
                    if (Double(saturation) !≈ Double(osaturation) || isAdditive) { add_sat = true }
                    if (Double(brightness) !≈ Double(obrightness) || isAdditive) { add_brightness = true }
                }
                if (Double(alpha) !≈ Double(oalpha) || isAdditive) { add_alpha = true }
                
                // setting white stomps on other color changes so only add white prop if nothing else (other than alpha) is changing
                if (!add_red && !add_green && !add_blue && !add_hue && !add_sat && !add_brightness) {
                    if (Double(white) !≈ Double(owhite) || isAdditive) { add_white = true }
                }
            }
            
            if (add_hue) {
                let p = PropertyData<TargetType>(stringPath: "hue", parentPath: keyPath, start: Double(ohue), end: Double(hue))
                properties.append(p)
            }
            if (add_sat) {
                let p = PropertyData<TargetType>(stringPath: "saturation", parentPath: keyPath, start: Double(osaturation), end: Double(saturation))
                properties.append(p)
            }
            if (add_brightness) {
                let p = PropertyData<TargetType>(stringPath: "brightness", parentPath: keyPath, start: Double(obrightness), end: Double(brightness))
                properties.append(p)
            }

            if (add_red) {
                let p = PropertyData<TargetType>(stringPath: "red", parentPath: keyPath, start: Double(ored), end: Double(red))
                properties.append(p)
            }
            if (add_green) {
                let p = PropertyData<TargetType>(stringPath: "green", parentPath: keyPath, start: Double(ogreen), end: Double(green))
                properties.append(p)
            }
            if (add_blue) {
                let p = PropertyData<TargetType>(stringPath: "blue", parentPath: keyPath, start: Double(oblue), end: Double(blue))
                properties.append(p)
            }
            if (add_white) {
                let p = PropertyData<TargetType>(stringPath: "white", parentPath: keyPath, start: Double(owhite), end: Double(white))
                properties.append(p)
            }
            if (add_alpha) {
                let p = PropertyData<TargetType>(stringPath: "alpha", parentPath: keyPath, start: Double(oalpha), end: Double(alpha))
                properties.append(p)
            }
            
            if (target is UIColor) {
                for index in 0 ..< properties.count {
                    properties[index].target = target
                }
            }
            
        }
        
        return properties
    }
    
    
    
    
    @discardableResult public func update(property: PropertyData<TargetType>, newValue: Double) -> Any? {
        
        return calculateValue(forProperty: property, newValue: newValue)

    }
    
    public func calculateValue(forProperty property: PropertyData<TargetType>, newValue: Double) -> Any? {
        
        guard let targetObject = property.targetObject  else { return nil }
                
        var newPropertyValue = newValue
        
        // replace the UIColor itself
        if let currentColor = property.retrieveParentValue(from: targetObject) as? UIColor {
            let newValues = [property.stringPath : newPropertyValue]
                    
            var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
            var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, white: CGFloat = 0.0
            
            var colorToUpdate = currentColor
            
            colorToUpdate.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            colorToUpdate.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            colorToUpdate.getWhite(&white, alpha: &alpha)
            
            for (prop, newValue) in newValues {
                var changed = CGFloat(newValue)

                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "hue") {
                    if (isAdditive) { changed = applyAdditiveTo(value: hue, newValue: changed) }
                    colorToUpdate = UIColor(hue: changed, saturation: saturation, brightness: brightness, alpha: alpha)
                }
                
                if (last_component == "saturation") {
                    if (isAdditive) { changed = applyAdditiveTo(value: saturation, newValue: changed) }
                    colorToUpdate = UIColor(hue: hue, saturation: changed, brightness: brightness, alpha: alpha)
                }
                
                if (last_component == "brightness") {
                    if (isAdditive) { changed = applyAdditiveTo(value: brightness, newValue: changed) }
                    colorToUpdate = UIColor(hue: hue, saturation: saturation, brightness: changed, alpha: alpha)
                }
                
                if (last_component == "alpha") {
                    if (isAdditive) { changed = applyAdditiveTo(value: alpha, newValue: changed) }
                    colorToUpdate = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: changed)
                }
                
                if (last_component == "red") {
                    if (isAdditive) { changed = applyAdditiveTo(value: red, newValue: changed) }
                    colorToUpdate = UIColor(red: changed, green: green, blue: blue, alpha: alpha)
                }
                
                if (last_component == "green") {
                    if (isAdditive) { changed = applyAdditiveTo(value: green, newValue: changed) }
                    colorToUpdate = UIColor(red: red, green: changed, blue: blue, alpha: alpha)
                }
                
                if (last_component == "blue") {
                    if (isAdditive) { changed = applyAdditiveTo(value: blue, newValue: changed) }
                    colorToUpdate = UIColor(red: red, green: green, blue: changed, alpha: alpha)
                }
                
                if (last_component == "white") {
                    if (isAdditive) { changed = applyAdditiveTo(value: white, newValue: changed) }
                    colorToUpdate = UIColor(white: changed, alpha: alpha)
                }
                
                newPropertyValue = changed
            }
            
            property.applyToParent(value: colorToUpdate, to: targetObject)
            
            
        }

        return newPropertyValue
        
    }
    
    
    
    public func supports(_ object: Any) -> Bool {
        var is_supported: Bool = false
        
        if (object is UIColor) {
            is_supported = true
        }
        
        return is_supported
    }
    
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        return false
    }
    
}
#endif
