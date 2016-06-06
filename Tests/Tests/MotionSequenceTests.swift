//
//  MotionSequenceTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/22/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

class MotionSequenceTests: XCTestCase {

    // MARK: Setup tests
    
    func test_add() {
        let tester = Tester()
        let sequence = MotionSequence()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        let motion3 = Motion(target: tester, duration: 1.0)
        
        // add should add a Moveable object to the group list
        sequence.add(motion)
        XCTAssertEqual(sequence.steps.count, 1)
        
        // add array should add all Moveable objects to the group list
        sequence.add([motion2, motion3])
        XCTAssertEqual(sequence.steps.count, 3)
    }
    
    func test_afterDelay() {
        let tester = Tester()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        
        // afterDelay should add a delay
        let sequence = MotionSequence(steps: [motion, motion2]).afterDelay(1.0)
        XCTAssertEqual(sequence.delay, 1.0)
    }
    
    func test_repeats() {
        let tester = Tester()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        
        // repeats should set repeating and amount
        let sequence = MotionSequence(steps: [motion, motion2]).repeats(1)
        XCTAssertTrue(sequence.repeating)
        XCTAssertEqual(sequence.repeatCycles, 1)
        
        // if no value provided, repeating should be infinite
        let sequence2 = MotionSequence(steps: [motion, motion2]).repeats()
        XCTAssertTrue(sequence2.repeating)
        XCTAssertEqual(sequence2.repeatCycles, REPEAT_INFINITE)
    }
    
    func test_reverses() {
        let tester = Tester()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        
        // reverses should set reversing and reversingMode
        let sequence = MotionSequence(steps: [motion, motion2]).reverses(.Contiguous)
        XCTAssertTrue(sequence.reversing)
        XCTAssertTrue(sequence.reversingMode == .Contiguous)
        
        // if no value provided, reversingMode should be .Sequential
        let sequence2 = MotionSequence(steps: [motion, motion2]).reverses()
        XCTAssertTrue(sequence2.reversing)
        XCTAssertTrue(sequence2.reversingMode == .Sequential)
    }
    
    
    func test_use_child_tempo() {
        let tester = Tester()
        let sequence = MotionSequence()
        let motion = Motion(target: tester, duration: 1.0)
        
        // specifying a group's child motion should use its own tempo should not override it with group tempo
        sequence.add(motion, useChildTempo: true)
        XCTAssertNotNil(motion.tempo, "child tempo should not be removed")
        
    }
    
    func test_remove() {
        let tester = Tester()
        let sequence = MotionSequence()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        
        sequence.add(motion)
        
        // remove should remove a Moveable object to the sequence steps
        sequence.remove(motion)
        XCTAssertEqual(sequence.steps.count, 0)
        
        // remove should fail gracefully when object not in sequence steps
        sequence.remove(motion2)
        XCTAssertEqual(sequence.steps.count, 0)
        
    }

    
    // MARK: Motion tests

