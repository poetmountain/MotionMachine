//
//  UIColorAssistant.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/18/16.
//  Copyright © 2016-2018 Poet & Mountain, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

/// UIColorAssistant provides support for the `UIColor` type.
public class UIColorAssistant : ValueAssistant {
    
    public var additive: Bool = false
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
        }
    }
    
    public required init() {}

    
    // MARK: ValueAssistant methods
    
    public func generateProperties(targetObject target: AnyObject, propertyStates: PropertyStates) throws -> [PropertyData] {
        
        var properties: [PropertyData] = []
        
        if (propertyStates.end is UIColor) {
            
            let new_color = propertyStates.end as! UIColor
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
            
            var ocolor: UIColor?
            
            // first check if target is a UIColor, and if so use that as the ocolor base
            if (target is UIColor) {
                ocolor = target as? UIColor
            }
            
            // if there's a start value in the PropertyStates object and it's a UIColor then use that instead
            if let unwrapped_start = propertyStates.start {
                if (propertyStates.start is UIColor) {
                    ocolor = unwrapped_start as? UIColor
                }
            }

            var ohue: CGFloat = 0.0, osaturation: CGFloat = 0.0, obrightness: CGFloat = 0.0, oalpha: CGFloat = 0.0
            var ored: CGFloat = 0.0, ogreen: CGFloat = 0.0, oblue: CGFloat = 0.0
            var owhite: CGFloat = 0.0, owalpha: CGFloat = 0.0
            
            if (ocolor != nil) {
                ocolor!.getHue(&ohue, saturation: &osaturation, brightness: &obrightness, alpha: &oalpha)
                ocolor!.getRed(&ored, green: &ogreen, blue: &oblue, alpha: &oalpha)
                ocolor!.getWhite(&owhite, alpha: &owalpha)
            }
            
            new_color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            new_color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            new_color.getWhite(&white, alpha: &walpha)
            
            if (ocolor != nil) {
                // check each component to avoid building PropertyData objects for color components whose start and end values are the same
                if (Double(red) !≈ Double(ored)) { add_red = true }
                if (Double(blue) !≈ Double(oblue)) { add_blue = true }
                if (Double(green) !≈ Double(ogreen)) { add_green = true }
                
                if (!add_red && !add_green && !add_blue) {
                    if (Double(hue) !≈ Double(ohue)) { add_hue = true }
                    if (Double(saturation) !≈ Double(osaturation)) { add_sat = true }
                    if (Double(brightness) !≈ Double(obrightness)) { add_brightness = true }
                }
                if (Double(alpha) !≈ Double(oalpha)) { add_alpha = true }
                
                // setting white stomps on other color changes so only add white prop if nothing else (other than alpha) is changing
                if (!add_red && !add_green && !add_blue && !add_hue && !add_sat && !add_brightness) {
                    if (Double(white) !≈ Double(owhite)) { add_white = true }
                }
            }
            
            if (add_hue) {
                let p = PropertyData(path: "hue", start: Double(ohue), end: Double(hue))
                properties.append(p)
            }
            if (add_sat) {
                let p = PropertyData(path: "saturation", start: Double(osaturation), end: Double(saturation))
                properties.append(p)
            }
            if (add_brightness) {
                let p = PropertyData(path: "brightness", start: Double(obrightness), end: Double(brightness))
                properties.append(p)
            }
            if (add_alpha) {
                let p = PropertyData(path: "alpha", start: Double(oalpha), end: Double(alpha))
                properties.append(p)
            }
            if (add_red) {
                let p = PropertyData(path: "red", start: Double(ored), end: Double(red))
                properties.append(p)
            }
            if (add_green) {
                let p = PropertyData(path: "green", start: Double(ogreen), end: Double(green))
                properties.append(p)
            }
            if (add_blue) {
                let p = PropertyData(path: "blue", start: Double(oblue), end: Double(blue))
                properties.append(p)
            }
            if (add_white) {
                let p = PropertyData(path: "white", start: Double(owhite), end: Double(white))
                properties.append(p)
            }
            
            if (target is UIColor) {
                for index in 0 ..< properties.count {
                    properties[index].target = target
                }
            }
            
        }
        
        
        if (propertyStates.path != "") {
            for index in 0 ..< properties.count {
                if (properties[index].path != "") {
                    properties[index].path = propertyStates.path + "." + properties[index].path
                } else {
                    properties[index].path = propertyStates.path
                }
            }
        }
        
        return properties
    }
    
    
    
    public func retrieveCurrentObjectValue(forProperty property: PropertyData) -> Double? {
        
        guard let unwrapped_target = property.target else { return nil }
        
        var object_value :Double?
        
        if let unwrapped_object = property.targetObject {
            // BEWARE, THIS BE UNSAFE MUCKING ABOUT
            // this would normally be in a do/catch but unfortunately Swift can't catch exceptions from Obj-C methods
            typealias GetterFunction = @convention(c) (AnyObject, Selector) -> AnyObject
            let implementation: IMP = unwrapped_object.method(for: property.getter!)
            let curried = unsafeBitCast(implementation, to: GetterFunction.self)
            let obj = curried(unwrapped_object, property.getter!)
            
            object_value = retrieveValue(inObject: obj as! NSObject, keyPath: property.path)

        } else if (unwrapped_target is UIColor) {

            object_value = retrieveValue(inObject: unwrapped_target as! NSObject, keyPath: property.path)
        }
        
        return object_value
    }
    
    
    
    public func retrieveValue(inObject object: Any, keyPath path: String) -> Double? {
        var retrieved_value: Double?
        
        if (object is UIColor) {
            let color = object as! UIColor
            var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, white: CGFloat = 0
            
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            color.getWhite(&white, alpha: &alpha)
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "hue") {
                retrieved_value = Double(hue)
                
            } else if (last_component == "saturation") {
                retrieved_value = Double(saturation)
                
            } else if (last_component == "brightness") {
                retrieved_value = Double(brightness)
                
            } else if (last_component == "alpha") {
                retrieved_value = Double(alpha)
                
            } else if (last_component == "red") {
                retrieved_value = Double(red)
                
            } else if (last_component == "green") {
                retrieved_value = Double(green)
                
            } else if (last_component == "blue") {
                retrieved_value = Double(blue)
                
            } else if (last_component == "white") {
                retrieved_value = Double(blue)
            }

        }
        
        return retrieved_value
    }
    
    
    public func updateValue(inObject object: Any, newValues: Dictionary<String, Double>) -> NSObject? {
        
        guard newValues.count > 0 else { return nil }
        
        var new_parent_value:NSObject?
        
        if (object is UIColor) {
            let color = object as! UIColor
            var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
            var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, white: CGFloat = 0.0
            
            var new_color = color
            
            for (prop, newValue) in newValues {
                var changed = CGFloat(newValue)
                new_color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                new_color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                new_color.getWhite(&white, alpha: &alpha)
                
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "hue") {
                    if (additive) { changed = hue + changed }
                    new_color = UIColor.init(hue: changed, saturation: saturation, brightness: brightness, alpha: alpha)
                }
                
                if (last_component == "saturation") {
                    if (additive) { changed = saturation + changed }
                    new_color = UIColor.init(hue: hue, saturation: changed, brightness: brightness, alpha: alpha)
                }
                
                if (last_component == "brightness") {
                    if (additive) { changed = brightness + changed }
                    new_color = UIColor.init(hue: hue, saturation: saturation, brightness: changed, alpha: alpha)
                }
                
                if (last_component == "alpha") {
                    if (additive) { changed = alpha + changed }
                    new_color = UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: changed)
                }
                
                if (last_component == "red") {
                    if (additive) { changed = red + changed }
                    new_color = UIColor.init(red: changed, green: green, blue: blue, alpha: alpha)
                }
                
                if (last_component == "green") {
                    if (additive) { changed = green + changed }
                    new_color = UIColor.init(red: red, green: changed, blue: blue, alpha: alpha)
                }
                
                if (last_component == "blue") {
                    if (additive) { changed = blue + changed }
                    new_color = UIColor.init(red: red, green: green, blue: changed, alpha: alpha)
                }
                
                if (last_component == "white") {
                    if (additive) { changed = white + changed }
                    new_color = UIColor.init(white: changed, alpha: alpha)
                }
            }
            
            new_parent_value = new_color
        }
        
        return new_parent_value
    }
    
    
    
    public func calculateValue(forProperty property: PropertyData, newValue: Double) -> NSObject? {
        
        guard let unwrapped_target = property.target else { return nil }
        
        var new_prop: NSObject? = NSNumber.init(value: property.current)
        
        
        if let unwrapped_object = property.targetObject {
            // we have a normal object whose property is being changed
            if (unwrapped_target is UIColor) {
                var new_property_value = property.current
                if (additive) {
                    new_property_value = newValue
                }
                
                // replace the top-level struct of the property we're trying to alter
                // e.g.: keyPath is @"frame.origin.x", so we replace "frame" because that's the closest KVC-compliant prop
                if let base_prop = unwrapped_object.value(forKeyPath: property.parentKeyPath) {
                    
                    let new_color = updateValue(inObject: (base_prop as! NSObject), newValues: [property.path : new_property_value]) as! UIColor
                    new_prop = new_color
                    
                    // BEWARE, THIS BE UNSAFE MUCKING ABOUT
                    // this would normally be in a do/catch but unfortunately Swift can't catch exceptions from Obj-C methods
                    
                    // letting the runtime know about result and argument types
                    typealias SetterFunction = @convention(c) (AnyObject, Selector, UIColor) -> Void
                    let implementation: IMP = unwrapped_object.method(for: property.setter!)
                    let curried = unsafeBitCast(implementation, to: SetterFunction.self)
                    curried(unwrapped_object, property.setter!, new_color)
                }
                
            }
            
            return new_prop
        }
        
        // we have no base object, so we must be changing the UIColor directly
        if (unwrapped_target is UIColor) {
            
            var new_property_value = property.current
            if (additive) {
                new_property_value = newValue
            }
            
            let new_color = updateValue(inObject: (unwrapped_target as! NSObject), newValues: [property.path : new_property_value]) as! UIColor
            new_prop = new_color
            
        }
        
        
        return new_prop
        
    }
    
    
    
    public func supports(_ object: AnyObject) -> Bool {
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
