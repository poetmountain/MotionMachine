//
//  CGStructAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class CGStructAssistantTests: XCTestCase {

    // MARK: generateProperties
    
    func test_generateProperties_rect() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        let end_rect = CGRect(x: 0.0, y: 20.0, width: 50.0, height: 100.0)
        let path = \Tester.rect
        
        let state = MotionState(keyPath: path, end: end_rect)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have three props because x is unchanged from original rect
            XCTAssertEqual(props.count, 3)
            
            if (props.count == 3) {
                let y_prop = props[0]
                let width_prop = props[1]
                let height_prop = props[2]
                // should test that ending property states were captured and start states are set to existing rect values
                XCTAssertEqual(y_prop.keyPath, \Tester.rect.origin.y)
                XCTAssertEqual(y_prop.start, 0.0)
                XCTAssertEqual(y_prop.end, Double(end_rect.origin.y))
                XCTAssertEqual(width_prop.keyPath, \Tester.rect.size.width)
                XCTAssertEqual(width_prop.start, 0.0)
                XCTAssertEqual(width_prop.end, Double(end_rect.size.width))
                XCTAssertEqual(height_prop.keyPath, \Tester.rect.size.height)
                XCTAssertEqual(height_prop.start, 0.0)
                XCTAssertEqual(height_prop.end, Double(end_rect.size.height))
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }

        
        
    }
    
    func test_generateProperties_rect_origin() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        let end_pt = CGPoint(x: 50.0, y: 75.0)
        let path = \Tester.rect.origin
        
        let state = MotionState(keyPath: path, end: end_pt)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should have 2 props because both props changed
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let x_prop = props[0]
                let y_prop = props[1]
                // should test that ending property states were captured and start states are set to existing rect origin
                XCTAssertEqual(x_prop.keyPath, \Tester.rect.origin.x)
                XCTAssertEqual(x_prop.start, 0.0)
                XCTAssertEqual(x_prop.end, Double(end_pt.x))
                XCTAssertEqual(y_prop.keyPath, \Tester.rect.origin.y)
                XCTAssertEqual(y_prop.start, 0.0)
                XCTAssertEqual(y_prop.end, Double(end_pt.y))
            }
        } catch {
            XCTFail("Generating properties \(error)")
        }
        
    }
    
    func test_generateProperties_rect_size() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        let end_size = CGSize(width: 100.0, height: 150.0)
        let path = \Tester.rect.size

        let state = MotionState(keyPath: path, end: end_size)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should have 2 props because both props changed
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let width_prop = props[0]
                let height_prop = props[1]
                // should test that ending property states were captured and start states are set to existing rect size
                XCTAssertEqual(width_prop.keyPath, \Tester.rect.size.width)
                XCTAssertEqual(width_prop.start, 0.0)
                XCTAssertEqual(width_prop.end, Double(end_size.width))
                XCTAssertEqual(height_prop.keyPath, \Tester.rect.size.height)
                XCTAssertEqual(height_prop.start, 0.0)
                XCTAssertEqual(height_prop.end, Double(end_size.height))
            }
        } catch {
            XCTFail("Generating properties \(error)")
        }
        
    }
    
    func test_generateProperties_start_states() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        let start_rect = CGRect(x: 0.0, y: 5.0, width: 20.0, height: 20.0)
        let end_rect = CGRect(x: 0.0, y: 00.0, width: 50.0, height: 100.0)
        let path = \Tester.rect

        let state = MotionState(keyPath: path, start: start_rect, end: end_rect)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have three props because x is unchanged from original rect
            XCTAssertEqual(props.count, 3)
            
            if (props.count == 3) {
                let y_prop = props[0]
                let width_prop = props[1]
                let height_prop = props[2]
                // should test that both the starting and ending property states were captured
                // the y prop is included by MotionMachine because even though the ending value is equal to the original value,
                // a different starting value was specified
                XCTAssertEqual(y_prop.keyPath, \Tester.rect.origin.y)
                XCTAssertEqual(y_prop.start, Double(start_rect.origin.y))
                XCTAssertEqual(y_prop.end, Double(end_rect.origin.y))
                XCTAssertEqual(width_prop.keyPath, \Tester.rect.size.width)
                XCTAssertEqual(width_prop.start, Double(start_rect.size.width))
                XCTAssertEqual(width_prop.end, Double(end_rect.size.width))
                XCTAssertEqual(height_prop.keyPath, \Tester.rect.size.height)
                XCTAssertEqual(height_prop.start, Double(start_rect.size.height))
                XCTAssertEqual(height_prop.end, Double(end_rect.size.height))
            }
        } catch {
            XCTFail("Generating properties \(error)")
        }
        
        
    }
    
    // test to make sure sub-CGStructs get starting states set
    func test_generateProperties_rect_size_with_start_states() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        let start_size = CGSize(width: 20.0, height: 50.0)
        let end_size = CGSize(width: 20.0, height: 150.0)
        let path = \Tester.rect.size
        
        let state = MotionState(keyPath: path, start: start_size, end: end_size)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            if let height_prop = props.first(where: { $0.keyPath == \Tester.rect.size.height }) {
                // should test that start gets the start value from the MotionState object
                XCTAssertEqual(height_prop.keyPath, \Tester.rect.size.height)
                XCTAssertEqual(height_prop.start, Double(start_size.height))
                XCTAssertEqual(height_prop.end, Double(end_size.height))
            } else {
                XCTFail("No height property found")
            }
        
        } catch {
            XCTFail("Generating properties \(error)")
        }
        
    }
    
    func test_generateProperties_vector() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        let start_vector = CGVector(dx: 0.0, dy: 0.5)
        let end_vector = CGVector(dx: 10.0, dy: 0.0)
        let path = \Tester.vector
        
        let state = MotionState(keyPath: path, start: start_vector, end: end_vector)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let dx_prop = props[0]
                let dy_prop = props[1]
                // should test that both the starting and ending property states were captured
                // the dy prop is included by MotionMachine because even though the ending value is equal to the original value,
                // a different starting value was specified
                XCTAssertEqual(dx_prop.keyPath, \Tester.vector.dx)
                XCTAssertEqual(dx_prop.start, Double(start_vector.dx))
                XCTAssertEqual(dx_prop.end, Double(end_vector.dx))
                XCTAssertEqual(dy_prop.keyPath, \Tester.vector.dy)
                XCTAssertEqual(dy_prop.start, Double(start_vector.dy))
                XCTAssertEqual(dy_prop.end, Double(end_vector.dy))
                
            }
        } catch {
            XCTFail("Generating properties \(error)")
        }
        
        
    }
    
    
    func test_generateProperties_affineTransform() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        let start_transform = CGAffineTransform(a: 0.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
        let end_transform = CGAffineTransform(a: 0.0, b: 0.0, c: 0.0, d: 0.0, tx: 10.0, ty: 10.0)
        let path = \Tester.transform

        let state = MotionState(keyPath: path, start: start_transform, end: end_transform)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // there are 4 props instead of 3 because if the supplied start value is different than the original prop value
            // that PropertyData will get created so the starting value gets set, even if start and end are the same
            XCTAssertEqual(props.count, 4)
            
            if (props.count == 4) {
                let d_prop = props[1]
                let tx_prop = props[2]
                let ty_prop = props[3]
                // should test that both the starting and ending property states were captured
                // the d prop is included by MotionMachine because even though the ending value is equal to the original value,
                // a different starting value was specified
                XCTAssertEqual(d_prop.keyPath, \Tester.transform.d)
                XCTAssertEqual(d_prop.start, Double(start_transform.d))
                XCTAssertEqual(d_prop.end, Double(end_transform.d))
                XCTAssertEqual(tx_prop.keyPath, \Tester.transform.tx)
                XCTAssertEqual(tx_prop.start, Double(start_transform.tx))
                XCTAssertEqual(tx_prop.end, Double(end_transform.tx))
                XCTAssertEqual(ty_prop.keyPath, \Tester.transform.ty)
                XCTAssertEqual(ty_prop.start, Double(start_transform.ty))
                XCTAssertEqual(ty_prop.end, Double(end_transform.ty))
            }
        } catch {
            XCTFail("Generating properties \(error)")
        }
        
        
    }
    
