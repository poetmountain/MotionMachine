//
//  CGStructAssistant.swift
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
    
    public required init() {}
    
    
    // MARK: ValueAssistant methods
    
    public func generateProperties(targetObject target: AnyObject, propertyStates: PropertyStates) throws -> [PropertyData] {
        
        var properties: [PropertyData] = []

        guard let end_value = propertyStates.end as? NSValue else { throw ValueAssistantError.typeRequirement("NSValue") }
        var start_value: NSValue?
        var start_type: ValueStructTypes = .unsupported
        if let unwrapped_start = propertyStates.start {
            if (propertyStates.start is NSValue) {
                start_value = unwrapped_start as? NSValue
                start_type = CGStructAssistant.determineType(forValue: start_value!)
            }
        }
        
        let end_type = CGStructAssistant.determineType(forValue: end_value)

        
        switch end_type {
        case .number:
            var start_state: Double?
            if (start_value != nil && start_type == .number) {
                start_state = (start_value as! NSNumber).doubleValue
            }
            let end_state = (end_value as! NSNumber).doubleValue
            let property = PropertyData(path: propertyStates.path, start: start_state, end: end_state)
            properties.append(property)
            
        case .point:
            var base_path: String = propertyStates.path + "."
            var org_x: Double?
            var org_y: Double?

            if let unwrapped_nsvalue = target as? NSValue {
                let type = CGStructAssistant.determineType(forValue: unwrapped_nsvalue)
                if (type == .point) {
                    let org_pt = unwrapped_nsvalue.cgPointValue
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
            
            let end_pt = end_value.cgPointValue
            
            // x
            var start_state_x: Double?
            if (start_value != nil && start_type == .point) {
                start_state_x = Double(start_value!.cgPointValue.x)
            }
            
            // if we've found a starting value either via the PropertyStates object or the original target, use that,
            // otherwise omit the start parameter and let the Motion setup method deal with it (it will use the current object value)
            // if we have no start value we can't compare start to end, so just make a PropertyData anyway
            // this check is merely an optimization to avoid interpolations for value states that don't change
            // we may want to check again in Motion setup once we have a valid starting value
            if let prop = MotionSupport.buildPropertyData(path: base_path + "x", originalValue: org_x, startValue: start_state_x, endValue: Double(end_pt.x)) {
                properties.append(prop)
            }

            
            // y
            var start_state_y: Double?
            if (start_value != nil && start_type == .point) {
                start_state_y = Double(start_value!.cgPointValue.y)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "y", originalValue: org_y, startValue: start_state_y, endValue: Double(end_pt.y)) {
                properties.append(prop)
            }
     
    
            
        case .size:
            var base_path: String = propertyStates.path + "."
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
                    let org_size = unwrapped_nsvalue.cgSizeValue
                    org_w = Double(org_size.width)
                    org_h = Double(org_size.height)
                }
            }
            
            let end_size = end_value.cgSizeValue
            
            // width
            var start_state_w: Double?
            if (start_value != nil && start_type == .size) {
                start_state_w = Double(start_value!.cgSizeValue.width)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "width", originalValue: org_w, startValue: start_state_w, endValue: Double(end_size.width)) {
                properties.append(prop)
            }
            
            
            // height
            var start_state_h: Double?
            if (start_value != nil && start_type == .size) {
                start_state_h = Double(start_value!.cgSizeValue.height)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "height", originalValue: org_h, startValue: start_state_h, endValue: Double(end_size.height)) {
                properties.append(prop)
            }
            
            
        case .rect:
            var base_path: String = propertyStates.path + "."
            #if os(iOS) || os(tvOS)
            if (target is UIView && propertyStates.path == "") {
                base_path = "frame."
            }
            #endif
            let end_rect = end_value.cgRectValue
            var target_pt: NSValue?
            var target_size: NSValue?
            

            if let unwrapped_value = target as? NSValue {
                let target_rect = unwrapped_value.cgRectValue
                target_pt = NSValue.init(cgPoint: target_rect.origin)
                target_size = NSValue.init(cgSize: target_rect.size)
            }
            #if os(iOS) || os(tvOS)
                if let unwrapped_view = target as? UIView {
                    target_pt = NSValue.init(cgPoint: unwrapped_view.frame.origin)
                    target_size = NSValue.init(cgSize: unwrapped_view.frame.size)
                }
            #endif
            
            if let unwrapped_pt = target_pt {
                let end_pt_value = NSValue.init(cgPoint: end_rect.origin)

                do {
                    let start_pt: NSValue
                    if (start_value != nil && start_type == .rect) {
                        let start_rect = start_value!.cgRectValue
                        start_pt = NSValue.init(cgPoint: start_rect.origin)
                    } else {
                        start_pt = unwrapped_pt
                    }

                    let states = PropertyStates(path: "", start: start_pt, end: end_pt_value)
                    var pt_props = try generateProperties(targetObject: unwrapped_pt, propertyStates: states)
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
                let end_size_value = NSValue.init(cgSize: end_rect.size)
                
                do {
                    let start_size: NSValue
                    if (start_value != nil && start_type == .rect) {
                        let start_rect = start_value!.cgRectValue
                        start_size = NSValue.init(cgSize: start_rect.size)
                    } else {
                        start_size = unwrapped_size
                    }
                    
                    let states = PropertyStates(path: "", start: start_size, end: end_size_value)

                    var size_props = try generateProperties(targetObject: unwrapped_size, propertyStates: states)
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
            let base_path: String = propertyStates.path + "."

            var org_dx: Double?
            var org_dy: Double?
            if (target is NSValue) {
                let type = CGStructAssistant.determineType(forValue: target as! NSValue)
                if (type == .vector) {
                    let org_vec = (target as! NSValue).cgVectorValue
                    org_dx = Double(org_vec.dx)
                    org_dy = Double(org_vec.dy)
                }
            }
            let end_vector = end_value.cgVectorValue
            
            // dx
            var start_state_dx: Double?
            if (start_value != nil && start_type == .vector) {
                start_state_dx = Double(start_value!.cgVectorValue.dx)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "dx", originalValue: org_dx, startValue: start_state_dx, endValue: Double(end_vector.dx)) {
                properties.append(prop)
            }
            
            
            // dy
            var start_state_dy: Double?
            if (start_value != nil && start_type == .vector) {
                start_state_dy = Double(start_value!.cgVectorValue.dy)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "dy", originalValue: org_dy, startValue: start_state_dy, endValue: Double(end_vector.dy)) {
                properties.append(prop)
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
                    let org_t = unwrapped_value.cgAffineTransformValue
                    oa = Double(org_t.a)
                    ob = Double(org_t.b)
                    oc = Double(org_t.c)
                    od = Double(org_t.d)
                    otx = Double(org_t.tx)
                    oty = Double(org_t.ty)
                }
            }
            

            
            // find all transform properties
            let end_transform = end_value.cgAffineTransformValue
            let base_path = propertyStates.path + "."
            
            // a
            var start_state_a: Double?
            if (start_value != nil && start_type == .affineTransform) {
                start_state_a = Double(start_value!.cgAffineTransformValue.a)
            }

            if let prop = MotionSupport.buildPropertyData(path: base_path + "a", originalValue: oa, startValue: start_state_a, endValue: Double(end_transform.a)) {
                properties.append(prop)
            }
            
    
            // b
            var start_state_b: Double?
            if (start_value != nil && start_type == .affineTransform) {
                start_state_b = Double(start_value!.cgAffineTransformValue.b)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "b", originalValue: ob, startValue: start_state_b, endValue: Double(end_transform.b)) {
                properties.append(prop)
            }
            

            // c
            var start_state_c: Double?
            if (start_value != nil && start_type == .affineTransform) {
                start_state_c = Double(start_value!.cgAffineTransformValue.c)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "c", originalValue: oc, startValue: start_state_c, endValue: Double(end_transform.c)) {
                properties.append(prop)
            }
            
            
            // d
            var start_state_d: Double?
            if (start_value != nil && start_type == .affineTransform) {
                start_state_d = Double(start_value!.cgAffineTransformValue.d)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "d", originalValue: od, startValue: start_state_d, endValue: Double(end_transform.d)) {
                properties.append(prop)
            }


            // tx
            var start_state_tx: Double?
            if (start_value != nil && start_type == .affineTransform) {
                start_state_tx = Double(start_value!.cgAffineTransformValue.tx)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "tx", originalValue: otx, startValue: start_state_tx, endValue: Double(end_transform.tx)) {
                properties.append(prop)
            }
   

            // ty
            var start_state_ty: Double?
            if (start_value != nil && start_type == .affineTransform) {
                start_state_ty = Double(start_value!.cgAffineTransformValue.ty)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "ty", originalValue: oty, startValue: start_state_ty, endValue: Double(end_transform.ty)) {
                properties.append(prop)
            }
            
            
        case .transform3D:
            var o11: Double?, o12: Double?, o13: Double?, o14: Double?
            var o21: Double?, o22: Double?, o23: Double?, o24: Double?
            var o31: Double?, o32: Double?, o33: Double?, o34: Double?
            var o41: Double?, o42: Double?, o43: Double?, o44: Double?
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
                    o41 = Double(org_t.m41)
                    o42 = Double(org_t.m42)
                    o43 = Double(org_t.m43)
                    o44 = Double(org_t.m44)
                }
            }
            
            let base_path = propertyStates.path + "."
            let end_transform = end_value.caTransform3DValue
            
            // m11
            var start_state_m11: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m11 = Double(start_value!.caTransform3DValue.m11)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m11", originalValue: o11, startValue: start_state_m11, endValue: Double(end_transform.m11)) {
                properties.append(prop)
            }
            
    
            // m12
            var start_state_m12: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m12 = Double(start_value!.caTransform3DValue.m12)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m12", originalValue: o12, startValue: start_state_m12, endValue: Double(end_transform.m12)) {
                properties.append(prop)
            }

            
            // m13
            var start_state_m13: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m13 = Double(start_value!.caTransform3DValue.m13)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m13", originalValue: o13, startValue: start_state_m13, endValue: Double(end_transform.m13)) {
                properties.append(prop)
            }
            

            // m14
            var start_state_m14: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m14 = Double(start_value!.caTransform3DValue.m14)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m14", originalValue: o14, startValue: start_state_m14, endValue: Double(end_transform.m14)) {
                properties.append(prop)
            }
            

            // m21
            var start_state_m21: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m21 = Double(start_value!.caTransform3DValue.m21)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m21", originalValue: o21, startValue: start_state_m21, endValue: Double(end_transform.m21)) {
                properties.append(prop)
            }

            
            // m22
            var start_state_m22: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m22 = Double(start_value!.caTransform3DValue.m22)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m22", originalValue: o22, startValue: start_state_m22, endValue: Double(end_transform.m22)) {
                properties.append(prop)
            }
            
            
            // m23
            var start_state_m23: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m23 = Double(start_value!.caTransform3DValue.m23)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m23", originalValue: o23, startValue: start_state_m23, endValue: Double(end_transform.m23)) {
                properties.append(prop)
            }

            
            // m24
            var start_state_m24: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m24 = Double(start_value!.caTransform3DValue.m24)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m24", originalValue: o24, startValue: start_state_m24, endValue: Double(end_transform.m24)) {
                properties.append(prop)
            }
            
            // m31
            var start_state_m31: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m31 = Double(start_value!.caTransform3DValue.m31)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m31", originalValue: o31, startValue: start_state_m31, endValue: Double(end_transform.m31)) {
                properties.append(prop)
            }
            
            // m32
            var start_state_m32: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m32 = Double(start_value!.caTransform3DValue.m32)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m32", originalValue: o32, startValue: start_state_m32, endValue: Double(end_transform.m32)) {
                properties.append(prop)
            }
            
            // m33
            var start_state_m33: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m33 = Double(start_value!.caTransform3DValue.m33)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m33", originalValue: o33, startValue: start_state_m33, endValue: Double(end_transform.m33)) {
                properties.append(prop)
            }
            
            // m34
            var start_state_m34: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m34 = Double(start_value!.caTransform3DValue.m34)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m34", originalValue: o34, startValue: start_state_m34, endValue: Double(end_transform.m34)) {
                properties.append(prop)
            }
            
            // m41
            var start_state_m41: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m41 = Double(start_value!.caTransform3DValue.m41)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m41", originalValue: o41, startValue: start_state_m41, endValue: Double(end_transform.m41)) {
                properties.append(prop)
            }
            
            // m42
            var start_state_m42: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m42 = Double(start_value!.caTransform3DValue.m42)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m42", originalValue: o42, startValue: start_state_m42, endValue: Double(end_transform.m42)) {
                properties.append(prop)
            }
            
            // m43
            var start_state_m43: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m43 = Double(start_value!.caTransform3DValue.m43)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m43", originalValue: o43, startValue: start_state_m43, endValue: Double(end_transform.m43)) {
                properties.append(prop)
            }
            
            // m44
            var start_state_m44: Double?
            if (start_value != nil && start_type == .transform3D) {
                start_state_m44 = Double(start_value!.caTransform3DValue.m44)
            }
            
            if let prop = MotionSupport.buildPropertyData(path: base_path + "m44", originalValue: o44, startValue: start_state_m44, endValue: Double(end_transform.m44)) {
                properties.append(prop)
            }

            
        case .unsupported: break
            
        default: break
        }
        
        return properties
    }

    

    
    
    public func retrieveValue(inObject object: Any, keyPath path: String) throws -> Double? {
        
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
    
    
    
    
    public func updateValue(inObject object: Any, newValues: Dictionary<String, Double>) -> NSObject? {
        
        guard newValues.count > 0 else { return nil }
        
        var new_parent_value:NSObject?
        
        var new_value = newValues.values.first!
        
        if let unwrapped_double = object as? Double {
            if (additive) {
                new_value = unwrapped_double + new_value
            }
            
            new_parent_value = NSNumber.init(value: (new_value as Double))
            
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
        
        if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: num))) {
            // cast numeric value to a double
            let double_value = MotionSupport.cast(cfStruct as AnyObject)
            if let doub = double_value {
                value = NSNumber.init(value: doub)
            }
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: pt))) {
            value = NSValue.init(cgPoint: (cfStruct as! CGPoint))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: size))) {
            value = NSValue.init(cgSize: (cfStruct as! CGSize))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: rect))) {
            value = NSValue.init(cgRect: (cfStruct as! CGRect))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: vector))) {
            value = NSValue.init(cgVector: (cfStruct as! CGVector))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: transform))) {
            value = NSValue.init(cgAffineTransform: (cfStruct as! CGAffineTransform))
        } else if (MotionSupport.matchesType(forValue: cfStruct, typeToMatch: type(of: transform3D))) {
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
        if (MotionSupport.matchesType(forValue: value, typeToMatch: type(of: pt))
            || MotionSupport.matchesType(forValue: value, typeToMatch: type(of: size))
            || MotionSupport.matchesType(forValue: value, typeToMatch: type(of: rect))
            || MotionSupport.matchesType(forValue: value, typeToMatch: type(of: vector))
            || MotionSupport.matchesType(forValue: value, typeToMatch: type(of: transform))
            || MotionSupport.matchesType(forValue: value, typeToMatch: type(of: transform3D))
            ) {
            is_supported = true
        }
        
        return is_supported
    }
    
    
     /** Determines whether the keyPath targets a nested struct by traversing the keyPath and taking the value of each, starting at the top. This is useful for avoiding a runtime exception caused from calling value(forKeyPath:) on a CGRect's component.
      *
      *  - remark: If the keyPath is a single level such as "rect", the function will return false.
     *   - returns: A Bool denoting whether a nested struct is being targeted.
      */
    static func targetsNestedStruct(object: AnyObject, path: String) -> Bool {
        var nested = false
        
        let keys: [String] = path.components(separatedBy: ".")
        let key_count = keys.count
        if (key_count <= 1) { return false }
        
        // there's more than one element in the path, meaning we have a parent, so let's find the prop type
        // descend keypath tree taking the value of each searching for a CGRect
        for (index, _) in keys.enumerated() {
            let parent_keys = keys[0 ..< index]
            
            if (parent_keys.count > 0) {
                let parent_path = parent_keys.joined(separator: ".")
                
                if let parent = object.value(forKeyPath: parent_path) as AnyObject? {
                    if (parent is NSValue && CGStructAssistant.determineType(forValue: parent as! NSValue) == .rect) {
                        nested = true
                        break
                    }
                    
                }
                
            }
        }
        
        
        return nested
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
            var point = structValue.cgPointValue
            
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
            var size = structValue.cgSizeValue
            
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
            var rect = structValue.cgRectValue
            let keys = Array(newValues.keys)
            
            let last_components: [String] = keys.map { (str) -> String in
                let components = str.components(separatedBy: ".")
                return components.last!
            }
            
            if (last_components.containsAny(["x", "y"])) {
                var pt_value = NSValue.init(cgPoint: rect.origin)
                updateStruct(&pt_value, type: .point, newValues: newValues)
                
                rect.origin = pt_value.cgPointValue
            }
            
            if (last_components.containsAny(["width", "height"])) {
                var size_value = NSValue.init(cgSize: rect.size)
                updateStruct(&size_value, type: .size, newValues: newValues)
                
                rect.size = size_value.cgSizeValue
            }
            
            structValue = NSValue.init(cgRect: rect)
            
            
        case .vector:
            var vector = structValue.cgVectorValue
            
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
            var transform = structValue.cgAffineTransformValue
            
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
            let point = structValue.cgPointValue
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "x") {
                retrieved_value = Double(point.x)
                
            } else if (last_component == "y") {
                retrieved_value = Double(point.y)
            }
            
            
        case .size:
            let size = structValue.cgSizeValue
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "width") {
                retrieved_value = Double(size.width)
                
            } else if (last_component == "height") {
                retrieved_value = Double(size.height)
                
            }
            
            
        case .rect:
            let rect = structValue.cgRectValue
            
            let last_component = lastComponent(forPath: path)
            
            if ([last_component].containsAny(["x", "y"])) {
                let pt_value = NSValue.init(cgPoint: rect.origin)
                
                retrieved_value = retrieveStructValue(pt_value, type: .point, path: path)
                
            } else if ([last_component].containsAny(["width", "height"])) {
                let size_value = NSValue.init(cgSize: rect.size)
                
                retrieved_value = retrieveStructValue(size_value, type: .size, path: path)
                
            }
            
            
        case .vector:
            let vector = structValue.cgVectorValue
            
            let last_component = lastComponent(forPath: path)
            
            if (last_component == "dx") {
                retrieved_value = Double(vector.dx)
                
            } else if (last_component == "dy") {
                retrieved_value = Double(vector.dy)
            }
            
            
        case .affineTransform:
            let transform = structValue.cgAffineTransformValue
            
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





