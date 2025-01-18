//
//  UIKitStructAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class UIKitStructAssistantTests: XCTestCase {

    // MARK: generateProperties
    
    func test_generateProperties_UIEdgeInsets() {
        let assistant = UIKitStructAssistant<Tester>()
        let tester = Tester()
        let insets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 20.0, right: 0.0)
        let path = \Tester.insets

        let state = MotionState(keyPath: path, end: insets)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 2 props because left and right are unchanged from original insets
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let top_prop = props[0]
                let bottom_prop = props[1]
                // should test that ending property states were captured and start states are set to existing inset values
                XCTAssertEqual(top_prop.keyPath, \Tester.insets.top)
                XCTAssertEqual(top_prop.start, 0.0)
                XCTAssertEqual(top_prop.end, 10.0)
                XCTAssertEqual(bottom_prop.keyPath, \Tester.insets.bottom)
                XCTAssertEqual(bottom_prop.start, 0.0)
                XCTAssertEqual(bottom_prop.end, 20.0)
            }
        } catch {
            XCTFail("Could not generate properties for \(state)")
        }
        
        
    }
    
    func test_generateProperties_UIEdgeInsets_start_state() {
        let assistant = UIKitStructAssistant<Tester>()
        let tester = Tester()
        let start_insets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 10.0, right: 0.0)
        let insets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 20.0, right: 0.0)
        let path = \Tester.insets

        let state = MotionState(keyPath: path, start: start_insets, end: insets)
        
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 3 props because right is unchanged from original insets
            XCTAssertEqual(props.count, 3)
            
            if (props.count == 3) {
                let top_prop = props[0]
                let left_prop = props[1]
                let bottom_prop = props[2]
                // should test that both the starting and ending property states were captured
                // the left prop is included by MotionMachine because even though the ending value is equal to the original inset value,
                // a different starting value was specified
                XCTAssertEqual(top_prop.keyPath, \Tester.insets.top)
                XCTAssertEqual(top_prop.start, 5.0)
                XCTAssertEqual(top_prop.end, 10.0)
                XCTAssertEqual(left_prop.keyPath, \Tester.insets.left)
                XCTAssertEqual(left_prop.start, 5.0)
                XCTAssertEqual(left_prop.end, 0.0)
                XCTAssertEqual(bottom_prop.keyPath, \Tester.insets.bottom)
                XCTAssertEqual(bottom_prop.start, 10.0)
                XCTAssertEqual(bottom_prop.end, 20.0)
            }
        } catch {
            XCTFail("Could not generate properties for \(state)")
        }

        
    }
    
    
    func test_generateProperties_UIOffset() {
        let assistant = UIKitStructAssistant<Tester>()
        let tester = Tester()
        let offset = UIOffset(horizontal: 10.0, vertical: 20.0)
        let path = \Tester.offset

        let state = MotionState(keyPath: path, end: offset)
        
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should  have 2 props both offset values are changed from original
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let h_prop = props[0]
                let v_prop = props[1]
                // should test that ending property states were captured and start states are set to original offset values
                XCTAssertEqual(h_prop.keyPath, \Tester.offset.horizontal)
                XCTAssertEqual(h_prop.start, 0.0)
                XCTAssertEqual(h_prop.end, 10.0)
                XCTAssertEqual(v_prop.keyPath, \Tester.offset.vertical)
                XCTAssertEqual(v_prop.start, 0.0)
                XCTAssertEqual(v_prop.end, 20.0)
            }
        } catch {
            XCTFail("Could not generate properties for \(state)")

        }
        
        
    }
    
    func test_generateProperties_UIOffset_start_state() {
        let assistant = UIKitStructAssistant<Tester>()
        let tester = Tester()
        let start_offset = UIOffset(horizontal: 5.0, vertical: 10.0)
        let offset = UIOffset(horizontal: 10.0, vertical: 20.0)
        let path = \Tester.offset

        let state = MotionState(keyPath: path, start: start_offset, end: offset)
        
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should  have 2 props both offset values are changed from original
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let h_prop = props[0]
                let v_prop = props[1]
                // should test that both the starting and ending property states were captured
                XCTAssertEqual(h_prop.keyPath, \Tester.offset.horizontal)
                XCTAssertEqual(h_prop.start, 5.0)
                XCTAssertEqual(h_prop.end, 10.0)
                XCTAssertEqual(v_prop.keyPath, \Tester.offset.vertical)
                XCTAssertEqual(v_prop.start, 10.0)
                XCTAssertEqual(v_prop.end, 20.0)
            }
        } catch {
            XCTFail("Could not generate properties for \(state)")
        }

        
    }
    
    func test_supports() {
        let assistant = UIKitStructAssistant<Tester>()
        let tester = Tester()

        XCTAssertTrue(assistant.supports(tester.insets))
        XCTAssertTrue(assistant.supports(tester.offset))
        XCTAssertFalse(assistant.supports(tester.value))

    }
    
    func test_update() {
        let assistant = UIKitStructAssistant<Tester>()
        let tester = Tester()
        
        let finalValue: Double = 10
        let path = \Tester.insets.left
        let property = PropertyData(keyPath: path, end: finalValue)
        property.current = finalValue
        property.targetObject = tester
        
        assistant.update(properties: [property: finalValue], targetObject: tester)
        
        let objectValue = tester[keyPath: path]
        XCTAssertEqual(objectValue, finalValue)
    }
    
    func test_update_additive() {
        let assistant = UIKitStructAssistant<Tester>()
        assistant.isAdditive = true
        let tester = Tester()
        
        let delta = 2.0
        let path = \Tester.insets.left
        let property = PropertyData(keyPath: path, end: 10)
        property.targetObject = tester
        
        let currentObjectValue = tester[keyPath: path]
        assistant.update(properties: [property: delta], targetObject: tester)
        let newValue = tester[keyPath: path]

        XCTAssertEqual(newValue, currentObjectValue + delta)
    }
}
