//
//  CIColorAssistantTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/26/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

class CIColorAssistantTests: XCTestCase {
    
    func test_generateProperties() {
        let assistant = CIColorAssistant()
        let color = CIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let new_color = CIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let props = assistant.generateProperties(fromObject: new_color, keyPath: "", targetObject: color)
        
        XCTAssertEqual(props.count, 1)
        
        let color_prop = props[0]
        XCTAssertEqual(color_prop.path, "blue")
        XCTAssertEqual(color_prop.end, 0.5)
        
    }
    
    func test_updateValue() {
        let assistant = CIColorAssistant()
        
        var old_value = CIColor.init(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        var new_value: CIColor
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["red" : 1.0]) as! CIColor
        XCTAssertEqual(new_value.red, 1.0)
        XCTAssertEqual(new_value.blue, 0.0)
        
        
        // additive
        assistant.additive = true
        old_value = CIColor.init(red: 0.2, green: 0.5, blue: 0.0, alpha: 1.0)
        new_value = assistant.updateValue(inObject: old_value, newValues: ["red" : 0.3]) as! CIColor
        XCTAssertEqual(new_value.red, 0.5)
        XCTAssertEqual(new_value.green, 0.5)
        
        
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
