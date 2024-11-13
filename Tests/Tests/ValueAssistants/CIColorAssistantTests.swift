//
//  CIColorAssistantTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/26/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

@MainActor class CIColorAssistantTests: XCTestCase {
    
    func test_generateProperties() {
        let assistant = CIColorAssistant()
        let color = CIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let new_color = CIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let states = PropertyStates(path: "", end: new_color)
        
        do {
            let props = try assistant.generateProperties(targetObject: color as AnyObject, propertyStates: states)
            
            // should only have 1 prop because only blue value is changed from original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let color_prop = props[0]
                // should test that ending property state was captured and start state is set to original color value
                XCTAssertEqual(color_prop.path, "blue")
                XCTAssertEqual(color_prop.start, 0.0)
                XCTAssertEqual(color_prop.end, 0.5)
            }
        } catch {
            XCTFail("Could not generate properties for \(states)")
        }
        
    }
    
    func test_generateProperties_start_state() {
        let assistant = CIColorAssistant()
        let color = CIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let start_color = CIColor.init(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0)
        let new_color = CIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let states = PropertyStates(path: "", start: start_color, end: new_color)
        
        do {
            let props = try assistant.generateProperties(targetObject: color as AnyObject, propertyStates: states)
            
            // should only have 1 prop because only blue value is changed from original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let color_prop = props[0]
                // should test that both the starting and ending property states were captured
                XCTAssertEqual(color_prop.path, "blue")
                XCTAssertEqual(color_prop.start, 0.2)
                XCTAssertEqual(color_prop.end, 0.5)
            }
        } catch {
            XCTFail("Could not generate properties for \(states)")

        }
    }
    
    func test_updateValue() {
        let assistant = CIColorAssistant()
        
        var old_value = CIColor.init(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        
        if let newValue = assistant.updateValue(inObject: old_value, newValues: ["red" : 1.0]) as? CIColor {
            XCTAssertEqual(newValue.red, 1.0)
            XCTAssertEqual(newValue.blue, 0.0)
        } else {
            XCTFail("Could not update red value")
        }
        
        // additive
        assistant.additive = true
        old_value = CIColor.init(red: 0.2, green: 0.5, blue: 0.0, alpha: 1.0)
        if let newValue = assistant.updateValue(inObject: old_value, newValues: ["red" : 0.3]) as? CIColor {
            XCTAssertEqual(newValue.red, 0.5)
            XCTAssertEqual(newValue.green, 0.5)
        } else {
            XCTFail("Could not update additive red value")
        }
        
    }
    
    func test_retrieveValue() {
        let assistant = CIColorAssistant()
        let object = CIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let value = assistant.retrieveValue(inObject: object, keyPath: "blue")
        XCTAssertEqual(value, 0.5)
        
    }
    
    func test_calculateValue() {
        let assistant = CIColorAssistant()
        let object = CIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        var prop = PropertyData("red")
        prop.current = 0.1
        prop.target = object
        let value = assistant.calculateValue(forProperty: prop, newValue: 1.0)
        XCTAssertEqual(value, CIColor.init(red: 0.1, green: 0.0, blue: 0.5, alpha: 1.0))
        
    }
}
