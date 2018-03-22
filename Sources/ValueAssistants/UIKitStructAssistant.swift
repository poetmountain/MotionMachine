//
//  UIKitStructAssistant.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/30/16.
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

/// UIKitStructAssistant provides support for the UIKit structs `UIEdgeInsets` and `UIOffset`.
public class UIKitStructAssistant : ValueAssistant {
    
    public var additive: Bool = false
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
        }
    }
    
    /**
     *  Initializer.
     *
     */
    public required init() {
        // provide support for UIKit structs
        // doesn't seem like there's a better way to extend the enum array from multiple assistants than this?
        ValueStructTypes.valueTypes[.uiEdgeInsets] = NSValue(uiEdgeInsets: UIEdgeInsets.zero)
        ValueStructTypes.valueTypes[.uiOffset] = NSValue(uiOffset: UIOffset.zero)
    }
    
    
    // MARK: ValueAssistant methods
    
    public func generateProperties(targetObject target: AnyObject, propertyStates: PropertyStates) throws -> [PropertyData] {
        
        var properties: [PropertyData] = []
        
        guard let end_value = propertyStates.end as? NSValue else { throw ValueAssistantError.typeRequirement("NSValue") }
        var start_value: NSValue?
        var start_type: ValueStructTypes = .unsupported
        if let unwrapped_start = propertyStates.start {
            if (propertyStates.start is NSValue) {
                start_value = unwrapped_start as? NSValue
                start_type = UIKitStructAssistant.determineType(forValue: start_value!)
            }
        }
        
        let end_type = UIKitStructAssistant.determineType(forValue: end_value)
        
        switch end_type {
        case .uiEdgeInsets:
            let base_path: String = propertyStates.path + "."

            var org_top: Double?
            var org_left: Double?
            var org_bottom: Double?
            var org_right: Double?
            
            if let unwrapped_nsvalue = target as? NSValue {
                let type = UIKitStructAssistant.determineType(forValue: unwrapped_nsvalue)
                if (type == .uiEdgeInsets) {
                    let org_insets = unwrapped_nsvalue.uiEdgeInsetsValue
                    org_top = Double(org_insets.top)
                    org_left = Double(org_insets.left)
                    org_bottom = Double(org_insets.bottom)
                    org_right = Double(org_insets.right)
                }
            }
            
            let insets = end_value.uiEdgeInsetsValue
            
            if let unwrapped_top = org_top {
                var start_state: Double
                if (start_value != nil && start_type == .uiEdgeInsets) {
                    start_state = Double(start_value!.uiEdgeInsetsValue.top)
                } else {
                    start_state = unwrapped_top
                }
                
                if (Double(insets.top) !≈ start_state) {
                    let prop = PropertyData(path: base_path + "top", start: start_state, end: Double(insets.top))
                    properties.append(prop)
                }
            }
            if let unwrapped_left = org_left {
                var start_state: Double
                if (start_value != nil && start_type == .uiEdgeInsets) {
                    start_state = Double(start_value!.uiEdgeInsetsValue.left)
                } else {
                    start_state = unwrapped_left
                }
                
                if (Double(insets.left) !≈ start_state) {
                    let prop = PropertyData(path: base_path + "left", start: start_state, end: Double(insets.left))
                    properties.append(prop)
                }
            }
            if let unwrapped_bottom = org_bottom {
                var start_state: Double
                if (start_value != nil && start_type == .uiEdgeInsets) {
                    start_state = Double(start_value!.uiEdgeInsetsValue.bottom)
                } else {
                    start_state = unwrapped_bottom
                }
                
                if (Double(insets.bottom) !≈ start_state) {
                    let prop = PropertyData(path: base_path + "bottom", start: start_state, end: Double(insets.bottom))
                    properties.append(prop)
                }
            }
            if let unwrapped_right = org_right {
                var start_state: Double
                if (start_value != nil && start_type == .uiEdgeInsets) {
                    start_state = Double(start_value!.uiEdgeInsetsValue.right)
                } else {
                    start_state = unwrapped_right
                }
                
                if (Double(insets.right) !≈ start_state) {
                    let prop = PropertyData(path: base_path + "right", start: start_state, end: Double(insets.right))
                    properties.append(prop)
                }
            }
            
        case .uiOffset:
            let base_path: String = propertyStates.path + "."
            
            var org_h: Double?
            var org_v: Double?
            
            if let unwrapped_nsvalue = target as? NSValue {
                let type = UIKitStructAssistant.determineType(forValue: unwrapped_nsvalue)
                if (type == .uiOffset) {
                    let org_offset = unwrapped_nsvalue.uiOffsetValue
                    org_h = Double(org_offset.horizontal)
                    org_v = Double(org_offset.vertical)
                }
            }
            
            let offset = end_value.uiOffsetValue
            
            if let unwrapped_h = org_h {
                var start_state: Double
                if (start_value != nil && start_type == .uiOffset) {
                    start_state = Double(start_value!.uiOffsetValue.horizontal)
                } else {
                    start_state = unwrapped_h
                }
                
                if (Double(offset.horizontal) !≈ start_state) {
                    let prop = PropertyData(path: base_path + "horizontal", start: start_state, end: Double(offset.horizontal))
                    properties.append(prop)
                }
            }
            if let unwrapped_v = org_v {
                var start_state: Double
                if (start_value != nil && start_type == .uiOffset) {
                    start_state = Double(start_value!.uiOffsetValue.vertical)
                } else {
                    start_state = unwrapped_v
                }
                
                if (Double(offset.vertical) !≈ start_state) {
                    let prop = PropertyData(path: base_path + "vertical", start: start_state, end: Double(offset.vertical))
                    properties.append(prop)
                }
            }
        
        case .unsupported: break

        default:
            break
        }
        
        return properties
    }
    
    
    
    public func retrieveValue(inObject object: Any, keyPath path: String) throws -> Double? {
        var retrieved_value: Double?
        
        guard let value = object as? NSValue else { throw ValueAssistantError.typeRequirement("NSValue") }

        if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.uiEdgeInsets.toObjCType())) {
            
            retrieved_value = retrieveStructValue(value, type: .uiEdgeInsets, path: path)
        
        } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.uiOffset.toObjCType())) {
            
            retrieved_value = retrieveStructValue(value, type: .uiOffset, path: path)
        }
        
        return retrieved_value
    }
    
    
    public func calculateValue(forProperty property: PropertyData, newValue: Double) -> NSObject? {
        
        guard let unwrapped_target = property.target else { return nil }
        
        var new_prop: NSObject? = NSNumber.init(value: property.current)
        
        // this code path will execute if the object passed in was an NSValue
        // as such we must replace the value object directly
        if ((property.targetObject == nil || property.targetObject === unwrapped_target) && unwrapped_target is NSValue) {
            var new_property_value = property.current
            if (additive) {
                new_property_value = newValue
            }
            
            new_prop = updateValue(inObject: unwrapped_target, newValues: [property.path : new_property_value])
            
            return new_prop
        }
        
        
        if let unwrapped_object = property.targetObject {
            // we have a normal object whose property is being changed
            if (unwrapped_target is Double) {
                if let base_prop = unwrapped_object.value(forKeyPath: property.path) {
                    var new_property_value = property.current
                    if (additive) {
                        new_property_value = newValue
                    }
                    new_prop = updateValue(inObject: base_prop, newValues: [property.path : new_property_value])
                }
                
            } else if (unwrapped_target is NSValue) {
                if (!property.replaceParentProperty) {
                    if let base_prop = unwrapped_object.value(forKeyPath: property.path) {
                        
                        if (base_prop is NSObject) {
                            var new_property_value = property.current
                            if (additive) {
                                new_property_value = newValue
                            }
                            
                            new_prop = updateValue(inObject: base_prop, newValues: [property.path : new_property_value])
                            
                        }
                        
                    }
                } else {
                    // replace the top-level struct of the property we're trying to alter
                    // e.g.: key path is "frame.origin.x", so we replace "frame" because that's the closest KVC-compliant prop
                    if let base_prop = unwrapped_object.value(forKeyPath: property.parentKeyPath) {
                        var new_property_value = property.current
                        if (additive) {
                            new_property_value = newValue
                        }
                        
                        new_prop = updateValue(inObject: base_prop, newValues: [property.path : new_property_value])
                        
                    }
                    
                }
                
            }
            
            return new_prop
        }
        
        return new_prop
    }
    
    
    public func updateValue(inObject object: Any, newValues: Dictionary<String, Double>) -> NSObject? {
        guard newValues.count > 0 else { return nil }
        
        var new_parent_value:NSObject?
        
        if let unwrapped_value = object as? NSValue {
            var value = unwrapped_value
            
            if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.uiEdgeInsets.toObjCType())) {
                
                updateStruct(&value, type: .uiEdgeInsets, newValues: newValues)
            
            } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.uiOffset.toObjCType())) {
                
                updateStruct(&value, type: .uiOffset, newValues: newValues)
            }
            
            new_parent_value = value
        }
        
        return new_parent_value
    }
    
    
    
    public func supports(_ object: AnyObject) -> Bool {
        var is_supported: Bool = false
        
        if let unwrapped_value = object as? NSValue {
            if (MotionSupport.matchesObjCType(forValue: unwrapped_value, typeToMatch: ValueStructTypes.uiEdgeInsets.toObjCType())
                || MotionSupport.matchesObjCType(forValue: unwrapped_value, typeToMatch: ValueStructTypes.uiOffset.toObjCType())
                ) {
                
                is_supported = true
            }
        }
        return is_supported
    }
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        var accepts = false
        
        if (object is UIEdgeInsets || object is UIOffset) {
            accepts = true
        }
        
        return accepts
    }
    
    
    // MARK: Static methods
    
    /// Determines the type of struct represented by a NSValue object.
    public static func determineType(forValue value: NSValue) -> ValueStructTypes {
        let type: ValueStructTypes
        
        if MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.uiEdgeInsets.toObjCType()) {
            type = ValueStructTypes.uiEdgeInsets
        } else if MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.uiOffset.toObjCType()) {
            type = ValueStructTypes.uiOffset
        } else {
            type = ValueStructTypes.unsupported
        }
        
        
        return type
    }
    
    
    static func valueForStruct(_ cfStruct: Any) -> NSValue? {
        var value: NSValue?
        
        let insets = UIEdgeInsets.zero
        let offset = UIOffset.zero
        
        if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: insets))) {
            value = NSValue.init(uiEdgeInsets: (cfStruct as! UIEdgeInsets))
            
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: offset))) {
            value = NSValue.init(uiOffset: (cfStruct as! UIOffset))
        }
        
        return value
    }
    
    
    // MARK: Private methods

    func updateStruct(_ structValue: inout NSValue, type: ValueStructTypes, newValues: Dictionary<String, Double>) {
        
        guard newValues.count > 0 else { return }
        
        switch type {
        case .uiEdgeInsets:
            var insets = structValue.uiEdgeInsetsValue
            
            for (prop, newValue) in newValues {
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "top") {
                    applyTo(value: &insets.top, newValue: CGFloat(newValue))
                    
                } else if (last_component == "left") {
                    applyTo(value: &insets.left, newValue: CGFloat(newValue))
                    
                } else if (last_component == "bottom") {
                    applyTo(value: &insets.bottom, newValue: CGFloat(newValue))

                } else if (last_component == "right") {
                    applyTo(value: &insets.right, newValue: CGFloat(newValue))
                }
            }
            
            structValue = NSValue.init(uiEdgeInsets: insets)
            
        case .uiOffset:
            var offset = structValue.uiOffsetValue
            
            for (prop, newValue) in newValues {
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "horizontal") {
                    applyTo(value: &offset.horizontal, newValue: CGFloat(newValue))
                    
                } else if (last_component == "vertical") {
                    applyTo(value: &offset.vertical, newValue: CGFloat(newValue))
                }
            }
            
            structValue = NSValue.init(uiOffset: offset)
            
        case .unsupported: break
            
        default: break
        }
        
    }
    
    
    func retrieveStructValue(_ structValue: NSValue, type: ValueStructTypes, path: String) -> Double? {
        
        var retrieved_value: Double?
        
        switch type {
        case .uiEdgeInsets:
            let insets = structValue.uiEdgeInsetsValue
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "top") {
                retrieved_value = Double(insets.top)
                
            } else if (last_component == "left") {
                retrieved_value = Double(insets.left)
                
            } else if (last_component == "bottom") {
                retrieved_value = Double(insets.bottom)
                
            } else if (last_component == "right") {
                retrieved_value = Double(insets.right)
            }
            
        case .uiOffset:
            let offset = structValue.uiOffsetValue
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "horizontal") {
                retrieved_value = Double(offset.horizontal)
                
            } else if (last_component == "vertical") {
                retrieved_value = Double(offset.vertical)
            }
            
        case .unsupported: break
            
        default:
            break
        }
        
        
        return retrieved_value
    }
    
    


    
}

