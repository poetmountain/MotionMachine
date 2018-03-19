//
//  UIKitStructAssistantTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/30/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

class UIKitStructAssistantTests: XCTestCase {

    // MARK: generateProperties
    
    func test_generateProperties_UIEdgeInsets() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let insets = UIEdgeInsetsMake(10.0, 0.0, 20.0, 0.0)
        let path = "insets"
        if let val = UIKitStructAssistant.valueForStruct(insets), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, end: val)
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
            // should only have 2 props because left and right are unchanged from original insets
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let top_prop = props[0]
                let bottom_prop = props[1]
                // should test that ending property states were captured and start states are set to existing inset values
                XCTAssertEqual(top_prop.path, "insets.top")
                XCTAssertEqual(top_prop.start, 0.0)
                XCTAssertEqual(top_prop.end, 10.0)
                XCTAssertEqual(bottom_prop.path, "insets.bottom")
                XCTAssertEqual(bottom_prop.start, 0.0)
                XCTAssertEqual(bottom_prop.end, 20.0)
            }
        }
        
    }
    
    func test_generateProperties_UIEdgeInsets_start_state() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let start_insets = UIEdgeInsetsMake(5.0, 5.0, 10.0, 0.0)
        let insets = UIEdgeInsetsMake(10.0, 0.0, 20.0, 0.0)
        let path = "insets"
        if let start_val = UIKitStructAssistant.valueForStruct(start_insets), let val = UIKitStructAssistant.valueForStruct(insets), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, start: start_val, end: val)
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
            // should only have 3 props because right is unchanged from original insets
            XCTAssertEqual(props.count, 3)
            
            if (props.count == 3) {
                let top_prop = props[0]
                let left_prop = props[1]
                let bottom_prop = props[2]
                // should test that both the starting and ending property states were captured
                // the left prop is included by MotionMachine because even though the ending value is equal to the original inset value,
                // a different starting value was specified
                XCTAssertEqual(top_prop.path, "insets.top")
                XCTAssertEqual(top_prop.start, 5.0)
                XCTAssertEqual(top_prop.end, 10.0)
                XCTAssertEqual(left_prop.path, "insets.left")
                XCTAssertEqual(left_prop.start, 5.0)
                XCTAssertEqual(left_prop.end, 0.0)
                XCTAssertEqual(bottom_prop.path, "insets.bottom")
                XCTAssertEqual(bottom_prop.start, 10.0)
                XCTAssertEqual(bottom_prop.end, 20.0)
            }
        }
        
    }
    
    
    func test_generateProperties_UIOffset() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let offset = UIOffsetMake(10.0, 20.0)
        let path = "offset"
        if let val = UIKitStructAssistant.valueForStruct(offset), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, end: val)
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
            // should  have 2 props both offset values are changed from original
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let h_prop = props[0]
                let v_prop = props[1]
                // should test that ending property states were captured and start states are set to original offset values
                XCTAssertEqual(h_prop.path, "offset.horizontal")
                XCTAssertEqual(h_prop.start, 0.0)
                XCTAssertEqual(h_prop.end, 10.0)
                XCTAssertEqual(v_prop.path, "offset.vertical")
                XCTAssertEqual(v_prop.start, 0.0)
                XCTAssertEqual(v_prop.end, 20.0)
            }
        }
        
    }
    
    func test_generateProperties_UIOffset_start_state() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let start_offset = UIOffsetMake(5.0, 10.0)
        let offset = UIOffsetMake(10.0, 20.0)
        let path = "offset"
        if let start_val = UIKitStructAssistant.valueForStruct(start_offset), let val = UIKitStructAssistant.valueForStruct(offset), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, start: start_val, end: val)
            let props = try! assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
            
            // should  have 2 props both offset values are changed from original
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let h_prop = props[0]
                let v_prop = props[1]
                // should test that both the starting and ending property states were captured
                XCTAssertEqual(h_prop.path, "offset.horizontal")
                XCTAssertEqual(h_prop.start, 5.0)
                XCTAssertEqual(h_prop.end, 10.0)
                XCTAssertEqual(v_prop.path, "offset.vertical")
                XCTAssertEqual(v_prop.start, 10.0)
                XCTAssertEqual(v_prop.end, 20.0)
            }
        }
        
    }
    
    
    func test_generateProperties_error() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let path = "insets"
        
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
    
    func test_updateValue_UIEdgeOffsets() {
        let assistant = UIKitStructAssistant()
        var old_value = NSValue.init(uiEdgeInsets: UIEdgeInsetsMake(10.0, 0.0, 20.0, 0.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["top" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.uiEdgeInsetsValue.top, 10.0)
        XCTAssertEqual(new_value.uiEdgeInsetsValue.bottom, old_value.uiEdgeInsetsValue.bottom)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(uiEdgeInsets: UIEdgeInsetsMake(1.0, 0.0, 20.0, 0.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["top" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.uiEdgeInsetsValue.top, 11.0)
        XCTAssertEqual(new_value.uiEdgeInsetsValue.bottom, old_value.uiEdgeInsetsValue.bottom)
    }
    
    func test_updateValue_UIOffset() {
        let assistant = UIKitStructAssistant()
        var old_value = NSValue.init(uiOffset: UIOffsetMake(10.0, 20.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["horizontal" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.uiOffsetValue.horizontal, 10.0)
        XCTAssertEqual(new_value.uiOffsetValue.vertical, old_value.uiOffsetValue.vertical)
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(uiOffset: UIOffsetMake(1.0, 20.0))
        new_value = assistant.updateValue(inObject: old_value, newValues: ["horizontal" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.uiOffsetValue.horizontal, 11.0)
        XCTAssertEqual(new_value.uiOffsetValue.vertical, old_value.uiOffsetValue.vertical)
    }

    
    // MARK: retrieveValue
    
    func test_retrieveValue_UIEdgeInsets() {
        let assistant = UIKitStructAssistant()
        let object = NSValue.init(uiEdgeInsets: UIEdgeInsetsMake(10.0, 0.0, 20.0, 0.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "top")
        XCTAssertEqual(value, 10.0)
    }
    
    func test_retrieveValue_UIOffset() {
        let assistant = UIKitStructAssistant()
        let object = NSValue.init(uiOffset: UIOffsetMake(10.0, 20.0))
        let value = try! assistant.retrieveValue(inObject: object, keyPath: "horizontal")
        XCTAssertEqual(value, 10.0)
    }
    
    func test_retrieveValue_error() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        
        do {
            // method needs an NSValue but we pass in a Tester, so this should throw an error
            try _ = assistant.retrieveValue(inObject: tester, keyPath: "top")
            
        } catch ValueAssistantError.typeRequirement(let valueType) {
            ValueAssistantError.typeRequirement(valueType).printError(fromFunction: #function)
            
            XCTAssertEqual(valueType, "NSValue")
            
        } catch {
            
        }
        
    }
    
}
