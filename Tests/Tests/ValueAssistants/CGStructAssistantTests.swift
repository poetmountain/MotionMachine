//
//  CGStructAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class CGStructAssistantTests: XCTestCase {

    // MARK: generateProperties
    
    func test_generateProperties_rect() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let end_rect = CGRect(x: 0.0, y: 20.0, width: 50.0, height: 100.0)
        let path = "rect"
        if let end_val = CGStructAssistant.valueForCGStruct(end_rect), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, end: end_val)
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
                // should only have three props because x is unchanged from original rect
                XCTAssertEqual(props.count, 3)
                
                if (props.count == 3) {
                    let y_prop = props[0]
                    let width_prop = props[1]
                    let height_prop = props[2]
                    // should test that ending property states were captured and start states are set to existing rect values
                    XCTAssertEqual(y_prop.path, "rect.origin.y")
                    XCTAssertEqual(y_prop.start, 0.0)
                    XCTAssertEqual(y_prop.end, Double(end_rect.origin.y))
                    XCTAssertEqual(width_prop.path, "rect.size.width")
                    XCTAssertEqual(width_prop.start, 0.0)
                    XCTAssertEqual(width_prop.end, Double(end_rect.size.width))
                    XCTAssertEqual(height_prop.path, "rect.size.height")
                    XCTAssertEqual(height_prop.start, 0.0)
                    XCTAssertEqual(height_prop.end, Double(end_rect.size.height))
                }
                
            } catch {
                XCTFail("Generating properties \(error)")
            }

        }
        
    }
    
    func test_generateProperties_rect_origin() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let end_pt = CGPoint(x: 50.0, y: 75.0)
        let path = "rect.origin"
        if let end_val = CGStructAssistant.valueForCGStruct(end_pt) {
            let states = PropertyStates(path: path, end: end_val)
            do {
                let props = try assistant.generateProperties(targetObject: tester as AnyObject, propertyStates: states)
                
                // should have 2 props because both props changed
                XCTAssertEqual(props.count, 2)
                
                if (props.count == 2) {
                    let x_prop = props[0]
                    let y_prop = props[1]
                    // should test that ending property states were captured and start states are set to existing rect origin
                    XCTAssertEqual(x_prop.path, "rect.origin.x")
                    XCTAssertEqual(x_prop.start, 0.0)
                    XCTAssertEqual(x_prop.end, Double(end_pt.x))
                    XCTAssertEqual(y_prop.path, "rect.origin.y")
                    XCTAssertEqual(y_prop.start, 0.0)
                    XCTAssertEqual(y_prop.end, Double(end_pt.y))
                }
            } catch {
                XCTFail("Generating properties \(error)")
            }
        }
    }
    
    func test_generateProperties_rect_size() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let end_size = CGSize(width: 100.0, height: 150.0)
        let path = "rect.size"
        if let end_val = CGStructAssistant.valueForCGStruct(end_size) {
            let states = PropertyStates(path: path, end: end_val)
            do {
                let props = try assistant.generateProperties(targetObject: tester as AnyObject, propertyStates: states)
                
                // should have 2 props because both props changed
                XCTAssertEqual(props.count, 2)
                
                if (props.count == 2) {
                    let width_prop = props[0]
                    let height_prop = props[1]
                    // should test that ending property states were captured and start states are set to existing rect size
                    XCTAssertEqual(width_prop.path, "rect.size.width")
                    XCTAssertEqual(width_prop.start, 0.0)
                    XCTAssertEqual(width_prop.end, Double(end_size.width))
                    XCTAssertEqual(height_prop.path, "rect.size.height")
                    XCTAssertEqual(height_prop.start, 0.0)
                    XCTAssertEqual(height_prop.end, Double(end_size.height))
                }
            } catch {
                XCTFail("Generating properties \(error)")
            }
        }
    }
    
    func test_generateProperties_start_states() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let start_rect = CGRect(x: 0.0, y: 5.0, width: 20.0, height: 20.0)
        let end_rect = CGRect(x: 0.0, y: 00.0, width: 50.0, height: 100.0)
        let path = "rect"
        if let start_val = CGStructAssistant.valueForCGStruct(start_rect), let end_val = CGStructAssistant.valueForCGStruct(end_rect), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, start: start_val, end: end_val)
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
                // should only have three props because x is unchanged from original rect
                XCTAssertEqual(props.count, 3)
                
                if (props.count == 3) {
                    let y_prop = props[0]
                    let width_prop = props[1]
                    let height_prop = props[2]
                    // should test that both the starting and ending property states were captured
                    // the y prop is included by MotionMachine because even though the ending value is equal to the original value,
                    // a different starting value was specified
                    XCTAssertEqual(y_prop.path, "rect.origin.y")
                    XCTAssertEqual(y_prop.start, Double(start_rect.origin.y))
                    XCTAssertEqual(y_prop.end, Double(end_rect.origin.y))
                    XCTAssertEqual(width_prop.path, "rect.size.width")
                    XCTAssertEqual(width_prop.start, Double(start_rect.size.width))
                    XCTAssertEqual(width_prop.end, Double(end_rect.size.width))
                    XCTAssertEqual(height_prop.path, "rect.size.height")
                    XCTAssertEqual(height_prop.start, Double(start_rect.size.height))
                    XCTAssertEqual(height_prop.end, Double(end_rect.size.height))
                }
            } catch {
                XCTFail("Generating properties \(error)")
            }
        }
        
    }
    
    // test to make sure sub-CGStructs get starting states set
    func test_generateProperties_rect_size_with_start_states() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let start_size = CGSize(width: 20.0, height: 50.0)
        let end_size = CGSize(width: 20.0, height: 150.0)
        let path = "rect.size"
        if let start_val = CGStructAssistant.valueForCGStruct(start_size), let end_val = CGStructAssistant.valueForCGStruct(end_size) {
            let states = PropertyStates(path: path, start: start_val, end: end_val)
            do {
                let props = try assistant.generateProperties(targetObject: tester as AnyObject, propertyStates: states)
                
                // this tests that optimization comparison is done between start and end values of PropertyStates object
                // start value is different than original rect width, but end value is same so no prop should be generated
                XCTAssertEqual(props.count, 1)
                
                if (props.count == 1) {
                    let height_prop = props[0]
                    // should test that start gets the start value from the PropertyStates object
                    XCTAssertEqual(height_prop.path, "rect.size.height")
                    XCTAssertEqual(height_prop.start, Double(start_size.height))
                    XCTAssertEqual(height_prop.end, Double(end_size.height))
                }
            } catch {
                XCTFail("Generating properties \(error)")
            }
        }
    }
    
    func test_generateProperties_vector() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let start_vector = CGVector(dx: 0.0, dy: 0.5)
        let end_vector = CGVector(dx: 10.0, dy: 0.0)
        let path = "vector"
        if let start_val = CGStructAssistant.valueForCGStruct(start_vector), let end_val = CGStructAssistant.valueForCGStruct(end_vector), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, start: start_val, end: end_val)
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
                XCTAssertEqual(props.count, 2)
                
                if (props.count == 2) {
                    let dx_prop = props[0]
                    let dy_prop = props[1]
                    // should test that both the starting and ending property states were captured
                    // the dy prop is included by MotionMachine because even though the ending value is equal to the original value,
                    // a different starting value was specified
                    XCTAssertEqual(dx_prop.path, "vector.dx")
                    XCTAssertEqual(dx_prop.start, Double(start_vector.dx))
                    XCTAssertEqual(dx_prop.end, Double(end_vector.dx))
                    XCTAssertEqual(dy_prop.path, "vector.dy")
                    XCTAssertEqual(dy_prop.start, Double(start_vector.dy))
                    XCTAssertEqual(dy_prop.end, Double(end_vector.dy))
                    
                }
            } catch {
                XCTFail("Generating properties \(error)")
            }
        }
        
    }
    
    
    func test_generateProperties_affineTransform() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let start_transform = CGAffineTransform(a: 0.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
        let end_transform = CGAffineTransform(a: 0.0, b: 0.0, c: 0.0, d: 0.0, tx: 10.0, ty: 10.0)
        let path = "transform"
        if let start_val = CGStructAssistant.valueForCGStruct(start_transform), let end_val = CGStructAssistant.valueForCGStruct(end_transform), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, start: start_val, end: end_val)
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
                // there are 4 props instead of 3 because if the supplied start value is different than the original prop value
                // that PropertyData will get created so the starting value gets set, even if start and end are the same
                XCTAssertEqual(props.count, 4)
                
                if (props.count == 4) {
                    let d_prop = props[1]
                    let tx_prop = props[2]
                    let ty_prop = props[3]
                    // should test that both the starting and ending property states were captured
                    // the d prop is included by MotionMachine because even though the ending value is equal to the original value,
                    // a different starting value was specified
                    XCTAssertEqual(d_prop.path, "transform.d")
                    XCTAssertEqual(d_prop.start, Double(start_transform.d))
                    XCTAssertEqual(d_prop.end, Double(end_transform.d))
                    XCTAssertEqual(tx_prop.path, "transform.tx")
                    XCTAssertEqual(tx_prop.start, Double(start_transform.tx))
                    XCTAssertEqual(tx_prop.end, Double(end_transform.tx))
                    XCTAssertEqual(ty_prop.path, "transform.ty")
                    XCTAssertEqual(ty_prop.start, Double(start_transform.ty))
                    XCTAssertEqual(ty_prop.end, Double(end_transform.ty))
                }
            } catch {
                XCTFail("Generating properties \(error)")
            }
        }
        
    }
    
    
    func test_generateProperties_transform3D() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let start_transform = CATransform3D(m11: 0.0, m12: 5.0, m13: 0.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0)
        let end_transform = CATransform3D(m11: 10.0, m12: 0.0, m13: 20.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0)
        let path = "transform3D"
        if let start_val = CGStructAssistant.valueForCGStruct(start_transform), let end_val = CGStructAssistant.valueForCGStruct(end_transform), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, start: start_val, end: end_val)
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
                // there are 6 props instead of 3 because if the supplied start value is different than the original prop value
                // that PropertyData will get created so the starting value gets set, even if start and end are the same
                XCTAssertEqual(props.count, 6)
                
                if (props.count == 6) {
                    let m11_prop = props[0]
                    let m12_prop = props[1]
                    let m13_prop = props[2]
                    // should test that both the starting and ending property states were captured
                    // the m12 prop is included by MotionMachine because even though the ending value is equal to the original value,
                    // a different starting value was specified
                    XCTAssertEqual(m11_prop.path, "transform3D.m11")
                    XCTAssertEqual(m11_prop.start, Double(start_transform.m11))
                    XCTAssertEqual(m11_prop.end, Double(end_transform.m11))
                    XCTAssertEqual(m12_prop.path, "transform3D.m12")
                    XCTAssertEqual(m12_prop.start, Double(start_transform.m12))
                    XCTAssertEqual(m12_prop.end, Double(end_transform.m12))
                    XCTAssertEqual(m13_prop.path, "transform3D.m13")
                    XCTAssertEqual(m13_prop.start, Double(start_transform.m13))
                    XCTAssertEqual(m13_prop.end, Double(end_transform.m13))
                }
            } catch {
                XCTFail("Generating properties \(error)")
            }
        }
        
    }
    
    
    func test_generateProperties_error() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let path = "rect"
        
        if let target = tester.value(forKeyPath: path) {
            do {
                // method needs an NSValue but we pass in a Tester, so this should throw an error
                let states = PropertyStates(path: path, end: tester)
                try _ = assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)

            } catch ValueAssistantError.typeRequirement(let valueType) {
                ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)
                
                XCTAssertEqual(valueType, "NSValue")
                
            } catch {
                
            }
            
        }
        
    }
    

    // MARK: updateValue

    func test_updateValue_NSNumber() {
        let assistant = CGStructAssistant()
        let updatedValue = assistant.updateValue(inObject: 0.0, newValues: ["" : 10.0])
        
        if let updatedValue = updatedValue as? NSNumber {
            XCTAssertEqual(updatedValue.doubleValue, 10.0)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: updatedValue))")
        }
        
        // additive
        assistant.additive = true
        let additiveValue = assistant.updateValue(inObject: 1.0, newValues: ["" : 10.0])
        if let additiveValue = additiveValue as? NSNumber {
            XCTAssertEqual(additiveValue.doubleValue, 11.0)
        } else {
            XCTFail("Value expected to be NSNumber, but was \(String(describing: additiveValue))")
        }
        
    }
    
    func test_updateValue_CGPoint() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgPoint: CGPoint(x: 0.0, y: 1.0))
        let newValue = assistant.updateValue(inObject: old_value, newValues: ["x" : 10.0])
        
        if let newValue = newValue as? NSValue {
            XCTAssertEqual(newValue.cgPointValue.x, 10.0)
            XCTAssertEqual(newValue.cgPointValue.y, old_value.cgPointValue.y)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: newValue))")
        }
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgPoint: CGPoint(x: 1.0, y: 1.0))
        let additiveValue = assistant.updateValue(inObject: old_value, newValues: ["x" : 10.0])
        if let additiveValue = additiveValue as? NSValue {
            XCTAssertEqual(additiveValue.cgPointValue.x, 11.0)
            XCTAssertEqual(additiveValue.cgPointValue.y, old_value.cgPointValue.y)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: additiveValue))")
        }
    }
    
    func test_updateValue_CGSize() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgSize: CGSize(width: 10.0, height: 10.0))
        let newValue = assistant.updateValue(inObject: old_value, newValues: ["width" : 10.0])
        
        if let newValue = newValue as? NSValue {
            XCTAssertEqual(newValue.cgSizeValue.width, 10.0)
            XCTAssertEqual(newValue.cgSizeValue.height, old_value.cgSizeValue.height)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: newValue))")
        }
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgSize: CGSize(width: 10.0, height: 10.0))
        let additiveValue = assistant.updateValue(inObject: old_value, newValues: ["width" : 1.0])
        
        if let additiveValue = additiveValue as? NSValue {
            XCTAssertEqual(additiveValue.cgSizeValue.width, 11.0)
            XCTAssertEqual(additiveValue.cgSizeValue.height, old_value.cgSizeValue.height)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: additiveValue))")
        }
        
    }
    
    func test_updateValue_CGRect() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgRect: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        let newValue = assistant.updateValue(inObject: old_value, newValues: ["origin.x" : 10.0])
        
        if let newValue = newValue as? NSValue {
            XCTAssertEqual(newValue.cgRectValue.origin.x, 10.0)
            XCTAssertEqual(newValue.cgRectValue.origin.y, old_value.cgRectValue.origin.y)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: newValue))")
        }
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgRect: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        let additiveValue = assistant.updateValue(inObject: old_value, newValues: ["size.width" : 1.0])
        if let additiveValue = additiveValue as? NSValue {
            XCTAssertEqual(additiveValue.cgRectValue.size.width, 11.0)
            XCTAssertEqual(additiveValue.cgRectValue.size.height, old_value.cgRectValue.size.height)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: additiveValue))")
        }
    }
    
    func test_updateValue_CGVector() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgVector: CGVector(dx: 0.0, dy: 0.0))
        let newValue = assistant.updateValue(inObject: old_value, newValues: ["dx" : 10.0])
        
        if let newValue = newValue as? NSValue {
            XCTAssertEqual(newValue.cgVectorValue.dx, 10.0)
            XCTAssertEqual(newValue.cgVectorValue.dy, old_value.cgVectorValue.dy)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: newValue))")
        }
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgVector: CGVector(dx: 10.0, dy: 10.0))
        let additiveValue = assistant.updateValue(inObject: old_value, newValues: ["dx" : 1.0])
        if let additiveValue = additiveValue as? NSValue {
            XCTAssertEqual(additiveValue.cgVectorValue.dx, 11.0)
            XCTAssertEqual(additiveValue.cgVectorValue.dy, old_value.cgVectorValue.dy)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: additiveValue))")
        }
    }
    
    func test_updateValue_CGAffineTransform() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgAffineTransform: CGAffineTransform.identity)
        let newValue = assistant.updateValue(inObject: old_value, newValues: ["tx" : 10.0])
        
        if let newValue = newValue as? NSValue {
            XCTAssertEqual(newValue.cgAffineTransformValue.tx, 10.0)
            XCTAssertEqual(newValue.cgAffineTransformValue.ty, old_value.cgAffineTransformValue.ty)
        }
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgAffineTransform: CGAffineTransform.init(a: 0, b: 0, c: 0, d: 0, tx: 1.0, ty: 0.1))
        let additiveValue = assistant.updateValue(inObject: old_value, newValues: ["tx" : 1.0])
        
        if let additiveValue = additiveValue as? NSValue {
            XCTAssertEqual(additiveValue.cgAffineTransformValue.tx, 2.0)
            XCTAssertEqual(additiveValue.cgAffineTransformValue.ty, old_value.cgAffineTransformValue.ty)
        }
    }
    
    func test_updateValue_CATransform3D() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(caTransform3D: CATransform3DIdentity)
        
        let newValue = assistant.updateValue(inObject: old_value, newValues: ["m11" : 10.0])
        if let newValue = newValue as? NSValue {
            XCTAssertEqual(newValue.caTransform3DValue.m11, 10.0)
            XCTAssertEqual(newValue.caTransform3DValue.m12, old_value.caTransform3DValue.m12)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: newValue))")
        }
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(caTransform3D: CATransform3DIdentity)
        
        let additiveValue = assistant.updateValue(inObject: old_value, newValues: ["m11" : 1.0])
        if let additiveValue = additiveValue as? NSValue {
            XCTAssertEqual(additiveValue.caTransform3DValue.m11, 2.0) // m11 is already 1.0 in identity
            XCTAssertEqual(additiveValue.caTransform3DValue.m12, old_value.caTransform3DValue.m12)
        } else {
            XCTFail("Value expected to be NSValue, but was \(String(describing: additiveValue))")
        }
    }
    
    // MARK: retrieveValue
    
    func test_retrieveValue_CGFloat() {
        let assistant = CGStructAssistant()
        
        do {
            let value = try assistant.retrieveValue(inObject: NSNumber(value: 10.0), keyPath: "")
            XCTAssertEqual(value, 10.0)
        } catch {
            XCTFail("Value was not found")

        }
    }
    
    func test_retrieveValue_CGPoint() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgPoint: CGPoint(x: 10.0, y: 0.0))
        do {
            let value = try assistant.retrieveValue(inObject: object, keyPath: "x")
            XCTAssertEqual(value, 10.0)
        } catch {
            XCTFail("x value was not found")
        }
    }
    
    func test_retrieveValue_CGSize() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgSize: CGSize(width: 10.0, height: 10.0))
        do {
            let value = try assistant.retrieveValue(inObject: object, keyPath: "width")
            XCTAssertEqual(value, 10.0)
        } catch {
            XCTFail("Width value was not found")
        }
    }
    
    func test_retrieveValue_CGRect() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgRect: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        do {
            let value = try assistant.retrieveValue(inObject: object, keyPath: "size.width")
            XCTAssertEqual(value, 10.0)
        } catch {
            XCTFail("size.width value was not found")
        }
    }
    
    func test_retrieveValue_CGVector() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgVector: CGVector(dx: 10.0, dy: 0.0))
        do {
            let value = try assistant.retrieveValue(inObject: object, keyPath: "dx")
            XCTAssertEqual(value, 10.0)
        } catch {
            XCTFail("dx value was not found")

        }
    }
    
    func test_retrieveValue_CGAffineTransform() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgAffineTransform: CGAffineTransform.init(a: 0.0, b: 0.0, c: 0.0, d: 0.0, tx: 10.0, ty: 0.0))
        do {
            let value = try assistant.retrieveValue(inObject: object, keyPath: "tx")
            XCTAssertEqual(value, 10.0)
        } catch {
            XCTFail("tx value was not found")
        }
    }
    
    func test_retrieveValue_CATransform3D() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(caTransform3D: CATransform3DIdentity) // m11 is already 1.0 in identity
        do {
            let value = try assistant.retrieveValue(inObject: object, keyPath: "m11")
            XCTAssertEqual(value, 1.0)
        } catch {
            XCTFail("m11 value was not found")
        }
    }
    
    
    func test_retrieveValue_error() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        
        do {
            // method needs an NSValue but we pass in a Tester, so this should throw an error
            try _ = assistant.retrieveValue(inObject: tester, keyPath: "m11")
            
        } catch ValueAssistantError.typeRequirement(let valueType) {
            ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)
            
            XCTAssertEqual(valueType, "NSValue")
            
        } catch {
            
        }
        
    }
    
    
    // MARK: utility methods
    
    func test_hasNestedStruct() {
        let tester = Tester()

        // rect at top level should return false
        let top_path = "rect"
        let targets_nested_top = CGStructAssistant.targetsNestedStruct(object: tester, path: top_path)
        XCTAssertFalse(targets_nested_top)
        
        // test that rect in a sub-class should return false
        let sub_path = "sub.rect"
        let targets_nested_sub = CGStructAssistant.targetsNestedStruct(object: tester, path: sub_path)
        XCTAssertFalse(targets_nested_sub)
        
        // test that path which includes component of rect returns true
        let component_path = "sub.rect.origin"
        let targets_component = CGStructAssistant.targetsNestedStruct(object: tester, path: component_path)
        XCTAssertTrue(targets_component)
    }
}
