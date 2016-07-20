//
//  ValueAssistantGroupTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/24/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

class ValueAssistantGroupTests: XCTestCase {

    
    func test_add() {
        let assistant = ValueAssistantGroup()
        assistant.add(CGStructAssistant())
        
        XCTAssertEqual(assistant.assistants.count, 1)
    }
    
    
    func test_additive() {
        let structs = CGStructAssistant()
        let ci_colors = CIColorAssistant()
        let ui_colors = UIColorAssistant()
        let assistant = ValueAssistantGroup(assistants: [structs, ci_colors, ui_colors])

        assistant.additive = true
        assistant.additiveWeighting = 0.5
        
        XCTAssertEqual(structs.additive, assistant.additive)
        XCTAssertEqual(ci_colors.additive, assistant.additive)
        XCTAssertEqual(ui_colors.additive, assistant.additive)
        XCTAssertEqual(structs.additiveWeighting, assistant.additiveWeighting)
        XCTAssertEqual(ci_colors.additiveWeighting, assistant.additiveWeighting)
        XCTAssertEqual(ui_colors.additiveWeighting, assistant.additiveWeighting)

    }

    
    func test_generateProperties() {
        let assistant = ValueAssistantGroup(assistants: [CGStructAssistant(), CIColorAssistant(), UIColorAssistant()])
        let tester = Tester()
        let rect = CGRect.init(x: 0.0, y: 10.0, width: 50.0, height: 0.0)
        let path = "rect"
        if let struct_val = CGStructAssistant.valueForCGStruct(rect), let target = tester.value(forKeyPath: path) {
            let props = assistant.generateProperties(fromObject: struct_val, keyPath: path, targetObject: target)
            
            XCTAssertEqual(props.count, 2)
            
            let y_prop = props[0]
            let width_prop = props[1]
            XCTAssertEqual(y_prop.path, "rect.origin.y")
            XCTAssertEqual(y_prop.end, 10.0)
            XCTAssertEqual(width_prop.path, "rect.size.width")
            XCTAssertEqual(width_prop.end, 50.0)
        }
        
    }
    
    
    func test_updateValue_CGRect() {
        let assistant = ValueAssistantGroup(assistants: [CGStructAssistant()])

        let old_value = NSValue.init(cgRect: CGRect.init(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        var new_value: NSValue
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["origin.x" : 10.0]) as! NSValue
        XCTAssertEqual(new_value.cgRectValue().origin.x, 10.0)
        XCTAssertEqual(new_value.cgRectValue().origin.y, old_value.cgRectValue().origin.y)
    }
    
    func test_updateValue_UIColor() {
        let assistant = ValueAssistantGroup(assistants: [CGStructAssistant(), UIColorAssistant()])

        let old_value = UIColor.init(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        var new_value: UIColor
        
        new_value = assistant.updateValue(inObject: old_value, newValues: ["red" : 1.0]) as! UIColor
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        new_value.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1.0)
        XCTAssertEqual(blue, 0.0)
    }
    
    func test_retrieveValue() {
        let assistant = ValueAssistantGroup(assistants: [CGStructAssistant(), UIColorAssistant()])

        let object = NSValue.init(cgRect: CGRect.init(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        let value = assistant.retrieveValue(inObject: object, keyPath: "size.width")
        XCTAssertEqual(value, 10.0)
        
        var color = UIColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        var cvalue = assistant.retrieveValue(inObject: color, keyPath: "blue")
        XCTAssertEqual(cvalue, 0.5)
        
        color = UIColor.init(hue: 0.5, saturation: 0.2, brightness: 1.0, alpha: 1.0)
        cvalue = assistant.retrieveValue(inObject: color, keyPath: "hue")
        XCTAssertEqual(cvalue, 0.5)
    }
    
}
