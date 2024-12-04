//
//  ColorAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class UIColorAssistantTests: XCTestCase {
    
    func test_generateProperties() {
        let assistant = UIColorAssistant()
        let color = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let new_color = UIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let states = PropertyStates(path: "", end: new_color)
        do {
            let props = try assistant.generateProperties(targetObject: color, propertyStates: states)
            
            // should only have 1 prop because only blue value is changed from the original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let color_prop = props[0]
                // should test that ending property state was captured and start state is set to original color value
                XCTAssertEqual(color_prop.path, "blue")
                XCTAssertEqual(color_prop.start, 0.0)
                XCTAssertEqual(color_prop.end, 0.5)
            }
        } catch {
            XCTFail("Color value was not found")
        }
    }

    func test_generateProperties_start_state() {
        let assistant = UIColorAssistant()
        let color = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let start_color = UIColor.init(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0)
        let new_color = UIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let states = PropertyStates(path: "", start: start_color, end: new_color)
        
        do {
            let props = try assistant.generateProperties(targetObject: color, propertyStates: states)
            
            // should only have 1 prop because only blue value is changed from the original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let color_prop = props[0]
                // should test that both the starting and ending property states were captured
                XCTAssertEqual(color_prop.path, "blue")
                XCTAssertEqual(color_prop.start, 0.2)
                XCTAssertEqual(color_prop.end, 0.5)
            }
        } catch {
            XCTFail("Color value was not found")

        }
    }
    
    func test_updateValue() {
        let assistant = UIColorAssistant()
        var old_value = UIColor.init(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        
        if let newValue = assistant.updateValue(inObject: old_value, newValues: ["red" : 1.0]) as? UIColor {
            var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
            newValue.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            XCTAssertEqual(red, 1.0)
            XCTAssertEqual(blue, 0.0)
        } else {
            XCTFail("Red value was not found")
        }
        
        // additive
        assistant.additive = true
        old_value = UIColor.init(red: 0.2, green: 0.5, blue: 0.0, alpha: 1.0)
        if let newValue = assistant.updateValue(inObject: old_value, newValues: ["red" : 0.3]) as? UIColor {
            var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
            newValue.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            XCTAssertEqual(red, 0.5)
            XCTAssertEqual(green, 0.5)
        } else {
            XCTFail("Red value was not found")
        }
    }
    

    func test_retrieveValue() {
        let assistant = UIColorAssistant()
        var object = UIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        var value = assistant.retrieveValue(inObject: object, keyPath: "blue")
        XCTAssertEqual(value, 0.5)
        
        object = UIColor.init(hue: 0.5, saturation: 0.2, brightness: 1.0, alpha: 1.0)
        value = assistant.retrieveValue(inObject: object, keyPath: "hue")
        XCTAssertEqual(value, 0.5)
    }
    
    func test_calculateValue() {
        let assistant = UIColorAssistant()
        let object = UIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        var prop = PropertyData("red")
        prop.current = 0.1
        prop.target = object
        let value = assistant.calculateValue(forProperty: prop, newValue: 0.7)
        XCTAssertEqual(value, UIColor.init(red: 0.1, green: 0.0, blue: 0.5, alpha: 1.0))
        
    }
    

}