#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
    func test_generateProperties_transform3D() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        let start_transform = CATransform3D(m11: 0.0, m12: 5.0, m13: 0.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0)
        let end_transform = CATransform3D(m11: 10.0, m12: 0.0, m13: 20.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0)
        let path = \Tester.transform3D

        let state = MotionState(keyPath: path, start: start_transform, end: end_transform)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // there are 6 props instead of 3 because if the supplied start value is different than the original prop value
            // that PropertyData will get created so the starting value gets set, even if start and end are the same
            XCTAssertEqual(props.count, 6)
            
            if (props.count == 6) {
                let m11_prop = props[0]
                let m12_prop = props[1]
                let m13_prop = props[2]
                // should test that both the starting and ending property states were captured
                // the m12 prop is included by MotionMachine because even though the ending value is equal to the original value,
                // a different starting value was specified
                XCTAssertEqual(m11_prop.keyPath, \Tester.transform3D.m11)
                XCTAssertEqual(m11_prop.start, Double(start_transform.m11))
                XCTAssertEqual(m11_prop.end, Double(end_transform.m11))
                XCTAssertEqual(m12_prop.keyPath, \Tester.transform3D.m12)
                XCTAssertEqual(m12_prop.start, Double(start_transform.m12))
                XCTAssertEqual(m12_prop.end, Double(end_transform.m12))
                XCTAssertEqual(m13_prop.keyPath, \Tester.transform3D.m13)
                XCTAssertEqual(m13_prop.start, Double(start_transform.m13))
                XCTAssertEqual(m13_prop.end, Double(end_transform.m13))
            }
        } catch {
            XCTFail("Generating properties \(error)")
        }
        
        
    }
