//
//  CGStructAssistant.swift
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
#if canImport(QuartzCore)
import QuartzCore
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS) || os(watchOS)
/// CGStructAssistant provides support for several Core Graphics struct types, including `CGPoint`, `CGSize`, `CGRect`, `CGVector`, `CGAffineTransform`, as well as QuartzCore's `CATransform3D` type. It also provides support for the `NSNumber` type.
public final class CGStructAssistant<TargetType: AnyObject>: ValueAssistant {
        
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

        let nestedObject = target[keyPath: state.keyPath]
        
        var startValue: Any?
        let endValue = state.end
        
        var startType: ValueStructTypes = .unsupported
        if let statesStart = state.start {
            startValue = statesStart
            startType = CGStructAssistant.determineType(forValue: statesStart)
            
        }
        
        let endType = CGStructAssistant.determineType(forValue: endValue)

        
        switch endType {
            
        case .point:
                
            guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, CGPoint> else { return properties }
                
            var orgX: CGFloat?
            var orgY: CGFloat?

            if let point = nestedObject as? CGPoint {
                orgX = point.x
                orgY = point.y
            }
            
            let endPoint = endValue as? CGPoint
            
            // x
            var startStateX: CGFloat?
            if startType == .point, let startState = startValue as? CGPoint {
                startStateX = startState.x
            }
            
            // if we've found a starting value either via the MotionState object or the original target, use that,
            // otherwise omit the start parameter and let the Motion setup method deal with it (it will use the current object value)
            // if we have no start value we can't compare start to end, so just make a PropertyData anyway
            // this check is merely an optimization to avoid interpolations for value states that don't change
            // we may want to check again in Motion setup once we have a valid starting value
            
            let xPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGPoint.x)
            if let endX = endPoint?.x, let prop = MotionSupport.buildPropertyData(keyPath: xPath, parentPath: keyPath, originalValue: orgX, startValue: startStateX, endValue: endX, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
                

            // y
            var startStateY: CGFloat?
            if startType == .point, let startState = startValue as? CGPoint {
                startStateY = startState.y
            }
            let yPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGPoint.y)
                if let endY = endPoint?.y, let prop = MotionSupport.buildPropertyData(keyPath: yPath, parentPath: keyPath, originalValue: orgY, startValue: startStateY, endValue: endY, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
     
    
            
        case .size:
            
            guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, CGSize> else { return properties }
                
            var orgWidth: CGFloat?
            var orgHeight: CGFloat?
            
                
            if let size = nestedObject as? CGSize {
                orgWidth = size.width
                orgHeight = size.height
            }
            
            let endSize = endValue as? CGSize
            
            // width
            var startStateWidth: CGFloat?
            if startType == .size, let startState = startValue as? CGSize {
                startStateWidth = startState.width
            }
            
            let widthPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGSize.width)
            if let endWidth = endSize?.width, let prop = MotionSupport.buildPropertyData(keyPath: widthPath, parentPath: keyPath, originalValue: orgWidth, startValue: startStateWidth, endValue: endWidth, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            
            // height
            var startStateHeight: CGFloat?
            if startType == .size, let startState = startValue as? CGSize {
                startStateHeight = startState.height
            }
                
            let heightPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGSize.height)
            if let endHeight = endSize?.height, let prop = MotionSupport.buildPropertyData(keyPath: heightPath, parentPath: keyPath, originalValue: orgHeight, startValue: startStateHeight, endValue: endHeight, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            
            
        case .rect:

            guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, CGRect> else { return properties}
                
            let end_rect = endValue as? CGRect
            var target_pt: CGPoint?
            var target_size: CGSize?
            
            if let target_rect = nestedObject as? CGRect {
                target_pt = target_rect.origin
                target_size = target_rect.size
            }

            
            if let targetPoint = target_pt, let endPoint = end_rect?.origin {

                do {
                    let startPoint: CGPoint
                    if startType == .rect, let startRect = startValue as? CGRect {
                        startPoint = startRect.origin
                    } else  {
                        startPoint = targetPoint
                    }
                    
                    let originPath: ReferenceWritableKeyPath<TargetType, CGPoint> = keyPath.appending(path: \CGRect.origin)
                    let states = MotionState(keyPath: originPath, start: startPoint, end: endPoint)

                    let pointProps = try generateProperties(targetObject: target, state: states)
                    properties.append(contentsOf: pointProps)
                

                    
                } catch ValueAssistantError.typeRequirement(let valueType) {
                    ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)
                    
                    return properties
                }
                
            }
                
                
            if let targetSize = target_size, let endSize = end_rect?.size {

                do {
                    let startSize: CGSize
                    if startType == .rect, let startRect = startValue as? CGRect {
                        startSize = startRect.size
                    } else  {
                        startSize = targetSize
                    }
                    
                    let sizePath: ReferenceWritableKeyPath<TargetType, CGSize> = keyPath.appending(path: \CGRect.size)
                    let states = MotionState(keyPath: sizePath, start: startSize, end: endSize)

                    let sizeProps = try generateProperties(targetObject: target, state: states)
                    properties.append(contentsOf: sizeProps)
                

                    
                } catch ValueAssistantError.typeRequirement(let valueType) {
                    ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)
                    
                    return properties
                }
                
            }
                
            
        case .vector:

            guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, CGVector> else { return properties }
                
            var org_dx: CGFloat?
            var org_dy: CGFloat?
                
            if let vector = nestedObject as? CGVector {
                org_dx = vector.dx
                org_dy = vector.dy
            }
                
            let end_vector = endValue as? CGVector
            
            // dx
            var start_state_dx: CGFloat?
            if startType == .vector, let startState = startValue as? CGVector {
                start_state_dx = startState.dx
            }
            
            let dxPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGVector.dx)
            if let endDX = end_vector?.dx, let prop = MotionSupport.buildPropertyData(keyPath: dxPath, parentPath: keyPath, originalValue: org_dx, startValue: start_state_dx, endValue: endDX, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            
            // dy
            var start_state_dy: CGFloat?
            if startType == .vector, let startState = startValue as? CGVector {
                start_state_dy = startState.dy
            }
            
            let dyPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGVector.dy)
            if let endDY = end_vector?.dy, let prop = MotionSupport.buildPropertyData(keyPath: dyPath, parentPath: keyPath, originalValue: org_dy, startValue: start_state_dy, endValue: endDY, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
 
            
        case .affineTransform:
            
            guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, CGAffineTransform> else { return properties }
                
            var oa: CGFloat?
            var ob: CGFloat?
            var oc: CGFloat?
            var od: CGFloat?
            var otx: CGFloat?
            var oty: CGFloat?
                
            if let transform = nestedObject as? CGAffineTransform {
                oa = transform.a
                ob = transform.b
                oc = transform.c
                od = transform.d
                otx = transform.tx
                oty = transform.ty
            }
                
            let endTransform = endValue as? CGAffineTransform
            
            // find all transform properties
            
            // a
            var start_state_a: CGFloat?
            if startType == .affineTransform, let startState = startValue as? CGAffineTransform {
                start_state_a = startState.a
            }
                
            let aPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGAffineTransform.a)
            if let endProp = endTransform?.a, let prop = MotionSupport.buildPropertyData(keyPath: aPath, parentPath: keyPath, originalValue: oa, startValue: start_state_a, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
    
            // b
            var start_state_b: CGFloat?
            if startType == .affineTransform, let startState = startValue as? CGAffineTransform {
                start_state_b = startState.b
            }
                
            let bPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGAffineTransform.b)
            if let endProp = endTransform?.b, let prop = MotionSupport.buildPropertyData(keyPath: bPath, parentPath: keyPath, originalValue: ob, startValue: start_state_b, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            

            // c
            var start_state_c: CGFloat?
            if startType == .affineTransform, let startState = startValue as? CGAffineTransform {
                start_state_c = startState.c
            }
                
            let cPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGAffineTransform.c)
            if let endProp = endTransform?.c, let prop = MotionSupport.buildPropertyData(keyPath: cPath, parentPath: keyPath, originalValue: oc, startValue: start_state_c, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            
            
            // d
            var start_state_d: CGFloat?
            if startType == .affineTransform, let startState = startValue as? CGAffineTransform {
                start_state_d = startState.d
            }
                
            let dPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGAffineTransform.d)
            if let endProp = endTransform?.d, let prop = MotionSupport.buildPropertyData(keyPath: dPath, parentPath: keyPath, originalValue: od, startValue: start_state_d, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            


            // tx
            var start_state_tx: CGFloat?
            if startType == .affineTransform, let startState = startValue as? CGAffineTransform {
                start_state_tx = startState.tx
            }
                
            let txPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGAffineTransform.tx)
            if let endProp = endTransform?.tx, let prop = MotionSupport.buildPropertyData(keyPath: txPath, parentPath: keyPath, originalValue: otx, startValue: start_state_tx, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
   

            // ty
            var start_state_ty: CGFloat?
            if startType == .affineTransform, let startState = startValue as? CGAffineTransform {
                start_state_ty = startState.ty
            }
                
            let tyPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CGAffineTransform.ty)
            if let endProp = endTransform?.ty, let prop = MotionSupport.buildPropertyData(keyPath: tyPath, parentPath: keyPath, originalValue: oty, startValue: start_state_ty, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            
#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
        case .transform3D:
                
            guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, CATransform3D> else { return properties }
                
            var o11: CGFloat?, o12: CGFloat?, o13: CGFloat?, o14: CGFloat?
            var o21: CGFloat?, o22: CGFloat?, o23: CGFloat?, o24: CGFloat?
            var o31: CGFloat?, o32: CGFloat?, o33: CGFloat?, o34: CGFloat?
            var o41: CGFloat?, o42: CGFloat?, o43: CGFloat?, o44: CGFloat?
                
            if let transform = nestedObject as? CATransform3D {
                o11 = transform.m11
                o12 = transform.m12
                o13 = transform.m13
                o14 = transform.m14
                o21 = transform.m21
                o22 = transform.m22
                o23 = transform.m23
                o24 = transform.m24
                o31 = transform.m31
                o32 = transform.m32
                o33 = transform.m33
                o34 = transform.m34
                o41 = transform.m41
                o42 = transform.m42
                o43 = transform.m43
                o44 = transform.m44
            }
                            
            let endTransform = endValue as? CATransform3D
            
            // m11
                
            var start_state_m11: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m11 = startState.m11
            }
                
            let m11Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m11)
            if let endProp = endTransform?.m11, let prop = MotionSupport.buildPropertyData(keyPath: m11Path, parentPath: keyPath, originalValue: o11, startValue: start_state_m11, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            

    
            // m12
            var start_state_m12: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m12 = startState.m12
            }
            
            let m12Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m12)
            if let endProp = endTransform?.m12, let prop = MotionSupport.buildPropertyData(keyPath: m12Path, parentPath: keyPath, originalValue: o12, startValue: start_state_m12, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            

            
            // m13
            var start_state_m13: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m13 = startState.m13
            }
            
            let m13Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m13)
            if let endProp = endTransform?.m13, let prop = MotionSupport.buildPropertyData(keyPath: m13Path, parentPath: keyPath, originalValue: o13, startValue: start_state_m13, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            

            // m14
            var start_state_m14: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m14 = startState.m14
            }
            
            let m14Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m14)
            if let endProp = endTransform?.m14, let prop = MotionSupport.buildPropertyData(keyPath: m14Path, parentPath: keyPath, originalValue: o14, startValue: start_state_m14, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            

            // m21
            var start_state_m21: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m21 = startState.m21
            }
            
            let m21Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m21)
            if let endProp = endTransform?.m21, let prop = MotionSupport.buildPropertyData(keyPath: m21Path, parentPath: keyPath, originalValue: o21, startValue: start_state_m21, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }

            
            // m22
            var start_state_m22: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m22 = startState.m22
            }
            
            let m22Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m22)
            if let endProp = endTransform?.m22, let prop = MotionSupport.buildPropertyData(keyPath: m22Path, parentPath: keyPath, originalValue: o22, startValue: start_state_m22, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            
            // m23
            var start_state_m23: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m23 = startState.m23
            }
            
            let m23Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m23)
            if let endProp = endTransform?.m23, let prop = MotionSupport.buildPropertyData(keyPath: m23Path, parentPath: keyPath, originalValue: o23, startValue: start_state_m23, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }

            
            // m24
            var start_state_m24: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m24 = startState.m24
            }

            let m24Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m24)
            if let endProp = endTransform?.m24, let prop = MotionSupport.buildPropertyData(keyPath: m24Path, parentPath: keyPath, originalValue: o24, startValue: start_state_m24, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            // m31
            var start_state_m31: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m31 = startState.m31
            }
            
            let m31Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m31)
            if let endProp = endTransform?.m31, let prop = MotionSupport.buildPropertyData(keyPath: m31Path, parentPath: keyPath, originalValue: o31, startValue: start_state_m31, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            // m32
            var start_state_m32: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m32 = startState.m32
            }
            
            let m32Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m32)
            if let endProp = endTransform?.m32, let prop = MotionSupport.buildPropertyData(keyPath: m32Path, parentPath: keyPath, originalValue: o32, startValue: start_state_m32, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            // m33
            var start_state_m33: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m33 = startState.m33
            }
            
            let m33Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m33)
            if let endProp = endTransform?.m33, let prop = MotionSupport.buildPropertyData(keyPath: m33Path, parentPath: keyPath, originalValue: o33, startValue: start_state_m33, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            // m34
            var start_state_m34: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m34 = startState.m34
            }
            
            let m34Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m34)
            if let endProp = endTransform?.m34, let prop = MotionSupport.buildPropertyData(keyPath: m34Path, parentPath: keyPath, originalValue: o34, startValue: start_state_m34, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            // m41
            var start_state_m41: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m41 = startState.m41
            }
            
            let m41Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m41)
            if let endProp = endTransform?.m41, let prop = MotionSupport.buildPropertyData(keyPath: m41Path, parentPath: keyPath, originalValue: o41, startValue: start_state_m41, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            // m42
            var start_state_m42: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m42 = startState.m42
            }
            
            let m42Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m42)
            if let endProp = endTransform?.m42, let prop = MotionSupport.buildPropertyData(keyPath: m42Path, parentPath: keyPath, originalValue: o42, startValue: start_state_m42, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            // m43
            var start_state_m43: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m43 = startState.m43
            }
            
            let m43Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m43)
            if let endProp = endTransform?.m43, let prop = MotionSupport.buildPropertyData(keyPath: m43Path, parentPath: keyPath, originalValue: o43, startValue: start_state_m43, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }
            
            // m44
            var start_state_m44: CGFloat?
            if startType == .transform3D, let startState = startValue as? CATransform3D {
                start_state_m44 = startState.m44
            }
            
            let m44Path: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \CATransform3D.m44)
            if let endProp = endTransform?.m44, let prop = MotionSupport.buildPropertyData(keyPath: m44Path, parentPath: keyPath, originalValue: o44, startValue: start_state_m44, endValue: endProp, isAdditive: isAdditive) {
                
                properties.append(prop)
            }

