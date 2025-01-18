//
//  ColorAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class UIColorAssistantTests: XCTestCase {
    
    func test_generateProperties() {
        let assistant = UIColorAssistant<Tester>()
        let tester = Tester()
        let color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let new_color = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let state = MotionState(keyPath: \Tester.color, start: color, end: new_color)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 1 prop because only blue value is changed from the original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let color_prop = props[0]
                // should test that ending property state was captured and start state is set to original color value
                XCTAssertEqual(color_prop.stringPath, "blue")
                XCTAssertEqual(color_prop.start, 0.0)
                XCTAssertEqual(color_prop.end, 0.5)
            }
        } catch {
            XCTFail("Color value was not found")
        }
    }

    func test_generateProperties_start_state() {
        let assistant = UIColorAssistant<Tester>()
        let tester = Tester()
        let start_color = UIColor(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0)
        let new_color = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let state = MotionState(keyPath: \Tester.color, start: start_color, end: new_color)
        
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 1 prop because only blue value is changed from the original color
            XCTAssertEqual(props.count, 1)
            
            if (props.count == 1) {
                let color_prop = props[0]
                // should test that both the starting and ending property states were captured
                XCTAssertEqual(color_prop.stringPath, "blue")
                XCTAssertEqual(color_prop.start, 0.2)
                XCTAssertEqual(color_prop.end, 0.5)
            }
        } catch {
            XCTFail("Color value was not found")

        }
    }
    
    
    func test_supports() {
        let assistant = UIColorAssistant<Tester>()
        let tester = Tester()

        XCTAssertTrue(assistant.supports(tester.color))
        XCTAssertFalse(assistant.supports(tester.value))

    }

    func test_update() {
        let assistant = UIColorAssistant<Tester>()
        let tester = Tester()
        
        let finalValue: Double = 0.9
        let finalColor = UIColor(red: finalValue, green: 0.0, blue: 0.0, alpha: 1.0)
        let path = \Tester.color
        let state = MotionState(keyPath: path, end: finalColor)
        let motion = Motion(target: tester, states: state, duration: 1.5)
        guard let property = motion.properties.first(where: { $0.stringPath == "red" }) else {
            XCTFail("Could not create property")
            return
        }
        property.current = finalValue
        
        assistant.update(properties: [property: finalValue], targetObject: tester)

        let newColor = tester[keyPath: \Tester.color]
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        newColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        XCTAssertEqual(Double(red), finalValue)

        
        let objectValue = tester[keyPath: path]
        XCTAssertEqual(objectValue, finalColor)
        
    }
    
    func test_update_additive() {
        let assistant = UIColorAssistant<Tester>()
        assistant.isAdditive = true
        let tester = Tester()
        
        let delta = 0.2
        let finalColor = UIColor.blue
        let state = MotionState(keyPath: \Tester.color, end: finalColor)
        let motion = Motion(target: tester, states: state, duration: 1.5)
        guard let property = motion.properties.first(where: { $0.stringPath == "red" }) else {
            XCTFail("Could not create property")
            return
        }
        property.current = 0.5
        property.targetObject = tester
        
        let currentColor = tester[keyPath: \Tester.color]
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        currentColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        assistant.update(properties: [property: delta], targetObject: tester)
        let newColor = tester[keyPath: \Tester.color]
        var newRed: CGFloat = 0.0, newGreen: CGFloat = 0.0, newBlue: CGFloat = 0.0, newAlpha: CGFloat = 0.0
        newColor.getRed(&newRed, green: &newGreen, blue: &newBlue, alpha: &newAlpha)
        
        XCTAssertEqual(newRed, red + delta)

    }
}
