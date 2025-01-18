//
//  ValueAssistantGroupTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class ValueAssistantGroupTests: XCTestCase {

    
    func test_add() {
        let assistant = ValueAssistantGroup<Tester>()
        assistant.add(CGStructAssistant())
        
        XCTAssertEqual(assistant.assistants.count, 1)
    }
    
    
    func test_additive() {
        let structs = CGStructAssistant<Tester>()
        let cg_colors = CGColorAssistant<Tester>()
        let ui_colors = UIColorAssistant<Tester>()
        let assistant = ValueAssistantGroup(assistants: [structs, cg_colors, ui_colors])

        assistant.isAdditive = true
        assistant.additiveWeighting = 0.5
        
        XCTAssertEqual(structs.isAdditive, assistant.isAdditive)
        XCTAssertEqual(cg_colors.isAdditive, assistant.isAdditive)
        XCTAssertEqual(ui_colors.isAdditive, assistant.isAdditive)
        XCTAssertEqual(structs.additiveWeighting, assistant.additiveWeighting)
        XCTAssertEqual(cg_colors.additiveWeighting, assistant.additiveWeighting)
        XCTAssertEqual(ui_colors.additiveWeighting, assistant.additiveWeighting)

    }

    
    func test_generateProperties() {
        let assistant = ValueAssistantGroup<Tester>(assistants: [CGStructAssistant(), CGColorAssistant(), UIColorAssistant()])
        let tester = Tester()
        let rect = CGRect(x: 0.0, y: 10.0, width: 50.0, height: 0.0)
        let path = \Tester.rect

        let state = MotionState(keyPath: path, end: rect)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let y_prop = props[0]
                let width_prop = props[1]
                XCTAssertEqual(y_prop.keyPath, \Tester.rect.origin.y)
                XCTAssertEqual(y_prop.end, 10.0)
                XCTAssertEqual(width_prop.keyPath, \Tester.rect.size.width)
                XCTAssertEqual(width_prop.end, 50.0)
            }
        } catch {
            XCTFail("CGStruct value was not found")
        }
        
    }
    
    func test_supports() {
        let assistant = ValueAssistantGroup<Tester>(assistants: [CGStructAssistant()])
        let tester = Tester()

        XCTAssertTrue(assistant.supports(tester.rect))
        XCTAssertFalse(assistant.supports(tester.value))

    }
    
    func test_update() {
        let assistant = ValueAssistantGroup<Tester>(assistants: [CGStructAssistant()])
        let tester = Tester()
        
        let finalValue: Double = 50
        let path = \Tester.rect.size.width
        let property = PropertyData(keyPath: path, end: finalValue)
        property.current = finalValue
        property.targetObject = tester
        property.target = tester.rect as AnyObject
        
        assistant.update(properties: [property: finalValue], targetObject: tester)
        
        let objectValue = tester[keyPath: path]
        XCTAssertEqual(objectValue, finalValue)
    }
    
}
