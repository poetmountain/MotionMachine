//
//  MotionTests.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit

@MainActor class MotionTests: XCTestCase {

    // MARK: Setup tests
    
    func test_no_start_params_sets_motion_starts_at_current_object_value() {
        let tester = Tester()
        tester.value = 50.0
        // when a Motion is not passed start values during init, it should assign the object's current object values
        // for the specified props to each PropertyData start value
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 100.0)], duration: 0.2)

        XCTAssertEqual(motion.properties[0].start, tester.value)
        
    }
    
    func test_add() {
        let tester = Tester()
        let motion = Motion<Tester>(target: tester, duration: 1.0)
        
        // add should add a PropertyData to the properties array
        motion.add(PropertyData(keyPath: \Tester.value, end: 50.0))
        XCTAssertEqual(motion.properties.count, 1)

    }
    
    func test_afterDelay() {
        let tester = Tester()
        
        // afterDelay should add a delay
        let motion = Motion<Tester>(target: tester, duration: 1.0).afterDelay(1.0)
        XCTAssertEqual(motion.delay, 1.0)
    }
    
    func test_repeats() {
        let tester = Tester()
        
        // repeats should set repeating and amount
        let motion = Motion<Tester>(target: tester, duration: 1.0).repeats(1)
        XCTAssertTrue(motion.isRepeating)
        XCTAssertEqual(motion.repeatCycles, 1)
        
        // if no value provided, repeating should be infinite
        let motion2 = Motion<Tester>(target: tester, duration: 1.0).repeats()
        XCTAssertTrue(motion2.isRepeating)
        XCTAssertEqual(motion2.repeatCycles, Motion<Tester>.REPEAT_INFINITE)
        
    }
    
    func test_reverses() {
        let tester = Tester()
        
        // reverses should set reversing and reverseEasing properties
        let easing: EasingUpdateClosure = EasingQuadratic.easeIn()
        let motion = Motion<Tester>(target: tester, duration: 1.0).reverses(withEasing: easing)
        XCTAssertTrue(motion.isReversing)
        XCTAssertTrue(motion.reverseEasing != nil)
        
    }
    
    
    // MARK: Motion tests
    
    func test_object_prop_should_end_at_specified_value() {
        let tester = Tester()

        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 100.0)], duration: 0.2)
        .completed { (motion) in
            
            let final_value = tester.value
            XCTAssertEqual(final_value, 100.0)
            XCTAssertEqual(motion.totalProgress, 1.0)

            did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
        
        // test UIColor assignment
        let did_complete2 = expectation(description: "color motion called completed notify closure")
        
        let motion2 = Motion(target: tester, properties: [PropertyData<Tester>(stringPath: "blue", parentPath: \Tester.color, end: 0.5)], duration: 0.2)
            .completed { (motion) in
                var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
                tester.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
                XCTAssertEqual(blue, 0.5)
                XCTAssertEqual(motion.totalProgress, 1.0)
                
                did_complete2.fulfill()
        }
        
        motion2.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_delay() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        let timestamp = CFAbsoluteTimeGetCurrent()
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 100.0)], duration: 0.2)
            .completed { (motion) in
                
                let final_value = tester.value
                XCTAssertEqual(final_value, 100.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                let new_timestamp = CFAbsoluteTimeGetCurrent()
                XCTAssertEqual(new_timestamp, timestamp + motion.duration, accuracy: 0.9)
                
                did_complete.fulfill()
        }
        motion.delay = 0.2
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }

    func test_object_prop_should_end_at_final_state() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = Motion(target: tester, states: MotionState(keyPath: \Tester.value, end: 10.0), duration: 0.2)
            .completed { (motion) in
                let final_value = tester.value
                XCTAssertEqual(motion.properties[0].current, 10.0)
                XCTAssertEqual(final_value, 10.0)

                did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_object_prop_should_follow_property_states() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = Motion(target: tester, states: MotionState(keyPath: \Tester.value, start: 10.0, end: 50.0), duration: 0.2)
            .started({ (motion) in
                XCTAssertEqual(motion.properties[0].current, 10.0)
            })
            .completed { (motion) in
                let final_value = tester.value
                XCTAssertEqual(motion.properties[0].current, 50.0)
                XCTAssertEqual(final_value, 50.0)
                
                did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_moving_nested_struct() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.rect.origin.x, end: 10.0)], duration: 0.2)
        .completed { (motion) in
            let final_value = tester.rect.origin.x
            XCTAssertEqual(motion.properties[0].current, 10.0)
            XCTAssertEqual(final_value, 10.0)

            did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
    func test_nested_struct_should_end_at_final_state() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = Motion(target: tester, states: MotionState(keyPath: \Tester.rect, end: CGRect(x: 10.0, y: 0.0, width: 0.0, height: 0.0)), duration: 0.2)
            .updated({ (motion) in
                print(tester.rect)
            })
            .completed { (motion) in
                let final_value = tester.rect.origin.x
                XCTAssertEqual(motion.properties[0].current, 10.0)
                XCTAssertEqual(final_value, 10.0)
                
                did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }

    func test_additive_mode_ends_on_second_motion() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.4, options: [.additive])
        
        let motion2 = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: -10.0)], duration: 0.4, options: [.additive])
        motion2.updated { motion in
            print("motion2 progress \(motion.properties[0].current) :: tester \(tester.value)")
        }
        motion2.completed { (motion) in
            XCTAssertEqual(tester.value, motion2.properties[0].end, accuracy: 0.00001, "Expected motion end to be \(motion2.properties[0].end), but got \(tester.value).")
            did_complete.fulfill()
        }
        motion2.delay = 0.2
        
        motion.start()
        motion2.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    
    func test_additive_mode_weighting() {
        let tester = Tester()
        
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.4, options: [.additive])
        
        let motion2 = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: -10.0)], duration: 0.4, options: [.additive])
        .completed { (motion) in
            // tester value should be halfway between the motions' ending values because second motion starts with 50% weighting
            XCTAssertEqual(tester.value, 0.0, accuracy: 0.0000001)
            
            did_complete.fulfill()
        }
        motion2.additiveWeighting = 0.5
        
        motion.start()
        motion2.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    
    func test_repeating_should_repeat() {
        let tester = Tester()
        
        let did_repeat = expectation(description: "motion called cycleRepeated notify closure")
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 100.0)], duration: 0.2, options:[.repeats])
            .cycleRepeated({ (motion) in
                XCTAssertEqual(motion.totalProgress, 0.5)
                XCTAssertEqual(motion.cycleProgress, 0.0)
                
                did_repeat.fulfill()
            })
            .completed { (motion) in
                XCTAssertEqual(tester.value, 100.0)
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
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 100.0)], duration: 0.4, options:[.reverses])
            .reversed({ (motion) in
                XCTAssertTrue(motion.totalProgress <= 0.5)
                XCTAssertTrue(motion.cycleProgress <= 0.5)
                XCTAssertEqual(motion.motionDirection, MotionDirection.reverse)

                did_reverse.fulfill()
            })
            .completed { (motion) in
                XCTAssertEqual(tester.value, 0.0)
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
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 100.0)], duration: 0.4, options:[.reverses, .repeats])
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
                XCTAssertEqual(tester.value, 0.0)
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
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.2)
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
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.2)
        motion.start()
        motion.pause()
        motion.start()
        
        // should not start again
        XCTAssertEqual(motion.motionState, .paused)
        
    }
    
    func test_stop() {
        
        let tester = Tester()
        
        let did_stop = expectation(description: "motion called stopped notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.2)
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

        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.2)
        .paused { (motion) in
            XCTAssertEqual(motion.motionState, .paused)
            
            did_pause.fulfill()
        }
        motion.start()
        motion.pause()

        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
    func test_pause_while_stopped() {
        
        let tester = Tester()
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.2)
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

        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.4)
        .resumed { (motion) in
            XCTAssertEqual(motion.motionState, .moving)
            
            did_resume.fulfill()
        }
        .completed { (motion) in
            XCTAssertEqual(tester.value, 10.0)
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
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.2)
        motion.start()
        motion.stop()
        motion.resume()
        
        // should not start again
        XCTAssertEqual(motion.motionState, .stopped)
        
    }
    
    func test_update() {
        
        let tester = Tester()
        
        let did_update = expectation(description: "motion called updated notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.2)
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
        
        let motion = Motion(target: tester, properties: [PropertyData(keyPath: \Tester.value, end: 10.0)], duration: 0.2)
        
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
