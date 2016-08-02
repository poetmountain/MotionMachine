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
    
    func test_generateProperties() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let rect = CGRect(x: 0.0, y: 10.0, width: 50.0, height: 0.0)
        let path = "rect"
        if let val = CGStructAssistant.valueForCGStruct(rect), let target = tester.value(forKeyPath: path) {
            let props = try! assistant.generateProperties(fromObject: val, keyPath: path, targetObject: target)
            
            XCTAssertEqual(props.count, 2)
            
            let y_prop = props[0]
            let width_prop = props[1]
            XCTAssertEqual(y_prop.path, "rect.origin.y")
            XCTAssertEqual(y_prop.end, 10.0)
            XCTAssertEqual(width_prop.path, "rect.size.width")
            XCTAssertEqual(width_prop.end, 50.0)
        }
        
    }
    
    func test_generateProperties_error() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        let path = "rect"
        
        if let target = tester.value(forKeyPath: path) {
            do {
                // method needs an NSValue but we pass in a Tester, so this should throw an error
                try _ = assistant.generateProperties(fromObject: tester, keyPath: path, targetObject: target)

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
