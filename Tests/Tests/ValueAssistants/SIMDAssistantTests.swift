//
//  SIMDAssistantTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor final class SIMDAssistantTests: XCTestCase {

    func test_generateProperties_simd2() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        let end_simd = SIMD2<Double>(x: 50, y: 75)
        let path = \Tester.simd2
        
        let state = MotionState(keyPath: path, end: end_simd)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let xPath = path.appending(path: \SIMD2.x)
                let yPath = path.appending(path: \SIMD2.y)
                let x_prop = props.first(where: { $0.keyPath == xPath })
                let y_prop = props.first(where: { $0.keyPath == yPath })
                // should test that ending property states were captured and start states are set to existing SIMD values
                XCTAssertEqual(x_prop?.keyPath, xPath)
                XCTAssertEqual(x_prop?.start, tester[keyPath: xPath])
                XCTAssertEqual(x_prop?.end, end_simd.x)
                XCTAssertEqual(y_prop?.keyPath, yPath)
                XCTAssertEqual(y_prop?.end, end_simd.y)
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }
    
    func test_generateProperties_start_states_simd2() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        let start_simd = SIMD2<Double>(x: 25, y: 25)
        let end_simd = SIMD2<Double>(x: 50, y: 75)
        let path = \Tester.simd2
        
        let state = MotionState(keyPath: path, start: start_simd, end: end_simd)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let xPath = path.appending(path: \SIMD2.x)
                let yPath = path.appending(path: \SIMD2.y)
                let x_prop = props.first(where: { $0.keyPath == xPath })
                let y_prop = props.first(where: { $0.keyPath == yPath })
                // should test that ending property states were captured and start states are set to start SIMD values
                XCTAssertEqual(x_prop?.keyPath, xPath)
                XCTAssertEqual(x_prop?.start, start_simd.x)
                XCTAssertEqual(x_prop?.end, end_simd.x)
                XCTAssertEqual(y_prop?.keyPath, yPath)
                XCTAssertEqual(y_prop?.start, start_simd.y)
                XCTAssertEqual(y_prop?.end, end_simd.y)
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }

    func test_generateProperties_simd3() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        let end_simd = SIMD3<Float>(x: 50, y: 75, z: 30)
        let path = \Tester.simd3
        
        let state = MotionState(keyPath: path, end: end_simd)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // we expect 2 props because the end y value is the same as start, so a prop should not be created for it
            XCTAssertEqual(props.count, 2)
            
            if (props.count == 2) {
                let xPath = path.appending(path: \SIMD3.x)
                let yPath = path.appending(path: \SIMD3.y)
                let zPath = path.appending(path: \SIMD3.z)
                let x_prop = props.first(where: { $0.keyPath == xPath })
                let y_prop = props.first(where: { $0.keyPath == yPath })
                let z_prop = props.first(where: { $0.keyPath == zPath })

                // should test that ending property states were captured and start states are set to existing SIMD values
                XCTAssertEqual(x_prop?.keyPath, xPath)
                XCTAssertEqual(x_prop?.start, Double(10))
                XCTAssertEqual(x_prop?.end, Double(end_simd.x))
                XCTAssertNil(y_prop?.keyPath)
                XCTAssertEqual(z_prop?.keyPath, zPath)
                XCTAssertEqual(z_prop?.end, Double(end_simd.z))
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }
    
    func test_generateProperties_simd4() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        let end_simd = SIMD4(x: 50, y: 75, z: 30, w: 50)
        let path = \Tester.simd4
        
        let state = MotionState(keyPath: path, end: end_simd)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, 4)
            
            if (props.count == 4) {
                let xPath = path.appending(path: \SIMD4.x)
                let yPath = path.appending(path: \SIMD4.y)
                let zPath = path.appending(path: \SIMD4.z)
                let wPath = path.appending(path: \SIMD4.w)
                let x_prop = props.first(where: { $0.keyPath == xPath })
                let y_prop = props.first(where: { $0.keyPath == yPath })
                let z_prop = props.first(where: { $0.keyPath == zPath })
                let w_prop = props.first(where: { $0.keyPath == wPath })

                // should test that ending property states were captured and start states are set to existing SIMD values
                XCTAssertEqual(x_prop?.keyPath, xPath)
                XCTAssertEqual(x_prop?.start, Double(10))
                XCTAssertEqual(x_prop?.end, Double(end_simd.x))
                XCTAssertEqual(y_prop?.keyPath, yPath)
                XCTAssertEqual(y_prop?.end, Double(end_simd.y))
                XCTAssertEqual(z_prop?.keyPath, zPath)
                XCTAssertEqual(z_prop?.end, Double(end_simd.z))
                XCTAssertEqual(w_prop?.keyPath, wPath)
                XCTAssertEqual(w_prop?.end, Double(end_simd.w))
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }
    
    func test_generateProperties_simd8() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        let end_simd = SIMD8<Float>(1, 2, 3, 4, 5, 6, 7, 8)
        let path = \Tester.simd8
        
        let state = MotionState(keyPath: path, end: end_simd)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, 8)
            
            if (props.count == 8) {
                let pathFirst = path.appending(path: \SIMD8[0])
                let pathLast = path.appending(path: \SIMD8[7])
                let propFirst = props.first(where: { $0.keyPath == pathFirst })
                let propLast = props.first(where: { $0.keyPath == pathLast })
    
                // should test that ending property states were captured and start states are set to existing SIMD values
                XCTAssertEqual(propFirst?.keyPath, pathFirst)
                XCTAssertEqual(propFirst?.start, Double(10))
                XCTAssertEqual(propFirst?.end, Double(end_simd[0]))
                XCTAssertEqual(propLast?.keyPath, pathLast)
                XCTAssertEqual(propLast?.start, Double(10))
                XCTAssertEqual(propLast?.end, Double(end_simd[7]))
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }
    
    
    func test_generateProperties_simd16() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        let simdCount = 16
        var simdArray: [Float] = []
        for x in 0..<simdCount { simdArray.append(Float(x+1)) }
        let end_simd = SIMD16<Float>(simdArray)
        let path = \Tester.simd16
        
        let state = MotionState(keyPath: path, end: end_simd)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            // should only have 15 props because position 5 has a value of 5 in the original SIMD object
            XCTAssertEqual(props.count, simdCount-1)
            
            if (props.count == simdCount-1) {
                let pathFirst = path.appending(path: \SIMD16[0])
                let pathLast = path.appending(path: \SIMD16[simdCount-1])
                let propFirst = props.first(where: { $0.keyPath == pathFirst })
                let propLast = props.first(where: { $0.keyPath == pathLast })
    
                // should test that ending property states were captured and start states are set to existing SIMD values
                XCTAssertEqual(propFirst?.keyPath, pathFirst)
                XCTAssertEqual(propFirst?.start, Double(tester[keyPath: pathFirst]))
                XCTAssertEqual(propFirst?.end, Double(end_simd[0]))
                XCTAssertEqual(propLast?.keyPath, pathLast)
                XCTAssertEqual(propLast?.start, Double(tester[keyPath: pathFirst]))
                XCTAssertEqual(propLast?.end, Double(end_simd[simdCount-1]))
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }
    
    
    func test_generateProperties_simd32() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        let simdCount = 32
        var simdArray: [Float] = []
        for x in 0..<simdCount { simdArray.append(Float(x+1)) }
        let end_simd = SIMD32<Float>(simdArray)
        let path = \Tester.simd32
        
        let state = MotionState(keyPath: path, end: end_simd)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, simdCount)
            
            if (props.count == simdCount) {
                let pathFirst = path.appending(path: \SIMD32[0])
                let pathLast = path.appending(path: \SIMD32[simdCount-1])
                let propFirst = props.first(where: { $0.keyPath == pathFirst })
                let propLast = props.first(where: { $0.keyPath == pathLast })
    
                // should test that ending property states were captured and start states are set to existing SIMD values
                XCTAssertEqual(propFirst?.keyPath, pathFirst)
                XCTAssertEqual(propFirst?.start, Double(tester[keyPath: pathFirst]))
                XCTAssertEqual(propFirst?.end, Double(end_simd[0]))
                XCTAssertEqual(propLast?.keyPath, pathLast)
                XCTAssertEqual(propLast?.start, Double(tester[keyPath: pathFirst]))
                XCTAssertEqual(propLast?.end, Double(end_simd[simdCount-1]))
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }
    
    
    func test_generateProperties_simd64() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        let simdCount = 64
        var simdArray: [Float] = []
        for x in 0..<simdCount { simdArray.append(Float(x+1)) }
        let end_simd = SIMD64<Float>(simdArray)
        let path = \Tester.simd64
        
        let state = MotionState(keyPath: path, end: end_simd)
        do {
            let props = try assistant.generateProperties(targetObject: tester, state: state)
            
            XCTAssertEqual(props.count, simdCount)
            
            if (props.count == simdCount) {
                let pathFirst = path.appending(path: \SIMD64[0])
                let pathLast = path.appending(path: \SIMD64[simdCount-1])
                let propFirst = props.first(where: { $0.keyPath == pathFirst })
                let propLast = props.first(where: { $0.keyPath == pathLast })
    
                // should test that ending property states were captured and start states are set to existing SIMD values
                XCTAssertEqual(propFirst?.keyPath, pathFirst)
                XCTAssertEqual(propFirst?.start, Double(tester[keyPath: pathFirst]))
                XCTAssertEqual(propFirst?.end, Double(end_simd[0]))
                XCTAssertEqual(propLast?.keyPath, pathLast)
                XCTAssertEqual(propLast?.start, Double(tester[keyPath: pathFirst]))
                XCTAssertEqual(propLast?.end, Double(end_simd[simdCount-1]))
            }
            
        } catch {
            XCTFail("Generating properties \(error)")
        }
    }
    
    func test_supports() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()

        XCTAssertTrue(assistant.supports(tester.simd2))
        XCTAssertTrue(assistant.supports(tester.simd3))
        XCTAssertTrue(assistant.supports(tester.simd4))
        XCTAssertTrue(assistant.supports(tester.simd8))
        XCTAssertTrue(assistant.supports(tester.simd16))
        XCTAssertTrue(assistant.supports(tester.simd32))
        XCTAssertTrue(assistant.supports(tester.simd64))
        XCTAssertFalse(assistant.supports(tester.value))

    }
    
    func test_update() {
        let assistant = SIMDAssistant<Tester>()
        let tester = Tester()
        
        let finalValue: Double = 50
        let path = \Tester.simd2.x
        let property = PropertyData(keyPath: path, parentPath: \Tester.simd2, end: finalValue)
        property.current = finalValue
        property.targetObject = tester
        
        let value = assistant.update(property: property, newValue: finalValue) as? Double
        XCTAssertEqual(value, finalValue)
        
        let objectValue = tester[keyPath: path]
        XCTAssertEqual(objectValue, finalValue, "Expected changed property to be \(finalValue), but found \(String(describing: objectValue)).")
    }
    
    func test_update_additive() {
        let assistant = SIMDAssistant<Tester>()
        assistant.isAdditive = true
        let tester = Tester()
        
        let delta: Double = 2
        let path = \Tester.simd2.x
        let property = PropertyData(keyPath: path, end: 50)
        property.targetObject = tester
        
        let currentObjectValue = tester[keyPath: path]
        assistant.update(property: property, newValue: delta)
        let newValue = tester[keyPath: path]
        XCTAssertEqual(newValue, currentObjectValue + delta)
    }
}