    func test_should_end_motions_at_proper_ending_values() {
        let did_start = expectationWithDescription("sequence called started notify closure")
        let did_complete = expectationWithDescription("sequence called completed notify closure")

        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, finalState: ["color" : UIColor.blueColor()], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        
        let sequence = MotionSequence(steps: [group, motion3, motion4])
        .started { (sequence) in
            let motion = sequence.steps.first as! MotionGroup
            XCTAssertTrue(sequence.currentStep() === motion, "should start with first motion")
            
            did_start.fulfill()
        }
        .completed { (sequence) in
            let motion = sequence.steps.last as! Motion
            XCTAssertTrue(sequence.currentStep() === motion, "should end with last motion")
            XCTAssertEqual(motion.properties[0].current, motion.properties[0].end)
            XCTAssertEqual(motion.totalProgress, 1.0)
            print("sequence completed")
            
            did_complete.fulfill()
        }
        
        sequence.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)

    }
    
    func test_delay() {
        let did_complete = expectationWithDescription("sequence called completed notify closure")
        let timestamp = CFAbsoluteTimeGetCurrent()
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2, motion3])
        .completed { (sequence) in
            
            let final_value = tester.value
            XCTAssertEqual(final_value, 60.0)
            XCTAssertEqual(sequence.totalProgress, 1.0)
            let new_timestamp = CFAbsoluteTimeGetCurrent()
            let motion = sequence.steps.first as! Motion
            XCTAssertEqualWithAccuracy(new_timestamp, timestamp + motion.duration, accuracy: 0.9)
            
            did_complete.fulfill()
        }
        sequence.delay = 0.2
        
        
        sequence.start()
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
 
    func test_repeating() {
        let did_repeat = expectationWithDescription("sequence called started notify closure")
        let did_complete = expectationWithDescription("sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, finalState: ["color" : UIColor.blueColor()], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        
        let sequence = MotionSequence(steps: [group, motion3, motion4], options: [.Repeat])
        .cycleRepeated { (sequence) in
            let motion = sequence.steps.first as! MotionGroup
            XCTAssertTrue(sequence.currentStep() === motion)
            XCTAssertEqual(sequence.totalProgress, 0.5)
            XCTAssertEqual(sequence.cycleProgress, 0.0)
            XCTAssertEqual(sequence.cyclesCompletedCount, 1)
            
            did_repeat.fulfill()
        }
        .completed { (sequence) in
            let motion = sequence.steps.last as! Motion
            XCTAssertTrue(sequence.currentStep() === motion, "should end with last motion")
            XCTAssertEqual(motion.properties[0].current, motion.properties[0].end)
            XCTAssertEqual(motion.totalProgress, 1.0)
            XCTAssertEqual(sequence.cyclesCompletedCount, sequence.repeatCycles+1)
            XCTAssertEqual(sequence.cycleProgress, 1.0)
            XCTAssertEqual(sequence.totalProgress, 1.0)
            XCTAssertEqual(sequence.motionState, MotionState.Stopped)
            
            did_complete.fulfill()
        }
        sequence.repeatCycles = 1
        
        sequence.start()
        waitForExpectationsWithTimeout(2.0, handler: nil)

    }
    
    func test_reversing_contiguous() {
        let did_reverse = expectationWithDescription("sequence called reversed notify closure")
        let did_complete = expectationWithDescription("sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, finalState: ["color" : UIColor.blueColor()], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        
        let sequence = MotionSequence(steps: [group, motion3, motion4], options: [.Reverse])
        .reversed({ (sequence) in
            let motion = sequence.steps.last as! Motion

            XCTAssertTrue(sequence.totalProgress <= 0.5)
            XCTAssertTrue(sequence.cycleProgress <= 0.5)
            XCTAssertEqual(sequence.motionDirection, MotionDirection.Reverse)
            XCTAssertTrue(sequence.currentStep() === motion, "step after reversing should be same step")
            XCTAssertEqual(motion.motionDirection, MotionDirection.Reverse, "sequence when reversing should move in reverse")

            did_reverse.fulfill()
        })
        .completed { (sequence) in
            let group = sequence.steps.first as! MotionGroup
            let motion = group.motions.first as! Motion
            let last = sequence.steps.last as! Motion
            XCTAssertTrue(sequence.currentStep() === group, "should end with first motion")
            
            // contiguous mode will reverse steps, so they should end back at start value
            XCTAssertEqual(tester.value, 0.0)
            XCTAssertEqual(motion.properties[0].current, motion.properties[0].start)
            XCTAssertEqual(last.properties[0].current, last.properties[0].start)
            
            XCTAssertEqual(motion.totalProgress, 1.0)
            XCTAssertEqual(sequence.cyclesCompletedCount, 1)
            XCTAssertEqual(sequence.cycleProgress, 1.0)
            XCTAssertEqual(sequence.totalProgress, 1.0)
            XCTAssertEqual(sequence.motionState, MotionState.Stopped)

            did_complete.fulfill()
        }
        
        sequence.reversingMode = .Contiguous
        
        // should turn reversing property on sequence steps
        XCTAssertTrue(group.reversing)
        XCTAssertTrue(motion3.reversing)
        
        sequence.start()

        // should pause first motion while moving the second
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            XCTAssertEqual(group.motionState, MotionState.Paused)
            XCTAssertEqual(motion3.motionState, MotionState.Moving)
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)

    }
    
    
    func test_reversing_nested_sequence_contiguous() {
        let did_reverse = expectationWithDescription("sequence called reversed notify closure")
        let did_complete = expectationWithDescription("sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, finalState: ["color" : UIColor.blueColor()], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        let motion5 = Motion(target: tester, properties: [PropertyData("value", 80.0)], duration: 0.2)
        let sub_sequence = MotionSequence(steps: [motion3, motion4])
        
        let sequence = MotionSequence(steps: [group, sub_sequence, motion5], options: [.Reverse])
            .reversed({ (sequence) in
                let motion = sequence.steps.last as! Motion
                let subsequence = sequence.steps[1] as! MotionSequence
                
                XCTAssertTrue(sequence.totalProgress <= 0.5)
                XCTAssertTrue(sequence.cycleProgress <= 0.5)
                XCTAssertEqual(sequence.motionDirection, MotionDirection.Reverse)
                XCTAssertEqual(subsequence.motionDirection, MotionDirection.Reverse, "sub sequence when reversing should move in reverse")
                XCTAssertTrue(sequence.currentStep() === motion, "step after reversing should be same step")
                XCTAssertEqual(motion.motionDirection, MotionDirection.Reverse, "sequence when reversing should move in reverse")
                
                did_reverse.fulfill()
            })
            .completed { (sequence) in
                let group = sequence.steps.first as! MotionGroup
                let motion = group.motions.first as! Motion
                let last = sequence.steps.last as! Motion
                let subsequence = sequence.steps[1] as! MotionSequence
                let sequence_motion = subsequence.steps[0] as! Motion
                XCTAssertTrue(sequence.currentStep() === group, "should end with first motion")
                
                // contiguous mode will reverse steps, so they should end back at start value
                XCTAssertEqual(tester.value, 0.0)
                XCTAssertEqual(motion.properties[0].current, motion.properties[0].start)
                XCTAssertEqual(last.properties[0].current, last.properties[0].start)
                XCTAssertEqual(sequence_motion.properties[0].current, sequence_motion.properties[0].start)

                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(sequence.cyclesCompletedCount, 1)
                XCTAssertEqual(sequence.cycleProgress, 1.0)
                XCTAssertEqual(sequence.totalProgress, 1.0)
                XCTAssertEqual(sequence.motionState, MotionState.Stopped)
                
                did_complete.fulfill()
        }
        
        sequence.reversingMode = .Contiguous
        
        // should turn reversing property on sequence steps
        XCTAssertTrue(group.reversing)
        XCTAssertTrue(sub_sequence.reversing)
        XCTAssertTrue(motion5.reversing)
        
        sequence.start()
        
        // should pause first motion while moving the second
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            XCTAssertEqual(group.motionState, MotionState.Paused)
            XCTAssertEqual(sub_sequence.motionState, MotionState.Paused)
            XCTAssertEqual(motion5.motionState, MotionState.Moving)
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
        
    }
    
    
    func test_reversing_nested_sequence_in_last_position_contiguous() {
        let did_reverse = expectationWithDescription("sequence called reversed notify closure")
        let did_complete = expectationWithDescription("sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, finalState: ["color" : UIColor.blueColor()], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        let sub_sequence = MotionSequence(steps: [motion3, motion4])
        
        let sequence = MotionSequence(steps: [group, sub_sequence], options: [.Reverse])
            .reversed({ (sequence) in
                let motion = sequence.steps.first as! MotionGroup
                let subsequence = sequence.steps.last as! MotionSequence
                
                XCTAssertTrue(sequence.totalProgress <= 0.5)
                XCTAssertTrue(sequence.cycleProgress <= 0.5)
                XCTAssertEqual(sequence.motionDirection, MotionDirection.Reverse)
                XCTAssertEqual(subsequence.motionDirection, MotionDirection.Reverse, "sub sequence when reversing should move in reverse")
                XCTAssertTrue(sequence.currentStep() === subsequence, "step after reversing should be same step")
                XCTAssertEqual(motion.motionDirection, MotionDirection.Reverse, "sequence when reversing should move in reverse")
                
                did_reverse.fulfill()
            })
            .completed { (sequence) in
                let group = sequence.steps.first as! MotionGroup
                let motion = group.motions.first as! Motion
                let subsequence = sequence.steps[1] as! MotionSequence
                let sequence_motion = subsequence.steps[0] as! Motion
                XCTAssertTrue(sequence.currentStep() === group, "should end with first motion")
                
                // contiguous mode will reverse steps, so they should end back at start value
                XCTAssertEqual(tester.value, 0.0)
                XCTAssertEqual(motion.properties[0].current, motion.properties[0].start)
                XCTAssertEqual(sequence_motion.properties[0].current, sequence_motion.properties[0].start)
                
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(sequence.cyclesCompletedCount, 1)
                XCTAssertEqual(sequence.cycleProgress, 1.0)
                XCTAssertEqual(sequence.totalProgress, 1.0)
                XCTAssertEqual(sequence.motionState, MotionState.Stopped)
                
                did_complete.fulfill()
        }
        
        sequence.reversingMode = .Contiguous
        
        // should turn reversing property on sequence steps
        XCTAssertTrue(group.reversing)
        XCTAssertTrue(sub_sequence.reversing)
        
        sequence.start()
        
        // should pause first motion while moving the second
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            XCTAssertEqual(group.motionState, MotionState.Paused)
            XCTAssertEqual(sub_sequence.motionState, MotionState.Moving)
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
        
    }
    
    
    
    func test_reversing_nested_sequence_noncontiguous() {
        let did_reverse = expectationWithDescription("sequence called reversed notify closure")
        let did_complete = expectationWithDescription("sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, finalState: ["color" : UIColor.blueColor()], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        let sub_sequence = MotionSequence(steps: [motion3, motion4])
        let motion5 = Motion(target: tester, properties: [PropertyData("value", 80.0)], duration: 0.2)

        let sequence = MotionSequence(steps: [group, sub_sequence, motion5], options: [.Reverse])
            .reversed({ (sequence) in
                let motion = sequence.steps.last as! Motion
                let subsequence = sequence.steps[1] as! MotionSequence

                XCTAssertTrue(sequence.totalProgress <= 0.5)
                XCTAssertTrue(sequence.cycleProgress <= 0.5)
                XCTAssertEqual(sequence.motionDirection, MotionDirection.Reverse)
                XCTAssertEqual(subsequence.motionDirection, MotionDirection.Forward, "sub sequence when reversing should move in reverse")
                XCTAssertTrue(sequence.currentStep() === sequence.steps.last, "step after reversing should be same step")
                XCTAssertEqual(motion.motionDirection, MotionDirection.Forward, "sequence when reversing should move forwards")

                did_reverse.fulfill()
            })
            .completed { (sequence) in
                let group = sequence.steps.first as! MotionGroup
                let motion = group.motions.first as! Motion
                let subsequence = sequence.steps[1] as! MotionSequence
                let sequence_motion = subsequence.steps[0] as! Motion
                let last = sequence.steps.last as! Motion
                
                XCTAssertTrue(sequence.currentStep() === group, "should end with first motion")
                
                // noncontiguous mode will not reverse steps, so they should end at normal end value
                XCTAssertEqual(tester.value, 20.0)
                XCTAssertEqual(motion.properties[0].current, motion.properties[0].end)
                XCTAssertEqual(last.properties[0].current, last.properties[0].end)
                XCTAssertEqual(sequence_motion.properties[0].current, sequence_motion.properties[0].end)

                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(sequence.cyclesCompletedCount, 1)
                XCTAssertEqual(sequence.cycleProgress, 1.0)
                XCTAssertEqual(sequence.totalProgress, 1.0)
                XCTAssertEqual(sequence.motionState, MotionState.Stopped)
                
                did_complete.fulfill()
        }
        
        // should not turn reversing property on sequence steps
        XCTAssertFalse(group.reversing)
        XCTAssertFalse(motion3.reversing)
        
        sequence.start()
        
        // should pause first motion while moving the second
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            XCTAssertEqual(group.motionState, MotionState.Stopped)
            XCTAssertEqual(motion3.motionState, MotionState.Moving)
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
        
    }
    
    
    func test_reversing_noncontiguous() {
        let did_reverse = expectationWithDescription("sequence called reversed notify closure")
        let did_complete = expectationWithDescription("sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, finalState: ["color" : UIColor.blueColor()], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        
        let sequence = MotionSequence(steps: [group, motion3, motion4], options: [.Reverse])
            .reversed({ (sequence) in
                let motion = sequence.steps.last as! Motion

                XCTAssertTrue(sequence.totalProgress <= 0.5)
                XCTAssertTrue(sequence.cycleProgress <= 0.5)
                XCTAssertEqual(sequence.motionDirection, MotionDirection.Reverse)
                XCTAssertTrue(sequence.currentStep() === sequence.steps.last, "step after reversing should be same step")
                XCTAssertEqual(motion.motionDirection, MotionDirection.Forward, "sequence when reversing should move forwards")
                
                did_reverse.fulfill()
            })
            .completed { (sequence) in
                let group = sequence.steps.first as! MotionGroup
                let motion = group.motions.first as! Motion
                let last = sequence.steps.last as! Motion
                
                XCTAssertTrue(sequence.currentStep() === group, "should end with first motion")
                
                // noncontiguous mode will not reverse steps, so they should end at normal end value
                XCTAssertEqual(tester.value, 20.0)
                XCTAssertEqual(motion.properties[0].current, motion.properties[0].end)
                XCTAssertEqual(last.properties[0].current, last.properties[0].end)
                
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(sequence.cyclesCompletedCount, 1)
                XCTAssertEqual(sequence.cycleProgress, 1.0)
                XCTAssertEqual(sequence.totalProgress, 1.0)
                XCTAssertEqual(sequence.motionState, MotionState.Stopped)
                
                did_complete.fulfill()
        }
        
        // should not turn reversing property on sequence steps
        XCTAssertFalse(group.reversing)
        XCTAssertFalse(motion3.reversing)
        
        sequence.start()
        
        // should pause first motion while moving the second
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            XCTAssertEqual(group.motionState, MotionState.Stopped)
            XCTAssertEqual(motion3.motionState, MotionState.Moving)
        }
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
        
    }
    
    
    
    
    // MARK: Moveable methods
    
    func test_start() {
        let did_start = expectationWithDescription("sequence called started notify closure")

        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .started { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.Moving)
            
            did_start.fulfill()
        }
        
        sequence.start()
        
        // should not start when paused
        sequence.pause()
        sequence.start()
        XCTAssertEqual(sequence.motionState, MotionState.Paused)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)

    }
    
    func test_stop() {
        let did_stop = expectationWithDescription("sequence called stopped notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .stopped { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.Stopped)
            
            did_stop.fulfill()
        }
        
        sequence.start()
        
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.02 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            sequence.stop()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func test_pause() {
        let did_pause = expectationWithDescription("sequence called paused notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .paused { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.Paused)
            
            did_pause.fulfill()
        }
        
        sequence.start()
        sequence.pause()
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_pause_while_stopped() {
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        
        sequence.start()
        sequence.stop()
        sequence.pause()
        
        // should not pause while stopped
        XCTAssertEqual(sequence.motionState, MotionState.Stopped)
    }
    
    
    func test_resume() {
        let did_resume = expectationWithDescription("sequence called resumed notify closure")
        let did_complete = expectationWithDescription("squence called completed notify closure")

        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .resumed { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.Moving)
            
            did_resume.fulfill()
        }
        .completed { (sequence) in
            XCTAssertEqual(tester.value, 40.0)
            XCTAssertEqual(sequence.totalProgress, 1.0)
            XCTAssertEqual(sequence.motionState, MotionState.Stopped)
            
            did_complete.fulfill()
        }
        sequence.start()
        sequence.pause()
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.02 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            sequence.resume()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func test_update() {
        
        let did_update = expectationWithDescription("sequence called updated notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .updated { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.Moving)
            
            did_update.fulfill()
            sequence.stop()
        }
        
        sequence.start()
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    func test_reset() {
        
        let did_reset = expectationWithDescription("motion called updated notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        
        sequence.start()
        let after_time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.02 * Double(NSEC_PER_SEC)));
        dispatch_after(after_time, dispatch_get_main_queue()) {
            sequence.reset()
            
            XCTAssertEqual(sequence.totalProgress, 0.0)
            XCTAssertEqual(sequence.cycleProgress, 0.0)
            
            did_reset.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }
    
    
}
