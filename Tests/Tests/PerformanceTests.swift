//
//  PerformanceTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 1/16/25.
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

@MainActor final class PerformanceTests: XCTestCase {

    let motionCount = 5000
    
    func test_performance_update_numeric() {
        
        var motions = [Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.float, end: 100.0)
            let motion = Motion(target: tester, states: state, duration: 2)
            motions.append(motion)
        }
        
        let assistant = NumericAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            for motion in motions {
                if let property = motion.properties.first, let targetObject = motion.targetObject {
                    let newValue = property.current
                    assistant.update(properties: [property: newValue], targetObject: targetObject)
                }
                    
            }
        }
    }

    func test_performance_update_CGRect() {
        
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.rect, end: CGRect(x: 20, y: 20, width: 50, height: 50))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
        
        var values = [[PropertyData<Tester>: Double]]()
        for (_, motion) in motions {
            let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
            
            for (_, groupedProperties) in grouped {
                var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                for property in groupedProperties {
                    valuesForProperties[property] = property.current
                }
                values.append(valuesForProperties)
            }
        }
        
        let assistant = CGStructAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            var x = 0
            for (tester, _) in motions {
                let valuesForProperties = values[x]
                assistant.update(properties: valuesForProperties, targetObject: tester)
                x += 1
            }
        }
        
    }
    
    
    func test_performance_update_CGPoint() {
        
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.point, end: CGPoint(x: 100, y: 100))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
        
        var values = [[PropertyData<Tester>: Double]]()
        for (_, motion) in motions {
            let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
            
            for (_, groupedProperties) in grouped {
                var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                for property in groupedProperties {
                    valuesForProperties[property] = property.current
                }
                values.append(valuesForProperties)
            }
        }
        
        let assistant = CGStructAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            var x = 0
            for (tester, _) in motions {
                let valuesForProperties = values[x]
                assistant.update(properties: valuesForProperties, targetObject: tester)
                x += 1
            }
        }
        
    }
    
    
    func test_performance_update_UIColor() {
        
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.color, end: .blue)
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
        
        var values = [[PropertyData<Tester>: Double]]()
        for (_, motion) in motions {
            let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
            
            for (_, groupedProperties) in grouped {
                var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                for property in groupedProperties {
                    valuesForProperties[property] = property.current
                }
                values.append(valuesForProperties)
            }
        }
        
        let assistant = UIColorAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            var x = 0
            for (tester, _) in motions {
                let valuesForProperties = values[x]
                assistant.update(properties: valuesForProperties, targetObject: tester)
                x += 1
            }
        }
        
    }
    
#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
    func test_performance_update_CIColor() {
        
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.ciColor, end: .blue)
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
        
        var values = [[PropertyData<Tester>: Double]]()
        for (_, motion) in motions {
            let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
            
            for (_, groupedProperties) in grouped {
                var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                for property in groupedProperties {
                    valuesForProperties[property] = property.current
                }
                values.append(valuesForProperties)
            }
        }
        
        let assistant = CIColorAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            var x = 0
            for (tester, _) in motions {
                let valuesForProperties = values[x]
                assistant.update(properties: valuesForProperties, targetObject: tester)
                x += 1
            }
        }
        
    }
