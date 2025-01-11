//
//  PhysicsMotionTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class PhysicsMotionTests: XCTestCase {

    // MARK: Setup tests
    
    func test_no_start_params_sets_motion_starts_at_current_object_value() {
        let tester = Tester()
        tester.value = 50.0
        // when a Motion is not passed start values during init, it should assign the object's current object values
        // for the specified props to each PropertyData start value
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 10.0, friction: 0.998)
        
        XCTAssertEqual(motion.properties[0].start, tester.value)
        
    }
    
    func test_add() {
        let tester = Tester()
        let motion = PhysicsMotion(target: tester, velocity: 10.0, friction: 0.998)
        
        // add should add a PropertyData to the properties array
        motion.add(PropertyData(keyPath: \Tester.value))
        XCTAssertEqual(motion.properties.count, 1)
        
    }
    
    func test_afterDelay() {
        let tester = Tester()
        
        // afterDelay should add a delay
        let motion = PhysicsMotion(target: tester, velocity: 10.0, friction: 0.998).afterDelay(1.0)
        XCTAssertEqual(motion.delay, 1.0)
    }
    
    func test_repeats() {
        let tester = Tester()
        
        // repeats should set repeating and amount
        let motion = PhysicsMotion(target: tester, velocity: 10.0, friction: 0.998).repeats(1)
        XCTAssertTrue(motion.isRepeating)
        XCTAssertEqual(motion.repeatCycles, 1)
        
        // if no value provided, repeating should be infinite
        let motion2 = PhysicsMotion(target: tester, velocity: 10.0, friction: 0.998).repeats()
        XCTAssertTrue(motion2.isRepeating)
        XCTAssertEqual(motion2.repeatCycles, PhysicsMotion<Tester>.REPEAT_INFINITE)
    }
    
    
    // MARK: Motion tests
    
    func test_top_level_prop_should_end_at_specified_value() {
        let did_complete = expectation(description: "motion called completed notify closure")
        let tester = Tester()
        let prop = PropertyData(keyPath: \Tester.value)
        let config = PhysicsConfiguration(velocity: 1.5, friction: 0.999)
        let motion = PhysicsMotion(target: tester, properties: [prop], configuration: config)
        .completed { (motion) in
            XCTAssertTrue(motion.velocity < 1.0)
            XCTAssertEqual(motion.totalProgress, 1.0)
            
            did_complete.fulfill()
        }
        motion.velocityDecayLimit = 1.0
        
        motion.start()
        waitForExpectations(timeout: 4.0, handler: nil)
        
    }
    
    func test_object_prop_should_end_at_specified_value() {
        let did_complete = expectation(description: "motion called completed notify closure")
        let tester = Tester()

        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.998)
        .completed { (motion) in
            XCTAssertTrue(motion.velocity < 1.0)
            XCTAssertEqual(motion.totalProgress, 1.0)
            XCTAssertEqual(tester.value, motion.properties[0].current, accuracy: 0.9)
            
            did_complete.fulfill()
        }
        motion.velocityDecayLimit = 1.0
        
        motion.start()
        waitForExpectations(timeout: 4.0, handler: nil)
        
    }
    
    func test_delay() {
        let tester = Tester()
        let did_start = expectation(description: "motion called started notify closure")
        let timestamp = CFAbsoluteTimeGetCurrent()
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 1.5, friction: 0.999)
        .started({ (motion) in
            let new_timestamp = CFAbsoluteTimeGetCurrent()
            XCTAssertEqual(new_timestamp, timestamp + motion.delay, accuracy: 0.9)
            
            did_start.fulfill()
        })
        motion.delay = 0.2
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }

    
    func test_moving_nested_struct() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.rect.origin.x)], velocity: 2.0, friction: 0.998)
        .completed { (motion) in
            XCTAssertTrue(motion.velocity < 1.0)
            XCTAssertEqual(Double(tester.rect.origin.x), motion.properties[0].current, accuracy: 0.9)
            
            did_complete.fulfill()
        }
        motion.velocityDecayLimit = 1.0

        motion.start()
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    
    func test_additive_mode_weighting() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 10.0, friction: 0.96, options: [.additive])
        motion.additiveWeighting = 0.5
        
        let motion2 = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: -10.0, friction: 0.96, options: [.additive])
        .completed { (m) in
            // velocity should basically be 0 as the two velocities cancel each other out
            XCTAssertEqual(tester.value, 0.0, accuracy: 0.05)
            
            did_complete.fulfill()
        }
        motion2.additiveWeighting = 0.5
        
        motion.start()
        motion2.start()
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    func test_repeating_should_repeat() {
        let tester = Tester()
        
        let did_repeat = expectation(description: "motion called cycleRepeated notify closure")
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98, options: [.repeats])
            .cycleRepeated({ (motion) in
                XCTAssertEqual(motion.totalProgress, 0.5)
                XCTAssertEqual(motion.cycleProgress, 0.0)
                
                did_repeat.fulfill()
            })
            .completed { (motion) in
                let new_cycles = motion.repeatCycles + 1
                XCTAssertEqual(motion.cyclesCompletedCount, new_cycles)
                XCTAssertEqual(motion.cycleProgress, 1.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, .stopped)
                
                did_complete.fulfill()
        }
        motion.repeatCycles = 1
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_reversing_should_reverse() {
        let tester = Tester()
        
        let did_reverse = expectation(description: "motion called reversed notify closure")
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98, options: [.reverses])
            .reversed({ (motion) in
                XCTAssertTrue(motion.totalProgress <= 0.5)
                XCTAssertTrue(motion.cycleProgress <= 0.5)
                XCTAssertEqual(motion.motionDirection, MotionDirection.reverse)
                
                did_reverse.fulfill()
            })
            .completed { (motion) in
                XCTAssertEqual(motion.cyclesCompletedCount, 1)
                XCTAssertEqual(motion.cycleProgress, 1.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, .stopped)
                
                did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    func test_reversing_and_repeating_should_reverse_and_repeat() {
        let tester = Tester()
        
        let did_repeat = expectation(description: "motion called cycleRepeated notify closure")
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98, options: [.reverses, .repeats])
            .reversed({ (motion) in
                if (motion.cyclesCompletedCount == 0) {
                    XCTAssertTrue(motion.totalProgress <= 0.25)
                    XCTAssertTrue(motion.cycleProgress <= 0.5)
                }
            })
            .cycleRepeated({ (motion) in
                XCTAssertEqual(motion.totalProgress, 0.5)
                XCTAssertEqual(motion.cycleProgress, 0.0)
                
                did_repeat.fulfill()
            })
            .completed { (motion) in
                XCTAssertEqual(motion.cyclesCompletedCount, 2)
                XCTAssertEqual(motion.cycleProgress, 1.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, .stopped)
                
                did_complete.fulfill()
        }
        motion.repeatCycles = 1
        
        motion.start()
        waitForExpectations(timeout: 3.0, handler: nil)
        
    }
    
    // MARK: Moveable methods
    
    func test_start() {
        
        let tester = Tester()
        
        let did_start = expectation(description: "motion called started notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98)
        .started { (motion) in
            XCTAssertEqual(motion.motionState, .moving)
            
            did_start.fulfill()
        }
        
        motion.start()
        motion.stop()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_start_while_paused() {
        
        let tester = Tester()
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98)
        motion.start()
        motion.pause()
        motion.start()
        
        // should not start again
        XCTAssertEqual(motion.motionState, .paused)
        
    }
    
    func test_stop() {
        
        let tester = Tester()
        
        let did_stop = expectation(description: "motion called stopped notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98)
        .stopped { (motion) in
            XCTAssertEqual(motion.motionState, .stopped)
            
            did_stop.fulfill()
        }
        
        motion.start()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            motion.stop()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_pause() {

        let tester = Tester()
        let did_pause = expectation(description: "motion called paused notify closure")
        let data = PropertyData(keyPath: \Tester.value, start: 0.0, end: 100.0)
        let motion = PhysicsMotion(target: tester, properties: [data], velocity: 2.0, friction: 0.98)
        .paused { (motion) in
            print("physics paused with state \(motion.motionState)")
            XCTAssertEqual(motion.motionState, .paused)

            did_pause.fulfill()
        }
        motion.start()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            motion.pause()
        })

        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
    func test_pause_while_stopped() {
        
        let tester = Tester()
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98)
        motion.start()
        motion.stop()
        motion.pause()
        
        // should not pause while stopped
        XCTAssertEqual(motion.motionState, .stopped)
    }
    
    func test_resume() {
        
        let tester = Tester()
        
        let did_resume = expectation(description: "motion called resumed notify closure")
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98)
            .resumed { (motion) in
                XCTAssertEqual(motion.motionState, .moving)
                
                did_resume.fulfill()
            }
            .completed { (motion) in
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, .stopped)
                
                did_complete.fulfill()
        }
        motion.start()
        motion.pause()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            motion.resume()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_resume_while_stopped() {
        
        let tester = Tester()
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98)
        motion.start()
        motion.stop()
        motion.resume()
        
        // should not start again
        XCTAssertEqual(motion.motionState, .stopped)
    }
    
    func test_update() {
        
        let tester = Tester()
        
        let did_update = expectation(description: "motion called updated notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value)], velocity: 2.0, friction: 0.98)
            .updated { (motion) in
                XCTAssertEqual(motion.motionState, .moving)
                
                did_update.fulfill()
                motion.stop()
        }
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_reset() {
        
        let tester = Tester()
        
        let did_reset = expectation(description: "motion called updated notify closure")
        
        let motion = PhysicsMotion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], velocity: 2.0, friction: 0.98)
        
        motion.start()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            motion.reset()
            
            XCTAssertEqual(motion.properties[0].current, motion.properties[0].start)
            XCTAssertEqual(motion.totalProgress, 0.0)
            XCTAssertEqual(motion.cycleProgress, 0.0)
            XCTAssertEqual(motion.cyclesCompletedCount, 0)
            
            did_reset.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
}
