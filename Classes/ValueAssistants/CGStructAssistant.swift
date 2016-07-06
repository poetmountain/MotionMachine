//
//  CGStructAssistant.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/18/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
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
import CoreGraphics
import QuartzCore

#if os(iOS) || os(tvOS)
import UIKit
#endif

/// CGStructAssistant provides support for several Core Graphics struct types, including `CGPoint`, `CGSize`, `CGRect`, `CGVector`, `CGAffineTransform`, as well as QuartzCore's `CATransform3D` type. It also provides support for the `NSNumber` type.
public class CGStructAssistant : ValueAssistant {
    
    public var additive: Bool = false
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
        }
    }
    
    
    // MARK: ValueAssistant methods
    
    public func generateProperties(fromObject object: AnyObject, keyPath path: String, targetObject target: AnyObject) throws -> [PropertyData] {
        var properties: [PropertyData] = []

        guard let value = object as? NSValue else { throw ValueAssistantError.typeRequirement("NSValue") }

        let value_type = CGStructAssistant.determineType(forValue: value)
        
        switch value_type {
        case .number:
            let number = value as! NSNumber
            let property = PropertyData(path, number.doubleValue)
            properties.append(property)
            
        case .point:
            var base_path: String = path + "."
            var org_x: Double?
            var org_y: Double?

            if let unwrapped_nsvalue = target as? NSValue {
                let type = CGStructAssistant.determineType(forValue: unwrapped_nsvalue)
                if (type == .point) {
                    let org_pt = unwrapped_nsvalue.cgPointValue()
                    org_x = Double(org_pt.x)
                    org_y = Double(org_pt.y)
                }
            }
            #if os(iOS) || os(tvOS)
            if let unwrapped_view = target as? UIView {
                    base_path = "origin."
                    org_x = Double(unwrapped_view.frame.origin.x)
                    org_y = Double(unwrapped_view.frame.origin.y)
            }
            #endif
            
            let pt = value.cgPointValue()
            
            if let unwrapped_x = org_x {
                if (Double(pt.x) !≈ unwrapped_x) {
                    var prop_x = PropertyData("x", Double(pt.x))
                    prop_x.path = base_path + prop_x.path
                    
                    properties.append(prop_x)
                }
            }
            if let unwrapped_y = org_y {
                if (Double(pt.y) !≈ unwrapped_y) {
                    var prop_y = PropertyData("y", Double(pt.y))
                    prop_y.path = base_path + prop_y.path
                    
                    properties.append(prop_y)
                }
            }
            
        case .size:
            var base_path: String = path + "."
            var org_w: Double?
            var org_h: Double?
            
            #if os(iOS) || os(tvOS)
            if let unwrapped_view = target as? UIView {
                base_path = "size."
                org_w = Double(unwrapped_view.frame.size.width)
                org_h = Double(unwrapped_view.frame.size.height)
            }
            #endif
            if let unwrapped_nsvalue = target as? NSValue {
                let type = CGStructAssistant.determineType(forValue: unwrapped_nsvalue)
                if (type == .size) {
                    let org_size = unwrapped_nsvalue.cgSizeValue()
                    org_w = Double(org_size.width)
                    org_h = Double(org_size.height)
                }
            }
            let size = value.cgSizeValue()
            if let unwrapped_w = org_w {
                if (Double(size.width) !≈ unwrapped_w) {
                    var prop_w = PropertyData("width", Double(size.width))
                    prop_w.path = base_path + prop_w.path
                    
                    properties.append(prop_w)
                }
            }
            if let unwrapped_h = org_h {
                if (Double(size.height) !≈ unwrapped_h) {
                    var prop_h = PropertyData("height", Double(size.height))
                    prop_h.path = base_path + prop_h.path
                    
                    properties.append(prop_h)
                }
            }
            
            
        case .rect:
            var base_path: String = path + "."
            #if os(iOS) || os(tvOS)
            if (target is UIView && path == "") {
                base_path = "frame."
            }
            #endif
            let rect = value.cgRectValue()
            let pt_value = NSValue.init(cgPoint: rect.origin)
            var target_pt: NSValue?
            var target_size: NSValue?
            
            #if os(iOS) || os(tvOS)
            if let unwrapped_view = target as? UIView {
                target_pt = NSValue.init(cgPoint: unwrapped_view.frame.origin)
                target_size = NSValue.init(cgSize: unwrapped_view.frame.size)
            }
            #endif
            if let unwrapped_value = target as? NSValue {
                let target_rect = unwrapped_value.cgRectValue()
                target_pt = NSValue.init(cgPoint: target_rect.origin)
                target_size = NSValue.init(cgSize: target_rect.size)
            }
            if let unwrapped_pt = target_pt {
                do {
                    var pt_props = try generateProperties(fromObject: pt_value, keyPath: "", targetObject: unwrapped_pt)
                    var mid_path = ""
                    if (target is NSValue) {
                        mid_path = "origin"
                    }
                    for index in 0 ..< pt_props.count {
                        pt_props[index].path = base_path + mid_path + pt_props[index].path
                    }
                    properties.append(contentsOf: pt_props)
                    
                } catch ValueAssistantError.typeRequirement(let valueType) {
                    ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)
                    
                    return properties
                }
                
            }
            
            if let unwrapped_size = target_size {
                let size_value = NSValue.init(cgSize: rect.size)
                
                do {
                    var size_props = try generateProperties(fromObject: size_value, keyPath: "", targetObject: unwrapped_size)
                    var mid_path = ""
                    if (target is NSValue) {
                        mid_path = "size"
                    }
                    for index in 0 ..< size_props.count {
                        size_props[index].path = base_path + mid_path + size_props[index].path
                    }
                    properties.append(contentsOf: size_props)
                    
                } catch ValueAssistantError.typeRequirement(let valueType) {
                    ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)
                    
                    return properties
                }

            }
            
        case .vector:
            var org_dx: Double?
            var org_dy: Double?
            if (target is NSValue) {
                let type = CGStructAssistant.determineType(forValue: target as! NSValue)
                if (type == .vector) {
                    let org_vec = (target as! NSValue).cgVectorValue()
                    org_dx = Double(org_vec.dx)
                    org_dy = Double(org_vec.dy)
                }
            }
            let vector = value.cgVectorValue()
            if let unwrapped_dx = org_dx {
                if (Double(vector.dx) !≈ unwrapped_dx) {
                    let prop_dx = PropertyData(path + ".dx", Double(vector.dx))
                    properties.append(prop_dx)
                }
            }
            if let unwrapped_dy = org_dy {
                if (Double(vector.dy) !≈ unwrapped_dy) {
                    let prop_dy = PropertyData(path + ".dy", Double(vector.dy))
                    properties.append(prop_dy)
                }
            }
            
        case .affineTransform:
            var oa: Double?
            var ob: Double?
            var oc: Double?
            var od: Double?
            var otx: Double?
            var oty: Double?
            if let unwrapped_value = target as? NSValue {
                let type = CGStructAssistant.determineType(forValue: unwrapped_value)
                if (type == .affineTransform) {
                    let org_t = unwrapped_value.cgAffineTransform()
                    oa = Double(org_t.a)
                    ob = Double(org_t.b)
                    oc = Double(org_t.c)
                    od = Double(org_t.d)
                    otx = Double(org_t.tx)
                    oty = Double(org_t.ty)
                }
            }
            
            // find all transform properties
            let transform = value.cgAffineTransform()
            let base_path = path + "."
            if let ua = oa {
                if (Double(transform.a) !≈ ua) {
                    let p = PropertyData(base_path + "a", Double(transform.a))
                    properties.append(p)
                }
            }
            if let ub = ob {
                if (Double(transform.b) !≈ ub) {
                    let p = PropertyData(base_path + "b", Double(transform.b))
                    properties.append(p)
                }
            }
            if let uc = oc {
                if (Double(transform.c) !≈ uc) {
                    let p = PropertyData(base_path + "c", Double(transform.c))
                    properties.append(p)
                }
            }
            if let ud = od {
                if (Double(transform.d) !≈ ud) {
                    let p = PropertyData(base_path + "d", Double(transform.d))
                    properties.append(p)
                }
            }
            if let utx = otx {
                if (Double(transform.tx) !≈ utx) {
                    let p = PropertyData(base_path + "tx", Double(transform.tx))
                    properties.append(p)
                }
            }
            if let uty = oty {
                if (Double(transform.ty) !≈ uty) {
                    let p = PropertyData(base_path + "ty", Double(transform.ty))
                    properties.append(p)
                }
            }
            
        case .transform3D:
            var o11: Double?, o12: Double?, o13: Double?, o14: Double?
            var o21: Double?, o22: Double?, o23: Double?, o24: Double?
            var o31: Double?, o32: Double?, o33: Double?, o34: Double?
            var o42: Double?, o43: Double?, o44: Double?
            if let unwrapped_value = target as? NSValue {
                let type = CGStructAssistant.determineType(forValue: unwrapped_value)
                if (type == .transform3D) {
                    let org_t = unwrapped_value.caTransform3DValue
                    o11 = Double(org_t.m11)
                    o12 = Double(org_t.m12)
                    o13 = Double(org_t.m13)
                    o14 = Double(org_t.m14)
                    o21 = Double(org_t.m21)
                    o22 = Double(org_t.m22)
                    o23 = Double(org_t.m23)
                    o24 = Double(org_t.m24)
                    o31 = Double(org_t.m31)
                    o32 = Double(org_t.m32)
                    o33 = Double(org_t.m33)
                    o34 = Double(org_t.m34)
                    o42 = Double(org_t.m42)
                    o43 = Double(org_t.m43)
                    o44 = Double(org_t.m44)
                }
            }
            let base_path = path + "."
            
            let transform = value.caTransform3DValue
            if let u11 = o11 {
                let double_val = Double(transform.m11)
                if (double_val !≈ u11) {
                    let p = PropertyData(base_path + "m11", double_val)
                    properties.append(p)
                }
            }
            if let u12 = o12 {
                let double_val = Double(transform.m12)
                if (double_val !≈ u12) {
                    let p = PropertyData(base_path + "m12", double_val)
                    properties.append(p)
                }
            }
            if let u13 = o13 {
                let double_val = Double(transform.m13)
                if (double_val !≈ u13) {
                    let p = PropertyData(base_path + "m13", double_val)
                    properties.append(p)
                }
            }
            if let u14 = o14 {
                let double_val = Double(transform.m14)
                if (double_val !≈ u14) {
                    let p = PropertyData(base_path + "m14", double_val)
                    properties.append(p)
                }
            }
            if let u21 = o21 {
                let double_val = Double(transform.m21)
                if (double_val !≈ u21) {
                    let p = PropertyData(base_path + "m21", double_val)
                    properties.append(p)
                }
            }
            if let u22 = o22 {
                let double_val = Double(transform.m22)
                if (double_val !≈ u22) {
                    let p = PropertyData(base_path + "m22", double_val)
                    properties.append(p)
                }
            }
            if let u23 = o23 {
                let double_val = Double(transform.m23)
                if (double_val !≈ u23) {
                    let p = PropertyData(base_path + "m23", double_val)
                    properties.append(p)
                }
            }
            if let u24 = o24 {
                let double_val = Double(transform.m24)
                if (double_val !≈ u24) {
                    let p = PropertyData(base_path + "m24", double_val)
                    properties.append(p)
                }
            }
            if let u31 = o31 {
                let double_val = Double(transform.m31)
                if (double_val !≈ u31) {
                    let p = PropertyData(base_path + "m31", double_val)
                    properties.append(p)
                }
            }
            if let u32 = o32 {
                let double_val = Double(transform.m32)
                if (double_val !≈ u32) {
                    let p = PropertyData(base_path + "m32", double_val)
                    properties.append(p)
                }
            }
            if let u33 = o33 {
                let double_val = Double(transform.m33)
                if (double_val !≈ u33) {
                    let p = PropertyData(base_path + "m33", double_val)
                    properties.append(p)
                }
            }
            if let u34 = o34 {
                let double_val = Double(transform.m34)
                if (double_val !≈ u34) {
                    let p = PropertyData(base_path + "m34", double_val)
                    properties.append(p)
                }
            }
            if let u42 = o42 {
                let double_val = Double(transform.m42)
                if (double_val !≈ u42) {
                    let p = PropertyData(base_path + "m42", double_val)
                    properties.append(p)
                }
            }
            if let u43 = o43 {
                let double_val = Double(transform.m43)
                if (double_val !≈ u43) {
                    let p = PropertyData(base_path + "m43", double_val)
                    properties.append(p)
                }
            }
            if let u44 = o44 {
                let double_val = Double(transform.m44)
                if (double_val !≈ u44) {
                    let p = PropertyData(base_path + "m44", double_val)
                    properties.append(p)
                }
            }
            
        case .unsupported: break
            
        default: break
        }
        
        return properties
    }
    
    
    
    
    public func retrieveValue(inObject object: AnyObject, keyPath path: String) throws -> Double? {
        
        var retrieved_value: Double?
        
        guard let value = object as? NSValue else { throw ValueAssistantError.typeRequirement("NSValue") }
        
        if let unwrapped_number = value as? NSNumber {
            retrieved_value = unwrapped_number.doubleValue
            
        } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.point.toObjCType())) {
            
            retrieved_value = retrieveStructValue(value, type: .point, path: path)
            
        } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.size.toObjCType())) {
            
            retrieved_value = retrieveStructValue(value, type: .size, path: path)
            
        } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.rect.toObjCType())) {
            
            retrieved_value = retrieveStructValue(value, type: .rect, path: path)
            
        } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.vector.toObjCType())) {
            
            retrieved_value = retrieveStructValue(value, type: .vector, path: path)
            
        } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.affineTransform.toObjCType())) {
            
            retrieved_value = retrieveStructValue(value, type: .affineTransform, path: path)
            
        } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.transform3D.toObjCType())) {
            
            retrieved_value = retrieveStructValue(value, type: .transform3D, path: path)
            
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
    
    
    
    
    public func updateValue(inObject object: AnyObject, newValues: Dictionary<String, Double>) -> NSObject? {
        
        guard newValues.count > 0 else { return nil }
        
        var new_parent_value:NSObject?
        
        var new_value = newValues.values.first!
        
        if let unwrapped_double = object as? Double {
            if (additive) {
                new_value = unwrapped_double + new_value
            }
            
            new_parent_value = Double(new_value)
            
        } else if let unwrapped_value = object as? NSValue {
            var value = unwrapped_value
            
            if let unwrapped_number = value as? NSNumber {
                if (additive) {
                    new_value = unwrapped_number.doubleValue + new_value
                }
                
                new_parent_value = NSNumber.init(value: new_value)
                
            } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.point.toObjCType())) {
                
                updateStruct(&value, type: .point, newValues: newValues)
                
            } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.size.toObjCType())) {
                
                updateStruct(&value, type: .size, newValues: newValues)
                
            } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.rect.toObjCType())) {
                
                updateStruct(&value, type: .rect, newValues: newValues)
                
            } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.vector.toObjCType())) {
                
                updateStruct(&value, type: .vector, newValues: newValues)
                
            } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.affineTransform.toObjCType())) {
                
                updateStruct(&value, type: .affineTransform, newValues: newValues)
                
            } else if (MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.transform3D.toObjCType())) {
                
                updateStruct(&value, type: .transform3D, newValues: newValues)
                
            }
            
            new_parent_value = value

        }
        
        return new_parent_value
    }
    
    
    
    public func supports(_ object: AnyObject) -> Bool {
        var is_supported: Bool = false
        
        if (object is Double || object is Int || object is UInt) {
            is_supported = true
            
        } else if let unwrapped_value = object as? NSValue {

            if (unwrapped_value is NSNumber
                || MotionSupport.matchesObjCType(forValue: unwrapped_value, typeToMatch: ValueStructTypes.point.toObjCType())
                || MotionSupport.matchesObjCType(forValue: unwrapped_value, typeToMatch: ValueStructTypes.size.toObjCType())
                || MotionSupport.matchesObjCType(forValue: unwrapped_value, typeToMatch: ValueStructTypes.rect.toObjCType())
                || MotionSupport.matchesObjCType(forValue: unwrapped_value, typeToMatch: ValueStructTypes.vector.toObjCType())
                || MotionSupport.matchesObjCType(forValue: unwrapped_value, typeToMatch: ValueStructTypes.affineTransform.toObjCType())
                || MotionSupport.matchesObjCType(forValue: unwrapped_value, typeToMatch: ValueStructTypes.transform3D.toObjCType())
                ) {
                
                is_supported = true
                
            }
            
        }
        
        return is_supported
    }
    
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        var accepts = false

        if (object is NSObject || object is CGPoint || object is CGSize || object is CGRect || object is CGVector || object is CGAffineTransform || object is CATransform3D) {
            accepts = true
        }

        return accepts
    }
    
    
    
    // MARK: Static methods
    
    /// Determines the type of struct represented by a NSValue object.
    static func determineType(forValue value: NSValue) -> ValueStructTypes {
        let type: ValueStructTypes
        
        if (value is NSNumber) {
            type = ValueStructTypes.number
        } else if MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.point.toObjCType()) {
            type = ValueStructTypes.point
        } else if MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.size.toObjCType()) {
            type = ValueStructTypes.size
        } else if MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.rect.toObjCType()) {
            type = ValueStructTypes.rect
        } else if MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.vector.toObjCType()) {
            type = ValueStructTypes.vector
        } else if MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.affineTransform.toObjCType()) {
            type = ValueStructTypes.affineTransform
        } else if MotionSupport.matchesObjCType(forValue: value, typeToMatch: ValueStructTypes.transform3D.toObjCType()) {
            type = ValueStructTypes.transform3D
        } else {
            type = ValueStructTypes.unsupported
        }
        
        return type
    }
    
    
    static func valueForCGStruct(_ cfStruct: Any) -> NSValue? {
        var value: NSValue?
        
        let num = NSNumber.init(value: 0)
        let pt = CGPoint.zero
        let size = CGSize.zero
        let rect = CGRect.zero
        let vector = CGVector(dx: 0.0, dy: 0.0)
        let transform = CGAffineTransform.identity
        let transform3D = CATransform3DIdentity
        
        if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: num.dynamicType)) {
            // cast numeric value to a double
            let double_value = MotionSupport.cast(cfStruct as! AnyObject)
            if let doub = double_value {
                value = NSNumber.init(value: doub)
            }
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: pt.dynamicType)) {
            value = NSValue.init(cgPoint: (cfStruct as! CGPoint))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: size.dynamicType)) {
            value = NSValue.init(cgSize: (cfStruct as! CGSize))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: rect.dynamicType)) {
            value = NSValue.init(cgRect: (cfStruct as! CGRect))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: vector.dynamicType)) {
            value = NSValue.init(cgVector: (cfStruct as! CGVector))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: transform.dynamicType)) {
            value = NSValue.init(cgAffineTransform: (cfStruct as! CGAffineTransform))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: transform3D.dynamicType)) {
            value = NSValue.init(caTransform3D: (cfStruct as! CATransform3D))
        }
        
        return value
    }
    
    
    static func isCGStruct(forValue value: Any) -> Bool {
        var is_supported = false
        
        let pt = CGPoint.zero
        let size = CGSize.zero
        let rect = CGRect.zero
        let vector = CGVector(dx: 0.0, dy: 0.0)
        let transform = CGAffineTransform.identity
        let transform3D = CATransform3DIdentity
        if (MotionSupport.matchesType(forValue: value, typeToMatch: pt.dynamicType)
            || MotionSupport.matchesType(forValue: value, typeToMatch: size.dynamicType)
            || MotionSupport.matchesType(forValue: value, typeToMatch: rect.dynamicType)
            || MotionSupport.matchesType(forValue: value, typeToMatch: vector.dynamicType)
            || MotionSupport.matchesType(forValue: value, typeToMatch: transform.dynamicType)
            || MotionSupport.matchesType(forValue: value, typeToMatch: transform3D.dynamicType)
            ) {
            is_supported = true
        }
        
        return is_supported
    }
    
    
    

    // MARK: Private Methods
    
    func updateStruct(_ structValue: inout NSValue, type: ValueStructTypes, newValues: Dictionary<String, Double>) {
                
        guard newValues.count > 0 else { return }
        
        switch type {
        case .number:
            if let unwrapped_number = structValue as? NSNumber {
                var val = unwrapped_number.doubleValue
                if (additive) {
                    val += newValues.values.first!
                } else {
                    val = newValues.values.first!
                }
                structValue = NSNumber.init(value: val)
            }
            
        case .point:
            var point = structValue.cgPointValue()
            
            for (prop, newValue) in newValues {
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "x") {
                    applyTo(value: &point.x, newValue: CGFloat(newValue))
                    
                } else if (last_component == "y") {
                    applyTo(value: &point.y, newValue: CGFloat(newValue))
                }
            }
            
            structValue = NSValue.init(cgPoint: point)
            
        case .size:
            var size = structValue.cgSizeValue()
            
            for (prop, newValue) in newValues {
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "width") {
                    applyTo(value: &size.width, newValue: CGFloat(newValue))
                    
                } else if (last_component == "height") {
                    applyTo(value: &size.height, newValue: CGFloat(newValue))
                }
            }
            
            structValue = NSValue.init(cgSize: size)
            
            
        case .rect:
            var rect = structValue.cgRectValue()
            let keys = Array(newValues.keys)
            
            let last_components: [String] = keys.map { (str) -> String in
                let components = str.components(separatedBy: ".")
                return components.last!
            }
            
            if (last_components.containsAny(["x", "y"])) {
                var pt_value = NSValue.init(cgPoint: rect.origin)
                updateStruct(&pt_value, type: .point, newValues: newValues)
                
                rect.origin = pt_value.cgPointValue()
            }
            
            if (last_components.containsAny(["width", "height"])) {
                var size_value = NSValue.init(cgSize: rect.size)
                updateStruct(&size_value, type: .size, newValues: newValues)
                
                rect.size = size_value.cgSizeValue()
            }
            
            structValue = NSValue.init(cgRect: rect)
            
            
        case .vector:
            var vector = structValue.cgVectorValue()
            
            for (prop, newValue) in newValues {
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "dx") {
                    applyTo(value: &vector.dx, newValue: CGFloat(newValue))
                    
                } else if (last_component == "dy") {
                    applyTo(value: &vector.dy, newValue: CGFloat(newValue))
                }
            }
            
            structValue = NSValue.init(cgVector: vector)
            
        case .affineTransform:
            var transform = structValue.cgAffineTransform()
            
            for (prop, newValue) in newValues {
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "a") {
                    applyTo(value: &transform.a, newValue: CGFloat(newValue))
                } else if (last_component == "b") {
                    applyTo(value: &transform.b, newValue: CGFloat(newValue))
                } else if (last_component == "c") {
                    applyTo(value: &transform.c, newValue: CGFloat(newValue))
                } else if (last_component == "d") {
                    applyTo(value: &transform.d, newValue: CGFloat(newValue))
                } else if (last_component == "tx") {
                    applyTo(value: &transform.tx, newValue: CGFloat(newValue))
                } else if (last_component == "ty") {
                    applyTo(value: &transform.ty, newValue: CGFloat(newValue))
                }
            }
            
            structValue = NSValue.init(cgAffineTransform: transform)
            
        case .transform3D:
            var transform = structValue.caTransform3DValue
            
            for (prop, newValue) in newValues {
                let last_component = lastComponent(forPath: prop)
                
                if (last_component == "m11") {
                    applyTo(value: &transform.m11, newValue: CGFloat(newValue))
                } else if (last_component == "m12") {
                    applyTo(value: &transform.m12, newValue: CGFloat(newValue))
                } else if (last_component == "m13") {
                    applyTo(value: &transform.m13, newValue: CGFloat(newValue))
                } else if (last_component == "m14") {
                    applyTo(value: &transform.m14, newValue: CGFloat(newValue))
                } else if (last_component == "m21") {
                    applyTo(value: &transform.m21, newValue: CGFloat(newValue))
                } else if (last_component == "m22") {
                    applyTo(value: &transform.m22, newValue: CGFloat(newValue))
                } else if (last_component == "m23") {
                    applyTo(value: &transform.m23, newValue: CGFloat(newValue))
                } else if (last_component == "m24") {
                    applyTo(value: &transform.m24, newValue: CGFloat(newValue))
                } else if (last_component == "m31") {
                    applyTo(value: &transform.m31, newValue: CGFloat(newValue))
                } else if (last_component == "m32") {
                    applyTo(value: &transform.m32, newValue: CGFloat(newValue))
                } else if (last_component == "m33") {
                    applyTo(value: &transform.m33, newValue: CGFloat(newValue))
                } else if (last_component == "m34") {
                    applyTo(value: &transform.m34, newValue: CGFloat(newValue))
                } else if (last_component == "m41") {
                    applyTo(value: &transform.m41, newValue: CGFloat(newValue))
                } else if (last_component == "m42") {
                    applyTo(value: &transform.m42, newValue: CGFloat(newValue))
                } else if (last_component == "m43") {
                    applyTo(value: &transform.m43, newValue: CGFloat(newValue))
                } else if (last_component == "m44") {
                    applyTo(value: &transform.m44, newValue: CGFloat(newValue))
                }
            }
            
            structValue = NSValue.init(caTransform3D: transform)
            
        case .unsupported: break
        
        default: break
        }
        
    }
    
    
    func retrieveStructValue(_ structValue: NSValue, type: ValueStructTypes, path: String) -> Double? {
        
        var retrieved_value: Double?
        
        switch type {
        case .number:
            if let unwrapped_number = structValue as? NSNumber {
                retrieved_value = unwrapped_number.doubleValue
            }
            
        case .point:
            let point = structValue.cgPointValue()
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "x") {
                retrieved_value = Double(point.x)
                
            } else if (last_component == "y") {
                retrieved_value = Double(point.y)
            }
            
            
        case .size:
            let size = structValue.cgSizeValue()
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "width") {
                retrieved_value = Double(size.width)
                
            } else if (last_component == "height") {
                retrieved_value = Double(size.height)
                
            }
            
            
        case .rect:
            let rect = structValue.cgRectValue()
            
            let last_component = lastComponent(forPath: path)
            
            if ([last_component].containsAny(["x", "y"])) {
                let pt_value = NSValue.init(cgPoint: rect.origin)
                
                retrieved_value = retrieveStructValue(pt_value, type: .point, path: path)
                
            } else if ([last_component].containsAny(["width", "height"])) {
                let size_value = NSValue.init(cgSize: rect.size)
                
                retrieved_value = retrieveStructValue(size_value, type: .size, path: path)
                
            }
            
            
        case .vector:
            let vector = structValue.cgVectorValue()
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "dx") {
                retrieved_value = Double(vector.dx)
                
            } else if (last_component == "dy") {
                retrieved_value = Double(vector.dy)
            }
            
            
        case .affineTransform:
            let transform = structValue.cgAffineTransform()
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "a") {
                retrieved_value = Double(transform.a)
            } else if (last_component == "b") {
                retrieved_value = Double(transform.b)
            } else if (last_component == "c") {
                retrieved_value = Double(transform.c)
            } else if (last_component == "d") {
                retrieved_value = Double(transform.d)
            } else if (last_component == "tx") {
                retrieved_value = Double(transform.tx)
            } else if (last_component == "ty") {
                retrieved_value = Double(transform.ty)
            }
            
        case .transform3D:
            let transform = structValue.caTransform3DValue
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "m11") {
                retrieved_value = Double(transform.m11)
            } else if (last_component == "m12") {
                retrieved_value = Double(transform.m12)
            } else if (last_component == "m13") {
                retrieved_value = Double(transform.m13)
            } else if (last_component == "m14") {
                retrieved_value = Double(transform.m14)
            } else if (last_component == "m21") {
                retrieved_value = Double(transform.m21)
            } else if (last_component == "m22") {
                retrieved_value = Double(transform.m22)
            } else if (last_component == "m23") {
                retrieved_value = Double(transform.m23)
            } else if (last_component == "m24") {
                retrieved_value = Double(transform.m24)
            } else if (last_component == "m31") {
                retrieved_value = Double(transform.m31)
            } else if (last_component == "m32") {
                retrieved_value = Double(transform.m32)
            } else if (last_component == "m33") {
                retrieved_value = Double(transform.m33)
            } else if (last_component == "m34") {
                retrieved_value = Double(transform.m34)
            } else if (last_component == "m41") {
                retrieved_value = Double(transform.m41)
            } else if (last_component == "m42") {
                retrieved_value = Double(transform.m42)
            } else if (last_component == "m43") {
                retrieved_value = Double(transform.m43)
            } else if (last_component == "m44") {
                retrieved_value = Double(transform.m44)
            }
            
        case .unsupported: break
            
        default: break
        }
        
        return retrieved_value
    }
    
}





