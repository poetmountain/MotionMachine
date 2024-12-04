//
//  UIKitStructAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class UIKitStructAssistantTests: XCTestCase {

    // MARK: generateProperties
    
    func test_generateProperties_UIEdgeInsets() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let insets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 20.0, right: 0.0)
        let path = "insets"
        if let val = UIKitStructAssistant.valueForStruct(insets), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, end: val)
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
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
            } catch {
                XCTFail("Could not generate properties for \(states)")
            }
        }
        
    }
    
    func test_generateProperties_UIEdgeInsets_start_state() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let start_insets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 10.0, right: 0.0)
        let insets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 20.0, right: 0.0)
        let path = "insets"
        if let start_val = UIKitStructAssistant.valueForStruct(start_insets), let val = UIKitStructAssistant.valueForStruct(insets), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, start: start_val, end: val)
            
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
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
            } catch {
                XCTFail("Could not generate properties for \(states)")
            }
        } else {
            XCTFail("Could not find start or end values for struct")
        }
        
    }
    
    
    func test_generateProperties_UIOffset() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let offset = UIOffset(horizontal: 10.0, vertical: 20.0)
        let path = "offset"
        if let val = UIKitStructAssistant.valueForStruct(offset), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, end: val)
            
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
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
            } catch {
                XCTFail("Could not generate properties for \(states)")

            }
        }
        
    }
    
    func test_generateProperties_UIOffset_start_state() {
        let assistant = UIKitStructAssistant()
        let tester = Tester()
        let start_offset = UIOffset(horizontal: 5.0, vertical: 10.0)
        let offset = UIOffset(horizontal: 10.0, vertical: 20.0)
        let path = "offset"
        if let start_val = UIKitStructAssistant.valueForStruct(start_offset), let val = UIKitStructAssistant.valueForStruct(offset), let target = tester.value(forKeyPath: path) {
            let states = PropertyStates(path: path, start: start_val, end: val)
            
            do {
                let props = try assistant.generateProperties(targetObject: target as AnyObject, propertyStates: states)
                
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
            } catch {
                XCTFail("Could not generate properties for \(states)")
            }
        } else {
            XCTFail("Could not get value for struct")
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
        var old_value = NSValue.init(uiEdgeInsets: UIEdgeInsets(top: 10.0, left: 0.0, bottom: 20.0, right: 0.0))
        
        if let newValue = assistant.updateValue(inObject: old_value, newValues: ["top" : 10.0]) as? NSValue {
            XCTAssertEqual(newValue.uiEdgeInsetsValue.top, 10.0)
            XCTAssertEqual(newValue.uiEdgeInsetsValue.bottom, old_value.uiEdgeInsetsValue.bottom)
        } else {
            XCTFail("Could not update top value")
        }
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(uiEdgeInsets: UIEdgeInsets(top: 1.0, left: 0.0, bottom: 20.0, right: 0.0))
        if let newValue = assistant.updateValue(inObject: old_value, newValues: ["top" : 10.0]) as? NSValue {
            XCTAssertEqual(newValue.uiEdgeInsetsValue.top, 11.0)
            XCTAssertEqual(newValue.uiEdgeInsetsValue.bottom, old_value.uiEdgeInsetsValue.bottom)
        } else {
            XCTFail("Could not update top value")
        }
    }
    
    func test_updateValue_UIOffset() {
        let assistant = UIKitStructAssistant()
        var old_value = NSValue.init(uiOffset: UIOffset(horizontal: 10.0, vertical: 20.0))
        
        if let newValue = assistant.updateValue(inObject: old_value, newValues: ["horizontal" : 10.0]) as? NSValue {
            XCTAssertEqual(newValue.uiOffsetValue.horizontal, 10.0)
            XCTAssertEqual(newValue.uiOffsetValue.vertical, old_value.uiOffsetValue.vertical)
        } else {
            XCTFail("Could not update horizontal value")
        }
        
        // additive
        assistant.additive = true
        old_value = NSValue.init(uiOffset: UIOffset(horizontal: 1.0, vertical: 20.0))
        if let newValue = assistant.updateValue(inObject: old_value, newValues: ["horizontal" : 10.0]) as? NSValue {
            XCTAssertEqual(newValue.uiOffsetValue.horizontal, 11.0)
            XCTAssertEqual(newValue.uiOffsetValue.vertical, old_value.uiOffsetValue.vertical)
        } else {
            XCTFail("Could not update horizontal value")
        }
    }

    
    // MARK: retrieveValue
    
    func test_retrieveValue_UIEdgeInsets() {
        let assistant = UIKitStructAssistant()
        let object = NSValue.init(uiEdgeInsets: UIEdgeInsets(top: 10.0, left: 0.0, bottom: 20.0, right: 0.0))
        do {
            let value = try assistant.retrieveValue(inObject: object, keyPath: "top")
            XCTAssertEqual(value, 10.0)
        } catch ValueAssistantError.typeRequirement(let valueType) {
            XCTFail("top value could not be retrieved for \(valueType)")
        } catch {
            XCTFail("error \(error)")
        }
    }
    
    func test_retrieveValue_UIOffset() {
        let assistant = UIKitStructAssistant()
        let object = NSValue.init(uiOffset: UIOffset(horizontal: 10.0, vertical: 20.0))
        do {
            let value = try assistant.retrieveValue(inObject: object, keyPath: "horizontal")
            XCTAssertEqual(value, 10.0)
        } catch ValueAssistantError.typeRequirement(let valueType) {
            XCTFail("top value could not be retrieved for \(valueType)")
        } catch {
            XCTFail("error \(error)")
        }
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
            XCTFail("error \(error)")
        }
        
    }
    
}
