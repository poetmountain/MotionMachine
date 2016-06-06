//
//  MotionTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/20/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest
import UIKit

class MotionTests: XCTestCase {

    // MARK: Setup tests
    
    func test_no_start_params_sets_motion_starts_at_current_object_value() {
        let tester = Tester()
        tester.value = 50.0
        // when a Motion is not passed start values during init, it should assign the object's current object values
        // for the specified props to each PropertyData start value
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.2)

        XCTAssertEqual(motion.properties[0].start, tester.value)
        
    }
    
    func test_add() {
        let tester = Tester()
        let motion = Motion(target: tester, duration: 1.0)
        
        // add should add a PropertyData to the properties array
        motion.add(PropertyData("value", 50.0))
        XCTAssertEqual(motion.properties.count, 1)

    }
    
    func test_afterDelay() {
        let tester = Tester()
        
        // afterDelay should add a delay
        let motion = Motion(target: tester, duration: 1.0).afterDelay(1.0)
        XCTAssertEqual(motion.delay, 1.0)
    }
    
    func test_repeats() {
        let tester = Tester()
        
        // repeats should set repeating and amount
        let motion = Motion(target: tester, duration: 1.0).repeats(1)
        XCTAssertTrue(motion.repeating)
        XCTAssertEqual(motion.repeatCycles, 1)
        
        // if no value provided, repeating should be infinite
        let motion2 = Motion(target: tester, duration: 1.0).repeats()
        XCTAssertTrue(motion2.repeating)
        XCTAssertEqual(motion2.repeatCycles, REPEAT_INFINITE)
        
    }
    
    func test_reverses() {
        let tester = Tester()
        
        // reverses should set reversing and reverseEasing properties
        let easing: EasingUpdateClosure = EasingQuadratic.easeIn()
        let motion = Motion(target: tester, duration: 1.0).reverses(withEasing: easing)
        XCTAssertTrue(motion.reversing)
        XCTAssertTrue(motion.reverseEasing != nil)
        
    }
    
    
    // MARK: Motion tests
    
    func test_top_level_prop_should_end_at_specified_value() {
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: 0, properties: [PropertyData(end: 100.0)], duration: 0.2)
        .completed { (motion) in
            XCTAssertTrue(true, "called completed closure")

            let final_value = motion.properties[0].current
            XCTAssertEqual(final_value, 100.0)
            
            did_complete.fulfill()
        }

        motion.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_object_prop_should_end_at_specified_value() {
        let tester = Tester()

        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.2)
        .completed { (motion) in
            
            let final_value = tester.value
            XCTAssertEqual(final_value, 100.0)
            XCTAssertEqual(motion.totalProgress, 1.0)

            did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
        
        // test UIColor assignment
        let did_complete2 = expectationWithDescription("color motion called completed notify closure")
        
        let motion2 = Motion(target: tester, properties: [PropertyData("color.blue", 0.5)], duration: 0.2)
            .completed { (motion) in
                var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
                tester.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
                XCTAssertEqual(blue, 0.5)
                XCTAssertEqual(motion.totalProgress, 1.0)
                
                did_complete2.fulfill()
        }
        
        motion2.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_delay() {
        let tester = Tester()
        
        let did_complete = expectationWithDescription("motion called completed notify closure")
        let timestamp = CFAbsoluteTimeGetCurrent()
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.2)
            .completed { (motion) in
                
                let final_value = tester.value
                XCTAssertEqual(final_value, 100.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                let new_timestamp = CFAbsoluteTimeGetCurrent()
                XCTAssertEqualWithAccuracy(new_timestamp, timestamp + motion.duration, accuracy: 0.9)
                
                did_complete.fulfill()
        }
        motion.delay = 0.2
        
        motion.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }

    func test_object_prop_should_end_at_final_state() {
        let tester = Tester()
        
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, finalState: ["value" : 10.0], duration: 0.2)
            .completed { (motion) in
                let final_value = tester.value
                XCTAssertEqual(motion.properties[0].current, 10.0)
                XCTAssertEqual(final_value, 10.0)

                did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_moving_nested_struct() {
        let tester = Tester()
        
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("rect.origin.x", 10.0)], duration: 0.2)
        .completed { (motion) in
            let final_value = tester.rect.origin.x
            XCTAssertEqual(motion.properties[0].current, 10.0)
            XCTAssertEqual(final_value, 10.0)

            did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)

    }
    
    func test_nested_struct_should_end_at_final_state() {
        let tester = Tester()
        
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, finalState: ["rect" : CGRectMake(10.0, 0.0, 0.0, 0.0)], duration: 0.2)
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
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }

    func test_additive_mode_ends_on_second_motion() {
        let tester = Tester()
        
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.4)
        motion.additive = true
        
        let motion2 = Motion(target: tester, properties: [PropertyData("value", -10.0)], duration: 0.4)
        .completed { (motion) in
            XCTAssertEqualWithAccuracy(tester.value, motion.properties[0].end, accuracy: 0.0000001)
            did_complete.fulfill()
        }
        motion2.additive = true
        motion2.delay = 0.2
        
        motion.start()
        motion2.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_additive_mode_weighting() {
        let tester = Tester()
        
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.4)
        motion.additive = true
        motion.additiveWeighting = 0.5
        
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 0.0)], duration: 0.4)
        .completed { (motion) in
            // tester value should be halfway between the motions' ending values because second starts at 50% of duration of first
            XCTAssertEqualWithAccuracy(tester.value, 5.0, accuracy: 0.0000001)
            
            did_complete.fulfill()
        }
        motion2.additive = true
        motion2.additiveWeighting = 0.5
        motion2.delay = 0.2
        
        motion.start()
        motion2.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    
    func test_repeating_should_repeat() {
        let tester = Tester()
        
        let did_repeat = expectationWithDescription("motion called cycleRepeated notify closure")
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.2, options:[.Repeat])
            .cycleRepeated({ (motion) in
                XCTAssertEqual(motion.totalProgress, 0.5)
                XCTAssertEqual(motion.cycleProgress, 0.0)
                
                did_repeat.fulfill()
            })
            .completed { (motion) in
                XCTAssertEqual(tester.value, 100.0)
                XCTAssertEqual(motion.cyclesCompletedCount, motion.repeatCycles+1)
                XCTAssertEqual(motion.cycleProgress, 1.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, MotionState.Stopped)
                
                did_complete.fulfill()
        }
        motion.repeatCycles = 1
        
        motion.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    
    func test_reversing_should_reverse() {
        let tester = Tester()
        
        let did_reverse = expectationWithDescription("motion called reversed notify closure")
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.4, options:[.Reverse])
            .reversed({ (motion) in
                XCTAssertTrue(motion.totalProgress <= 0.5)
                XCTAssertTrue(motion.cycleProgress <= 0.5)
                XCTAssertEqual(motion.motionDirection, MotionDirection.Reverse)

                did_reverse.fulfill()
            })
            .completed { (motion) in
                XCTAssertEqual(tester.value, 0.0)
                XCTAssertEqual(motion.cyclesCompletedCount, 1)
                XCTAssertEqual(motion.cycleProgress, 1.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, MotionState.Stopped)
                
                did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectationsWithTimeout(2.0, handler: nil)
        
    }
    
    
    func test_reversing_and_repeating_should_reverse_and_repeat() {
        let tester = Tester()
        
        let did_repeat = expectationWithDescription("motion called cycleRepeated notify closure")
        let did_complete = expectationWithDescription("motion called completed notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.4, options:[.Reverse, .Repeat])
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
                XCTAssertEqual(motion.motionState, MotionState.Stopped)
                
                did_complete.fulfill()
        }
        motion.repeatCycles = 1
        
        motion.start()
        waitForExpectationsWithTimeout(3.0, handler: nil)
        
    }
    
    
    // MARK: Moveable methods
    
    func test_start() {
        
        let tester = Tester()
        
        let did_start = expectationWithDescription("motion called started notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
            .started { (motion) in
                XCTAssertEqual(motion.motionState, MotionState.Moving)
                
                did_start.fulfill()
        }
        
        motion.start()
        motion.stop()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_start_while_paused() {
        
        let tester = Tester()
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        motion.start()
        motion.pause()
        motion.start()
        
        // should not start again
        XCTAssertEqual(motion.motionState, MotionState.Paused)
        
    }
    
    func test_stop() {
        
        let tester = Tester()
        
        let did_stop = expectationWithDescription("motion called stopped notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
            .stopped { (motion) in
                XCTAssertEqual(motion.motionState, MotionState.Stopped)
                
                did_stop.fulfill()
        }
        
        motion.start()
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.02 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            motion.stop()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_pause() {
        
        let tester = Tester()
        let did_pause = expectationWithDescription("motion called paused notify closure")

        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        .paused { (motion) in
            XCTAssertEqual(motion.motionState, MotionState.Paused)
            
            did_pause.fulfill()
        }
        motion.start()
        motion.pause()

        waitForExpectationsWithTimeout(1.0, handler: nil)

    }
    
    func test_pause_while_stopped() {
        
        let tester = Tester()
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        motion.start()
        motion.stop()
        motion.pause()
        
        // should not pause while stopped
        XCTAssertEqual(motion.motionState, MotionState.Stopped)
        
    }
    
    func test_resume() {
        
        let tester = Tester()
        
        let did_resume = expectationWithDescription("motion called resumed notify closure")
        let did_complete = expectationWithDescription("motion called completed notify closure")

        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.4)
        .resumed { (motion) in
            XCTAssertEqual(motion.motionState, MotionState.Moving)
            
            did_resume.fulfill()
        }
        .completed { (motion) in
            XCTAssertEqual(tester.value, 10.0)
            XCTAssertEqual(motion.totalProgress, 1.0)
            XCTAssertEqual(motion.motionState, MotionState.Stopped)
            
            did_complete.fulfill()
        }
        motion.start()
        motion.pause()
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.02 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            motion.resume()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_resume_while_stopped() {
        
        let tester = Tester()
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        motion.start()
        motion.stop()
        motion.resume()
        
        // should not start again
        XCTAssertEqual(motion.motionState, MotionState.Stopped)
        
    }
    
    func test_update() {
        
        let tester = Tester()
        
        let did_update = expectationWithDescription("motion called updated notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
            .updated { (motion) in
                XCTAssertEqual(motion.motionState, MotionState.Moving)
                
                did_update.fulfill()
                motion.stop()
        }
        
        motion.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_reset() {
        
        let tester = Tester()
        
        let did_reset = expectationWithDescription("motion called updated notify closure")
        
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        
        motion.start()
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.02 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            motion.reset()
            
            XCTAssertEqual(motion.properties[0].current, motion.properties[0].start)
            XCTAssertEqual(motion.totalProgress, 0.0)
            XCTAssertEqual(motion.cycleProgress, 0.0)
            XCTAssertEqual(motion.cyclesCompletedCount, 0)

            
            did_reset.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
}
