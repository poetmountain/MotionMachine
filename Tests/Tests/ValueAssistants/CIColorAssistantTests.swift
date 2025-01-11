//
//  CIColorAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest


@MainActor class CIColorAssistantTests: XCTestCase {
#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
    func test_generateProperties() {
        let assistant = CIColorAssistant<Tester>()
        let tester = Tester()
        let newColor = CIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        let state = MotionState(keyPath: \Tester.ciColor, end: newColor)
        
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 1 prop because only blue value is changed from original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let property = props[0]
                // should test that ending property state was captured and start state is set to original color value
                XCTAssertEqual(property.keyPath, \Tester.ciColor.red)
                XCTAssertEqual(property.start, tester.ciColor.red)
                XCTAssertEqual(property.end, 0.5)
            }
        } catch {
            XCTFail("Could not generate properties for \(state)")
        }
        
    }
    
    func test_generateProperties_start_state() {
        let assistant = CIColorAssistant<Tester>()
        let tester = Tester()
        let start_color = CIColor(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0)
        let new_color = CIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let state = MotionState(keyPath: \Tester.ciColor, start: start_color, end: new_color)
        
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 1 prop because only blue value is changed from original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let color_prop = props[0]
                // should test that both the starting and ending property states were captured
                XCTAssertEqual(color_prop.keyPath, \Tester.ciColor.blue)
                XCTAssertEqual(color_prop.start, 0.2)
                XCTAssertEqual(color_prop.end, 0.5)
            }
        } catch {
            XCTFail("Could not generate properties for \(state)")

        }
    }
    
    
    func test_supports() {
        let assistant = CIColorAssistant<Tester>()
        let tester = Tester()

        XCTAssertTrue(assistant.supports(tester.ciColor))
        XCTAssertFalse(assistant.supports(tester.value))

    }
    
    func test_update() {
        let assistant = CIColorAssistant<Tester>()
        let tester = Tester()
        
        let finalValue: Double = 0.9
        let path = \Tester.ciColor
        let propertyPath = path.appending(path: \.red)
        let state = MotionState(keyPath: path, end: CIColor(red: finalValue, green: 0.5, blue: 0.7))
        let motion = Motion(target: tester, states: state, duration: 1.5)
        guard let property = motion.properties.first(where: { $0.keyPath == propertyPath }) else {
            XCTFail("Could not create property")
            return
        }
        property.current = finalValue
        property.targetObject = tester
        
        if let value = assistant.update(property: property, newValue: finalValue) as? any BinaryFloatingPoint {
            XCTAssertEqual(Double(value), finalValue)
        } else {
            XCTFail("No final value found")
        }
        
        let objectValue = tester[keyPath: propertyPath]
        XCTAssertEqual(objectValue, finalValue)
        
    }
    
    func test_update_additive() {
        let assistant = CIColorAssistant<Tester>()
        assistant.isAdditive = true
        let tester = Tester()
        tester.ciColor = CIColor.blue
        
        let finalValue: Double = 0.9
        let delta = 0.2
        let path = \Tester.ciColor
        let propertyPath = path.appending(path: \.red)
        let state = MotionState(keyPath: path, end: CIColor(red: finalValue, green: 0.5, blue: 0.7))
        let motion = Motion(target: tester, states: state, duration: 1.5)
        guard let property = motion.properties.first(where: { $0.keyPath == propertyPath }) else {
            XCTFail("Could not create property")
            return
        }
        property.current = 0.5
        property.targetObject = tester
        
        let currentObjectValue = tester[keyPath: propertyPath]
        assistant.update(property: property, newValue: delta)
        let newValue = tester[keyPath: propertyPath]
        XCTAssertEqual(newValue, currentObjectValue + delta)

    }
#endif
}