#endif
    
    func test_supports() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()

        XCTAssertTrue(assistant.supports(tester.size))
        XCTAssertTrue(assistant.supports(tester.point))
        XCTAssertTrue(assistant.supports(tester.rect))
        XCTAssertTrue(assistant.supports(tester.transform))
#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
        XCTAssertTrue(assistant.supports(tester.transform3D))
#endif
        XCTAssertTrue(assistant.supports(tester.vector))
        XCTAssertFalse(assistant.supports(tester.value))

    }
    
    func test_update() {
        let assistant = CGStructAssistant<Tester>()
        let tester = Tester()
        
        let finalValue: Double = 50
        let path = \Tester.rect.size.width
        let property = PropertyData(keyPath: path, end: finalValue)
        property.current = finalValue
        property.targetObject = tester
        
        let value = assistant.update(property: property, newValue: finalValue) as? Double
        XCTAssertEqual(value, finalValue)
        
        let objectValue = tester[keyPath: path]
        XCTAssertEqual(objectValue, finalValue)
    }
    
    func test_update_additive() {
        let assistant = CGStructAssistant<Tester>()
        assistant.isAdditive = true
        let tester = Tester()
        
        let finalValue: Double = 50
        let delta = 2.0
        let path = \Tester.rect.size.width
        let property = PropertyData(keyPath: path, end: finalValue)
        property.targetObject = tester
        
        let currentObjectValue = tester[keyPath: path]
        assistant.update(property: property, newValue: delta)
        let newValue = tester[keyPath: path]
        XCTAssertEqual(newValue, currentObjectValue + delta)
    }
    
}
