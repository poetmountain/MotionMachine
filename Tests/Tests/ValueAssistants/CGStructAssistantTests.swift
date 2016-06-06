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
        let rect = CGRectMake(0.0, 10.0, 50.0, 0.0)
        let path = "rect"
        if let val = CGStructAssistant.valueForCGStruct(rect), target = tester.valueForKeyPath(path) {
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
        
        if let target = tester.valueForKeyPath(path) {
            do {
                // method needs an NSValue but we pass in a Tester, so this should throw an error
                try assistant.generateProperties(fromObject: tester, keyPath: path, targetObject: target)

            } catch ValueAssistantError.TypeRequirement(let valueType) {
                ValueAssistantError.TypeRequirement(valueType).printError(fromFunction: #function)
                
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
        var old_value = NSValue.init(CGPoint: CGPointMake(0.0, 1.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["x" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.CGPointValue().x, 10.0)
        XCTAssertEqual(new_value.CGPointValue().y, old_value.CGPointValue().y)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(CGPoint: CGPointMake(1.0, 1.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["x" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.CGPointValue().x, 11.0)
        XCTAssertEqual(new_value.CGPointValue().y, old_value.CGPointValue().y)
        
    }
    
    func test_updateValue_CGSize() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(CGSize: CGSizeMake(10.0, 10.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["width" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.CGSizeValue().width, 10.0)
        XCTAssertEqual(new_value.CGSizeValue().height, old_value.CGSizeValue().height)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(CGSize: CGSizeMake(10.0, 10.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["width" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.CGSizeValue().width, 11.0)
        XCTAssertEqual(new_value.CGSizeValue().height, old_value.CGSizeValue().height)
        
    }
    
    func test_updateValue_CGRect() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(CGRect: CGRectMake(0.0, 0.0, 10.0, 10.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["origin.x" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.CGRectValue().origin.x, 10.0)
        XCTAssertEqual(new_value.CGRectValue().origin.y, old_value.CGRectValue().origin.y)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(CGRect: CGRectMake(0.0, 0.0, 10.0, 10.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["size.width" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.CGRectValue().size.width, 11.0)
        XCTAssertEqual(new_value.CGRectValue().size.height, old_value.CGRectValue().size.height)
        
    }
    
    func test_updateValue_CGVector() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(CGVector: CGVectorMake(0.0, 0.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["dx" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.CGVectorValue().dx, 10.0)
        XCTAssertEqual(new_value.CGVectorValue().dy, old_value.CGVectorValue().dy)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(CGVector: CGVectorMake(10.0, 10.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["dx" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.CGVectorValue().dx, 11.0)
        XCTAssertEqual(new_value.CGVectorValue().dy, old_value.CGVectorValue().dy)
        
    }
    
    func test_updateValue_CGAffineTransform() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(CGAffineTransform: CGAffineTransformIdentity)
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["tx" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.CGAffineTransformValue().tx, 10.0)
        XCTAssertEqual(new_value.CGAffineTransformValue().ty, old_value.CGAffineTransformValue().ty)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(CGAffineTransform: CGAffineTransformMake(0, 0, 0, 0, 1.0, 0.1))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["tx" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.CGAffineTransformValue().tx, 2.0)
        XCTAssertEqual(new_value.CGAffineTransformValue().ty, old_value.CGAffineTransformValue().ty)
        
    }
    
    func test_updateValue_CATransform3D() {
        let assistant = CGStructAssistant()
        var old_value = NSValue.init(CATransform3D: CATransform3DIdentity)
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["m11" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.CATransform3DValue.m11, 10.0)
        XCTAssertEqual(new_value.CATransform3DValue.m12, old_value.CATransform3DValue.m12)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(CATransform3D: CATransform3DIdentity)
        new_value = assistant.updateValue(inObject: old_value, newValues: ["m11" : 1.0]) as! NSValue
        XCTAssertEqual(new_value.CATransform3DValue.m11, 2.0) // m11 is already 1.0 in identity
        XCTAssertEqual(new_value.CATransform3DValue.m12, old_value.CATransform3DValue.m12)
        
    }
    
    // MARK: retrieveValue
    
    func test_retrieveValue_CGFloat() {
        let assistant = CGStructAssistant()
        
        let value = try! assistant.retrieveValue(inObject: NSNumber(float: 10.0), keyPath: "")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGPoint() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(CGPoint: CGPointMake(10.0, 0.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "x")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGSize() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(CGSize: CGSizeMake(10.0, 10.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "width")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGRect() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(CGRect: CGRectMake(0.0, 0.0, 10.0, 10.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "size.width")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGVector() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(CGVector: CGVectorMake(10.0, 0.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "dx")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CGAffineTransform() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(CGAffineTransform: CGAffineTransformMake(0.0, 0.0, 0.0, 0.0, 10.0, 0.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "tx")
        XCTAssertEqual(value, 10.0)
        
    }
    
    func test_retrieveValue_CATransform3D() {
        let assistant = CGStructAssistant()
        let object = NSValue.init(CATransform3D: CATransform3DIdentity) // m11 is already 1.0 in identity
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "m11")
        XCTAssertEqual(value, 1.0)
        
    }
    
    
    func test_retrieveValue_error() {
        let assistant = CGStructAssistant()
        let tester = Tester()
        
        do {
            // method needs an NSValue but we pass in a Tester, so this should throw an error
            try assistant.retrieveValue(inObject: tester, keyPath: "m11")
            
        } catch ValueAssistantError.TypeRequirement(let valueType) {
            ValueAssistantError.TypeRequirement(valueType).printError(fromFunction: #function)
            
            XCTAssertEqual(valueType, "NSValue")
            
        } catch {
            
        }
        
    }
}
