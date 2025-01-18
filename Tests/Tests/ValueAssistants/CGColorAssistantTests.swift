//
//  CGColorAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor final class CGColorAssistantTests: XCTestCase {

    func test_generateProperties() {
        let assistant = CGColorAssistant<Tester>()
        let tester = Tester()
        let new_color = CGColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let state = MotionState(keyPath: \Tester.cgColor, end: new_color)
        
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 1 prop because only blue value is changed from original color
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let redProperty = props[0]
                let blueProperty = props[1]
                // should test that ending property state was captured and start state is set to original color value
                XCTAssertEqual(redProperty.keyPath, \Tester.cgColor.components[default: [CGFloat]()][0])
                XCTAssertEqual(redProperty.start, tester.cgColor.components?[0].toDouble())
                XCTAssertEqual(redProperty.end, 0.0)
                XCTAssertEqual(blueProperty.keyPath, \Tester.cgColor.components[default: [CGFloat]()][2])
                XCTAssertEqual(blueProperty.start, tester.cgColor.components?[2].toDouble())
                XCTAssertEqual(blueProperty.end, 0.5)
            }
        } catch {
            XCTFail("Could not generate properties for \(state)")
        }
        
    }
    
    func test_generateProperties_start_state() {
        let assistant = CGColorAssistant<Tester>()
        let tester = Tester()
        let color = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let new_color = CGColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let state = MotionState(keyPath: \Tester.cgColor, start: color, end: new_color)
        
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 1 prop because only blue value is changed from original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let property = props[0]
                // should test that ending property state was captured and start state is set to original color value
                XCTAssertEqual(property.keyPath, \Tester.cgColor.components[default: [CGFloat]()][2])
                XCTAssertEqual(property.start, 0.0)
                XCTAssertEqual(property.end, 0.5)
            }
        } catch {
            XCTFail("Could not generate properties for \(state)")
        }
        
    }
    
    func test_supports() {
        let assistant = CGColorAssistant<Tester>()
        let tester = Tester()

        XCTAssertTrue(assistant.supports(tester.cgColor))
        
        XCTAssertFalse(assistant.supports(tester.value))
        XCTAssertFalse(assistant.supports(tester.color))
    }
    
    func test_update() {
        let assistant = CGColorAssistant<Tester>()
        let tester = Tester()
        
        let finalValue: Double = 0.9
        let path = \Tester.cgColor
        let state = MotionState(keyPath: path, end: CGColor(red: finalValue, green: 0.5, blue: 0.7, alpha: 1.0))
        let motion = Motion(target: tester, states: state, duration: 1.5)
        guard let property = motion.properties.first(where: { $0.stringPath == "0" }) else {
            XCTFail("Could not find property")
            return
        }
        property.current = finalValue
        property.targetObject = tester
        
        assistant.update(properties: [property: finalValue], targetObject: tester)
        
        if let parentValue = property.retrieveParentValue(from: tester), let color = assistant.castToCGColor(object: parentValue) {
            XCTAssertEqual(color.components?[0].toDouble(), finalValue)
        } else {
            XCTFail("Could not retrieve color object")
        }
    }

    func test_update_additive() {
        let assistant = CGColorAssistant<Tester>()
        assistant.isAdditive = true
        let tester = Tester()
        
        let delta: Double = 0.1
        let initialValue: CGFloat = 0.0
        let finalValue: Double = 0.9
        let path = \Tester.cgColor
        let component: Int = 2
        let state = MotionState(keyPath: path, end: CGColor(red: 0.0, green: 0.5, blue: finalValue, alpha: 1.0))
        let motion = Motion(target: tester, states: state, duration: 1.5, options: [.additive])
        guard let property = motion.properties.first(where: { $0.stringPath == "\(component)" }) else {
            XCTFail("Could not find property")
            return
        }
        property.current = 0.5
        property.targetObject = tester
        
        assistant.update(properties: [property: delta], targetObject: tester)

        if let parentValue = property.retrieveParentValue(from: tester), let color = assistant.castToCGColor(object: parentValue) {
            let newValue = color.components?[component].toDouble() ?? 0.0
            XCTAssertEqual(newValue, initialValue + delta)
            
        } else {
            XCTFail("Could not retrieve color object")
        }
    }
}
