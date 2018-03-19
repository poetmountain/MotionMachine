//
//  CGStructAssistantTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/23/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

class CGStructAssistantTests: XCTestCase {

    // MARK: generateProperties
    
    func test_generateProperties_rect() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let end_rect = CGRect(x: 0.0, y: 20.0, width: 50.0, height: 100.0)
        let path = "rect"
        if let end_val = CGStructAssistant.valueForCGStruct(end_rect), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, end: end_val)
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
            // should only have three props because x is unchanged from original rect
            XCTAssertEqual(props.count, 3)
            
            if (props.count == 3) {
                let y_prop = props[0]
                let width_prop = props[1]
                let height_prop = props[2]
                // should test that ending property states were captured and start states are set to existing rect values
                XCTAssertEqual(y_prop.path, "rect.origin.y")
                XCTAssertEqual(y_prop.start, 0.0)
                XCTAssertEqual(y_prop.end, 20.0)
                XCTAssertEqual(width_prop.path, "rect.size.width")
                XCTAssertEqual(width_prop.start, 0.0)
                XCTAssertEqual(width_prop.end, 50.0)
                XCTAssertEqual(height_prop.path, "rect.size.height")
                XCTAssertEqual(height_prop.start, 0.0)
                XCTAssertEqual(height_prop.end, 100.0)
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
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
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
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
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
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
            XCTAssertEqual(props.count, 3)
            
            if (props.count == 3) {
                let d_prop = props[0]
                let tx_prop = props[1]
                let ty_prop = props[2]
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
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
            XCTAssertEqual(props.count, 3)
            
            if (props.count == 3) {
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
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: 0.0, newValues: ["" : 10.0]) as! NSValue
        XCTAssertEqual((new_value as! NSNumber).doubleValue, 10.0)
        
        // additive
        assistant.additive = true
        new_value = assistant.updateValue(inObject: 1.0, newValues: ["" : 10.0]) as! NSValue
        XCTAssertEqual((new_value as! NSNumber).doubleValue, 11.0)
        
    }
    
    func test_updateValue_CGPoint() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgPoint: CGPoint(x: 0.0, y: 1.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["x" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.cgPointValue.x, 10.0)
        XCTAssertEqual(new_value.cgPointValue.y, old_value.cgPointValue.y)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgPoint: CGPoint(x: 1.0, y: 1.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["x" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.cgPointValue.x, 11.0)
        XCTAssertEqual(new_value.cgPointValue.y, old_value.cgPointValue.y)
        
    }
    
    func test_updateValue_CGSize() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgSize: CGSize(width: 10.0, height: 10.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["width" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.cgSizeValue.width, 10.0)
        XCTAssertEqual(new_value.cgSizeValue.height, old_value.cgSizeValue.height)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgSize: CGSize(width: 10.0, height: 10.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["width" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.cgSizeValue.width, 11.0)
        XCTAssertEqual(new_value.cgSizeValue.height, old_value.cgSizeValue.height)
        
    }
    
    func test_updateValue_CGRect() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgRect: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["origin.x" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.cgRectValue.origin.x, 10.0)
        XCTAssertEqual(new_value.cgRectValue.origin.y, old_value.cgRectValue.origin.y)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgRect: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["size.width" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.cgRectValue.size.width, 11.0)
        XCTAssertEqual(new_value.cgRectValue.size.height, old_value.cgRectValue.size.height)
        
    }
    
    func test_updateValue_CGVector() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgVector: CGVector(dx: 0.0, dy: 0.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["dx" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.cgVectorValue.dx, 10.0)
        XCTAssertEqual(new_value.cgVectorValue.dy, old_value.cgVectorValue.dy)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgVector: CGVector(dx: 10.0, dy: 10.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["dx" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.cgVectorValue.dx, 11.0)
        XCTAssertEqual(new_value.cgVectorValue.dy, old_value.cgVectorValue.dy)
        
    }
    
    func test_updateValue_CGAffineTransform() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(cgAffineTransform: CGAffineTransform.identity)
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["tx" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.cgAffineTransformValue.tx, 10.0)
        XCTAssertEqual(new_value.cgAffineTransformValue.ty, old_value.cgAffineTransformValue.ty)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(cgAffineTransform: CGAffineTransform.init(a: 0, b: 0, c: 0, d: 0, tx: 1.0, ty: 0.1))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["tx" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.cgAffineTransformValue.tx, 2.0)
        XCTAssertEqual(new_value.cgAffineTransformValue.ty, old_value.cgAffineTransformValue.ty)
        
    }
    
    func test_updateValue_CATransform3D() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(caTransform3D: CATransform3DIdentity)
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["m11" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.caTransform3DValue.m11, 10.0)
        XCTAssertEqual(new_value.caTransform3DValue.m12, old_value.caTransform3DValue.m12)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(caTransform3D: CATransform3DIdentity)
        new_value = assistant.updateValue(inObject: old_value, newValues: ["m11" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.caTransform3DValue.m11, 2.0) // m11 is already 1.0 in identity
        XCTAssertEqual(new_value.caTransform3DValue.m12, old_value.caTransform3DValue.m12)
        
    }
    
    // MARK: retrieveValue
    
    func test_retrieveValue_CGFloat() {
        let assistant = CGStructAssistant()
        
        let value = try! assistant.retrieveValue(inObject: NSNumber(value: 10.0), keyPath: "")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGPoint() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgPoint: CGPoint(x: 10.0, y: 0.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "x")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGSize() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgSize: CGSize(width: 10.0, height: 10.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "width")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGRect() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgRect: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "size.width")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGVector() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgVector: CGVector(dx: 10.0, dy: 0.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "dx")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGAffineTransform() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(cgAffineTransform: CGAffineTransform.init(a: 0.0, b: 0.0, c: 0.0, d: 0.0, tx: 10.0, ty: 0.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "tx")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CATransform3D() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(caTransform3D: CATransform3DIdentity) // m11 is already 1.0 in identity
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "m11")
        XCTAssertEqual(value, 1.0)
        
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
}
