//
//  NumericAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor final class NumericAssistantTests: XCTestCase {

    func test_generateProperties() {
        let assistant = NumericAssistant<Tester>()
        let tester = Tester()
        let path = \Tester.value
        let finalValue = 50.0
        let state = MotionState(keyPath: path, end: finalValue)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, 1)
            
            if let property = props.first {
                XCTAssertEqual(property.start, tester[keyPath: path])
                XCTAssertEqual(property.end, finalValue)
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }

    func test_supports() {
        let assistant = NumericAssistant<Tester>()
        let tester = Tester()

        XCTAssertTrue(assistant.supports(tester.value))
        XCTAssertFalse(assistant.supports(tester.rect))
    }
    
    func test_update() {
        let assistant = NumericAssistant<Tester>()
        let tester = Tester()
        
        let finalValue: Double = 10
        let path = \Tester.value
        let property = PropertyData(keyPath: path, end: finalValue)
        property.current = finalValue
        property.targetObject = tester
        
        let value = assistant.update(property: property, newValue: finalValue) as? Double
        XCTAssertEqual(value, finalValue)
        
        let objectValue = tester[keyPath: path]
        XCTAssertEqual(objectValue, finalValue)
    }
    
    func test_update_additive() {
        let assistant = NumericAssistant<Tester>()
        assistant.isAdditive = true
        let tester = Tester()
        tester.value = 0.0
        
        let delta: Double = 2
        let path = \Tester.value
        let property = PropertyData(keyPath: path, end: 50)
        property.targetObject = tester
        
        let currentObjectValue = tester[keyPath: path]
        assistant.update(property: property, newValue: delta)
        let newValue = tester[keyPath: path]

        XCTAssertEqual(newValue, currentObjectValue + delta)
    }
}