#endif
        case .unsupported: break
            
        default: break
        }
        
        return properties
    }

    
    @discardableResult public func update(property: PropertyData<TargetType>, newValue: Double) -> Any? {
        guard let targetObject = property.targetObject else { return nil }
        
        var newPropertyValue = newValue
        var currentValue: Any?

        currentValue = property.retrieveValue(from: targetObject)
        
        if (isAdditive), let currentValue {
            if let currentValue = currentValue as? any BinaryFloatingPoint, let current = currentValue.toDouble() {
                newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
                
            } else if let currentValue = currentValue as? any BinaryInteger, let current = currentValue.toDouble() {
                newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
            }
        }
        
        property.apply(value: newPropertyValue, to: targetObject)
        
        
        return newPropertyValue
        
    }
    
    
    public func supports(_ object: Any) -> Bool {
        var is_supported: Bool = false
        
#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
        if (object is CGPoint
            || object is CGSize
            || object is CGRect
            || object is CGVector
            || object is CGAffineTransform
            || object is CATransform3D
        ) {
            is_supported = true
        }
#endif

#if os(watchOS)
        if (object is CGPoint
            || object is CGSize
            || object is CGRect
            || object is CGVector
            || object is CGAffineTransform
        ) {
            is_supported = true
        }
#endif
        
        return is_supported
    }
    
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        var accepts = false

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
        if (object is CGPoint || object is CGSize || object is CGRect || object is CGVector || object is CGAffineTransform || object is CATransform3D) {
            accepts = true
        }
#endif

#if os(watchOS)
        if (object is CGPoint || object is CGSize || object is CGRect || object is CGVector || object is CGAffineTransform) {
            accepts = true
        }
#endif

        return accepts
    }
    
    
    
    // MARK: Static methods
    
    /// Determines the type of struct represented by the supplied object.
    static func determineType(forValue value: Any) -> ValueStructTypes {
        var type: ValueStructTypes = .unsupported
        
#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS) || os(macOS)
        if (value is CGPoint) {
            type = ValueStructTypes.point
        } else if (value is CGSize) {
            type = ValueStructTypes.size
        } else if (value is CGRect) {
            type = ValueStructTypes.rect
        } else if (value is CGVector) {
            type = ValueStructTypes.vector
        } else if (value is CGAffineTransform) {
            type = ValueStructTypes.affineTransform
        }
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
        if (value is CATransform3D) {
            type = ValueStructTypes.transform3D
        }
#endif
        
        return type
    }
    
}
#endif
