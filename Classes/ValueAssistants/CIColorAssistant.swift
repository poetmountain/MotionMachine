//
//  CIColorAssistant.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/26/16.
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
import CoreImage

/// CIColorAssistant provides support for Core Image's `CIColor` type.
public class CIColorAssistant : ValueAssistant {

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
        
        if (propertyStates.end is CIColor) {

            
            let new_color = propertyStates.end as! CIColor
            var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
            
            var add_alpha = false
            var add_red = false
            var add_green = false
            var add_blue = false
            
            if (target is CIColor) {
                let tcolor = target as! CIColor
                red = tcolor.red
                blue = tcolor.blue
                green = tcolor.green
                alpha = tcolor.alpha
            }
            
            var start_color: CIColor?
            if let unwrapped_start = propertyStates.start {
                if (propertyStates.start is CIColor) {
                    start_color = unwrapped_start as? CIColor
                    // we need to save start color values so we can compare to new color below
                    let scolor = unwrapped_start as! CIColor
                    red = scolor.red
                    blue = scolor.blue
                    green = scolor.green
                    alpha = scolor.alpha
                }
            }
            
            // check each component to avoid building PropertyData objects for color components whose start and end values are the same
            if (Double(red) !≈ Double(new_color.red)) { add_red = true }
            if (Double(blue) !≈ Double(new_color.blue)) { add_blue = true }
            if (Double(green) !≈ Double(new_color.green)) { add_green = true }
            if (Double(alpha) !≈ Double(new_color.alpha)) { add_alpha = true }
            
            if (add_red) {
                var start_state: Double?
                if let unwrapped_start_color = start_color {
                    start_state = Double(unwrapped_start_color.red)
                }
                let p = PropertyData(path: "red", start: start_state, end: Double(new_color.red))
                properties.append(p)
            }
            if (add_green) {
                var start_state: Double?
                if let unwrapped_start_color = start_color {
                    start_state = Double(unwrapped_start_color.green)
                }
                let p = PropertyData(path: "green", start: start_state, end: Double(new_color.green))
                properties.append(p)
            }
            if (add_blue) {
                var start_state: Double?
                if let unwrapped_start_color = start_color {
                    start_state = Double(unwrapped_start_color.blue)
                }
                let p = PropertyData(path: "blue", start: start_state, end: Double(new_color.blue))
                properties.append(p)
            }
            if (add_alpha) {
                var start_state: Double?
                if let unwrapped_start_color = start_color {
                    start_state = Double(unwrapped_start_color.alpha)
                }
                let p = PropertyData(path: "alpha", start: start_state, end: Double(new_color.alpha))
                properties.append(p)
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

        var path_value :Double?
        
        if let unwrapped_object = property.targetObject {
            if let parent = unwrapped_object.value(forKeyPath: property.parentKeyPath)! as? NSObject {
                path_value = retrieveValue(inObject: parent, keyPath: property.path)
            }
            
        } else if (unwrapped_target is CIColor) {
            
            path_value = retrieveValue(inObject: unwrapped_target, keyPath: property.path)
        }
        
        return path_value
        
    }
    
    
    public func retrieveValue(inObject object: Any, keyPath path: String) -> Double? {
        var retrieved_value: Double?
        
        if (object is CIColor) {
            let color = object as! CIColor
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "alpha") {
                retrieved_value = Double(color.alpha)
                
            } else if (last_component == "red") {
                retrieved_value = Double(color.red)
                
            } else if (last_component == "green") {
                retrieved_value = Double(color.green)
                
            } else if (last_component == "blue") {
                retrieved_value = Double(color.blue)
            }
            
            
        }
        
        return retrieved_value
    }
    
    
    public func updateValue(inObject object: Any, newValues: Dictionary<String, Double>) -> NSObject? {
        
        guard newValues.count > 0 else { return nil }
        
        var new_parent_value:NSObject?
        
        if (object is CIColor) {
            let color = object as! CIColor
            var new_color = color
            
            for (prop, newValue) in newValues {
                var changed = CGFloat(newValue)
                
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "alpha") {
                    if (additive) { changed = color.alpha + changed }
                    new_color = CIColor.init(red: color.red, green: color.green, blue: color.blue, alpha: changed)
                }
                
                if (last_component == "red") {
                    if (additive) { changed = color.red + changed }
                    new_color = CIColor.init(red: changed, green: color.green, blue: color.blue, alpha: color.alpha)
                }
                
                if (last_component == "green") {
                    if (additive) { changed = color.green + changed }
                    new_color = CIColor.init(red: color.red, green: changed, blue: color.blue, alpha: color.alpha)
                }
                
                if (last_component == "blue") {
                    if (additive) { changed = color.blue + changed }
                    new_color = CIColor.init(red: color.red, green: color.green, blue: changed, alpha: color.alpha)
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
            if (unwrapped_target is CIColor) {
                var new_property_value = property.current
                if (additive) {
                    new_property_value = newValue
                }
                
                // replace the top-level struct of the property we're trying to alter
                // e.g.: keyPath is @"frame.origin.x", so we replace "frame" because that's the closest KVC-compliant prop
                if let base_prop = unwrapped_object.value(forKeyPath: property.parentKeyPath) {
                    
                    new_prop = updateValue(inObject: (base_prop as! NSObject), newValues: [property.path : new_property_value])
                }
            }
            
            return new_prop
        }
        
        // we have no base object, so we must be changing the CIColor directly
        if (unwrapped_target is CIColor) {
            
            var new_property_value = property.current
            if (additive) {
                new_property_value = newValue
            }
            
            new_prop = updateValue(inObject: (unwrapped_target as! NSObject), newValues: [property.path : new_property_value])
            
        }
        
        
        return new_prop
        
    }
    
    
    
    public func supports(_ object: AnyObject) -> Bool {
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
