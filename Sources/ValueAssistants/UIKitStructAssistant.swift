//
//  UIKitStructAssistant.swift
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
/// UIKitStructAssistant provides support for the UIKit structs `UIEdgeInsets` and `UIOffset`.
public final class UIKitStructAssistant<TargetType: AnyObject>: ValueAssistant {

    public var isAdditive: Bool = false
    public var additiveWeighting: Double = 1.0 {
        didSet {
            // constrain weighting to range of 0.0 - 1.0
            additiveWeighting = max(min(additiveWeighting, 1.0), 0.0)
        }
    }
    
    /// Initializer.
    public required init() {
        // provide support for UIKit structs
        // doesn't seem like there's a better way to extend the enum array from multiple assistants than this?
        ValueStructTypes.valueTypes[.uiEdgeInsets] = UIEdgeInsets.zero
        ValueStructTypes.valueTypes[.uiOffset] = UIOffset.zero
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
            startType = UIKitStructAssistant.determineType(forValue: statesStart)
        }
        
        let endType = UIKitStructAssistant.determineType(forValue: endValue)
        
        switch endType {
        case .uiEdgeInsets:

            guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, UIEdgeInsets> else { return properties }

            var org_top: Double?
            var org_left: Double?
            var org_bottom: Double?
            var org_right: Double?
                
            if let insets = nestedObject as? UIEdgeInsets {
                org_top = insets.top
                org_left = insets.left
                org_right = insets.right
                org_bottom = insets.bottom
            }
                
            let endInsets = endValue as? UIEdgeInsets

            
            if let org_top {
                var startStateTop: Double
                if startType == .uiEdgeInsets, let startValue = startValue as? UIEdgeInsets {
                    startStateTop = startValue.top
                } else {
                    startStateTop = org_top
                }
                
                let finalPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \UIEdgeInsets.top)

                if let endTop = endInsets?.top, let prop = MotionSupport.buildPropertyData(keyPath: finalPath, parentPath: keyPath, originalValue: org_top, startValue: startStateTop, endValue: endTop, isAdditive: isAdditive) {
                    properties.append(prop)
                }
            }
        
            if let org_left {
                var startStateLeft: Double
                if startType == .uiEdgeInsets, let startValue = startValue as? UIEdgeInsets {
                    startStateLeft = startValue.left
                } else {
                    startStateLeft = org_left
                }
                
                let finalPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \UIEdgeInsets.left)

                if let endLeft = endInsets?.left, let prop = MotionSupport.buildPropertyData(keyPath: finalPath, parentPath: keyPath, originalValue: org_left, startValue: startStateLeft, endValue: endLeft, isAdditive: isAdditive) {
                    properties.append(prop)
                }
            }
                
            if let org_bottom {
                var startStateBottom: Double
                if startType == .uiEdgeInsets, let startValue = startValue as? UIEdgeInsets {
                    startStateBottom = startValue.bottom
                } else {
                    startStateBottom = org_bottom
                }
                
                let finalPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \UIEdgeInsets.bottom)

                if let endBottom = endInsets?.bottom, let prop = MotionSupport.buildPropertyData(keyPath: finalPath, parentPath: keyPath, originalValue: org_bottom, startValue: startStateBottom, endValue: endBottom, isAdditive: isAdditive) {
                    properties.append(prop)
                }
            }
                
            if let org_right {
                var startStateRight: Double
                if startType == .uiEdgeInsets, let startValue = startValue as? UIEdgeInsets {
                    startStateRight = startValue.right
                } else {
                    startStateRight = org_right
                }
                
                let finalPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \UIEdgeInsets.right)

                if let endRight = endInsets?.right, let prop = MotionSupport.buildPropertyData(keyPath: finalPath, parentPath: keyPath, originalValue: org_right, startValue: startStateRight, endValue: endRight, isAdditive: isAdditive) {
                    properties.append(prop)
                }
            }
            
        case .uiOffset:

            guard let keyPath = state.keyPath as? ReferenceWritableKeyPath<TargetType, UIOffset> else { return properties }

            var org_h: Double?
            var org_v: Double?
            
            if let uiOffset = nestedObject as? UIOffset {
                org_h = uiOffset.horizontal
                org_v = uiOffset.vertical
            }
                    
            let endOffset = endValue as? UIOffset
            
            if let org_h {
                var startStateHorizontal: Double
                if startType == .uiOffset, let startValue = startValue as? UIOffset {
                    startStateHorizontal = startValue.horizontal
                } else {
                    startStateHorizontal = org_h
                }
                
                let finalPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \UIOffset.horizontal)

                if let endHorizontal = endOffset?.horizontal, let prop = MotionSupport.buildPropertyData(keyPath: finalPath, parentPath: keyPath, originalValue: org_h, startValue: startStateHorizontal, endValue: endHorizontal, isAdditive: isAdditive) {
                    properties.append(prop)
                }
            }
                
            if let org_v {
                var startStateVertical: Double
                if startType == .uiOffset, let startValue = startValue as? UIOffset {
                    startStateVertical = startValue.vertical
                } else {
                    startStateVertical = org_v
                }
                
                let finalPath: ReferenceWritableKeyPath<TargetType, CGFloat> = keyPath.appending(path: \UIOffset.vertical)

                if let endVertical = endOffset?.vertical, let prop = MotionSupport.buildPropertyData(keyPath: finalPath, parentPath: keyPath, originalValue: org_v, startValue: startStateVertical, endValue: endVertical, isAdditive: isAdditive) {
                    properties.append(prop)
                }
            }
        
        case .unsupported: break

        default:
            break
        }
        
        return properties
    }
    
    
    @discardableResult public func update(property: PropertyData<TargetType>, newValue: Double) -> Any? {
        guard let targetObject = property.targetObject else { return nil }

        var newPropertyValue = newValue
        var currentValue: Any?

        currentValue = property.retrieveValue(from: targetObject)

        if (isAdditive) {
            if let currentValue = currentValue as? any BinaryFloatingPoint, let current = currentValue.toDouble() {
                newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
            } else if let currentValue = currentValue as? any BinaryInteger, let current = currentValue.toDouble() {
                newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
            } else if let currentValue = currentValue as? NSNumber {
                let current = currentValue.doubleValue
                newPropertyValue = applyAdditiveTo(value: current, newValue: newValue)
            }
        }
        
        property.apply(value: newPropertyValue, to: targetObject)
        
        return newPropertyValue
    }
    
    
    
    public func supports(_ object: Any) -> Bool {
        var isSupported: Bool = false
        
        if (object is UIEdgeInsets || object is UIOffset) {
            isSupported = true
        }
        
        return isSupported
    }
    
    public func acceptsKeypath(_ object: AnyObject) -> Bool {
        var accepts = false
        
        if (object is UIEdgeInsets || object is UIOffset) {
            accepts = true
        }
        
        return accepts
    }
    
    
    // MARK: Static methods
    
    /// Determines the type of struct represented by the supplied object.
    public static func determineType(forValue value: Any) -> ValueStructTypes {
        let type: ValueStructTypes
        
        if value is UIEdgeInsets {
            type = ValueStructTypes.uiEdgeInsets
        } else if value is UIOffset {
            type = ValueStructTypes.uiOffset
        } else {
            type = ValueStructTypes.unsupported
        }
        
        
        return type
    }
    
    
}

#endif