#endif
    
    
    func test_performance_update_CGColor() {
        
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.cgColor, end: UIColor.blue.cgColor)
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
        
        var values = [[PropertyData<Tester>: Double]]()
        for (_, motion) in motions {
            let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
            
            for (_, groupedProperties) in grouped {
                var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                for property in groupedProperties {
                    valuesForProperties[property] = property.current
                }
                values.append(valuesForProperties)
            }
        }
        
        let assistant = CGColorAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            var x = 0
            for (tester, _) in motions {
                let valuesForProperties = values[x]
                assistant.update(properties: valuesForProperties, targetObject: tester)
                x += 1
            }
        }
        
    }
    
    func test_performance_update_simd3() {
        
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.simd3, end: SIMD3(repeating: 100))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
        
        var values = [[PropertyData<Tester>: Double]]()
        for (_, motion) in motions {
            let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
            
            for (_, groupedProperties) in grouped {
                var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                for property in groupedProperties {
                    valuesForProperties[property] = property.current
                }
                values.append(valuesForProperties)
            }
        }
        
        let assistant = SIMDAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            var x = 0
            for (tester, _) in motions {
                let valuesForProperties = values[x]
                assistant.update(properties: valuesForProperties, targetObject: tester)
                x += 1
            }
        }
        
    }
    
    func test_performance_update_simd8() {
        
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.simd8Double, end: SIMD8(repeating: 100.0))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
        
        var values = [[PropertyData<Tester>: Double]]()
        for (_, motion) in motions {
            let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
            
            for (_, groupedProperties) in grouped {
                var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                for property in groupedProperties {
                    valuesForProperties[property] = property.current
                }
                values.append(valuesForProperties)
            }
        }
        
        let assistant = SIMDAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            var x = 0
            for (tester, _) in motions {
                let valuesForProperties = values[x]
                assistant.update(properties: valuesForProperties, targetObject: tester)
                x += 1
            }
        }
        
    }
    
    
    func test_performance_update_simd64() {
        
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.simd64Double, end: SIMD64(repeating: 200.0))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
        
        var values = [[PropertyData<Tester>: Double]]()
        for (_, motion) in motions {
            let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
            
            for (_, groupedProperties) in grouped {
                var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                for property in groupedProperties {
                    valuesForProperties[property] = property.current
                }
                values.append(valuesForProperties)
            }
        }
        
        let assistant = SIMDAssistant<Tester>()
    
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            var x = 0
            for (tester, _) in motions {
                let valuesForProperties = values[x]
                assistant.update(properties: valuesForProperties, targetObject: tester)
                x += 1
            }
        }
        
    }
    
    func test_motion_updateProperties() {
        var motions = [Tester: Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.simd8, end: SIMD8(repeating: 100.0))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions[tester] = motion
        }
            
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            for (_, motion) in motions {
                let grouped = Dictionary(grouping: motion.properties, by: { $0.parentPath ?? $0.keyPath })
                
                for (_, groupedProperties) in grouped {
                    var valuesForProperties: [PropertyData<Tester>: Double] = [:]
                    for property in groupedProperties {
                        valuesForProperties[property] = property.current
                    }

                }
                    
            }
        }
    }
    
    
    func test_performance_full_test_numeric() {
        
        var motions = [Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.value, end: 200.0)
            let motion = Motion(target: tester, states: state, duration: 2)
            motions.append(motion)
        }

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            for motion in motions {
                motion.test_updatePropertyValues(properties: motion.properties)
            }
        }
        
    }
    
    func test_performance_full_test_CGPoint() {
        
        var motions = [Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.point, end: CGPoint(x: 100, y: 100))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions.append(motion)
        }

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            for motion in motions {
                motion.test_updatePropertyValues(properties: motion.properties)
            }
        }
        
    }
    
    
    func test_performance_full_test_CGRect() {
        
        var motions = [Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.rect, end: CGRect(x: 50, y: 50, width: 100, height: 100))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions.append(motion)
        }

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            for motion in motions {
                motion.test_updatePropertyValues(properties: motion.properties)
            }
        }
        
    }
    
    func test_performance_full_test_UIColor() {
        
        var motions = [Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.color, end: .blue)
            let motion = Motion(target: tester, states: state, duration: 2)
            motions.append(motion)
        }

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            for motion in motions {
                motion.test_updatePropertyValues(properties: motion.properties)
            }
        }
        
    }
    
    func test_performance_full_test_simd64() {
        
        var motions = [Motion<Tester>]()
        
        for _ in 0..<motionCount {
            let tester = Tester()
            let state = MotionState(keyPath: \Tester.simd64Double, end: SIMD64(repeating: 200.0))
            let motion = Motion(target: tester, states: state, duration: 2)
            motions.append(motion)
        }

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        self.measure(options: options) {
            for motion in motions {
                motion.test_updatePropertyValues(properties: motion.properties)
            }
        }
        
    }
}
