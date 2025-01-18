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

#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
/// UIColorAssistant provides support for the `UIColor` type.
public final class UIColorAssistant<TargetType: AnyObject>: ValueAssistant {
    
    private enum ColorType {
        case hsb
        case rgb
        case white
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
    
    
    
    
    public func update(properties: [PropertyData<TargetType>: Double], targetObject: TargetType) {
        let parentObject = properties.keys.first?.retrieveParentValue(from: targetObject)
        guard let currentColor = parentObject as? UIColor else { return }
        
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, white: CGFloat = 0.0
        
        if properties.keys.contains(where: { $0.stringPath == "hue" || $0.stringPath == "saturation" || $0.stringPath == "brightness" }) {
            currentColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        }
        
        if properties.keys.contains(where: { $0.stringPath == "red" || $0.stringPath == "blue" || $0.stringPath == "green" }) {
            currentColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        
        if properties.keys.contains(where: { $0.stringPath == "white" }) {
            currentColor.getWhite(&white, alpha: &alpha)
        }
        
        var colorChangeType: ColorType = .rgb
        
        for (property, newValue) in properties {
            
            let lastComponent = property.stringPath
            
            let newFloatValue = CGFloat(newValue)
            
            if (lastComponent == "hue") {
                colorChangeType = .hsb
                hue = (isAdditive) ? applyAdditiveTo(value: hue, newValue: newFloatValue) : newFloatValue
            }
            
            if (lastComponent == "saturation") {
                colorChangeType = .hsb
                saturation = (isAdditive) ? applyAdditiveTo(value: saturation, newValue: newFloatValue) : newFloatValue
            }
            
            if (lastComponent == "brightness") {
                colorChangeType = .hsb
                brightness = (isAdditive) ? applyAdditiveTo(value: brightness, newValue: newFloatValue) : newFloatValue
            }
            
            if (lastComponent == "red") {
                colorChangeType = .rgb
                red = (isAdditive) ? applyAdditiveTo(value: red, newValue: newFloatValue) : newFloatValue
            }
            
            if (lastComponent == "green") {
                colorChangeType = .rgb
                green = (isAdditive) ? applyAdditiveTo(value: green, newValue: newFloatValue) : newFloatValue
            }
            
            if (lastComponent == "blue") {
                colorChangeType = .rgb
                blue = (isAdditive) ? applyAdditiveTo(value: blue, newValue: newFloatValue) : newFloatValue
            }
            
            if (lastComponent == "white") {
                colorChangeType = .white
                white = (isAdditive) ? applyAdditiveTo(value: white, newValue: newFloatValue) : newFloatValue
            }
                
            if (lastComponent == "alpha") {
                alpha = (isAdditive) ? applyAdditiveTo(value: alpha, newValue: newFloatValue) : newFloatValue
            }
        }

        var changedColor: UIColor
        
        switch colorChangeType {
            case .hsb:
                changedColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            case .rgb:
                changedColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            case .white:
                changedColor = UIColor(white: white, alpha: alpha)
        }
                
        properties.keys.first?.applyToParent(value: changedColor, to: targetObject)
        
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
