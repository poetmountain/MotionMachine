//
//  MotionSequenceTests.swift
//  MotionMachineTests
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@MainActor class MotionSequenceTests: XCTestCase {

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
        let sequence = MotionSequence(steps: [motion, motion2]).reverses(.contiguous)
        XCTAssertTrue(sequence.reversing)
        XCTAssertTrue(sequence.reversingMode == .contiguous)
        
        // if no value provided, reversingMode should be .Sequential
        let sequence2 = MotionSequence(steps: [motion, motion2]).reverses()
        XCTAssertTrue(sequence2.reversing)
        XCTAssertTrue(sequence2.reversingMode == .sequential)
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
        let did_start = expectation(description: "sequence called started notify closure")
        let did_complete = expectation(description: "sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, statesForProperties: [PropertyStates(path: "color", end: UIColor.blue)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        
        let sequence = MotionSequence(steps: [group, motion3, motion4])
        .started { (sequence) in
            if let motion = sequence.steps.first as? MotionGroup {
                XCTAssertTrue(sequence.currentStep() === motion, "should start with first motion")
                
                did_start.fulfill()
            } else {
                XCTFail("No Motion found in Sequence \(sequence.steps)")
            }
        }
        .completed { (sequence) in
            if let motion = sequence.steps.last as? Motion {
                XCTAssertTrue(sequence.currentStep() === motion, "should end with last motion")
                XCTAssertEqual(motion.properties[0].current, motion.properties[0].end)
                XCTAssertEqual(motion.totalProgress, 1.0)
                print("sequence completed")
                
                did_complete.fulfill()
            } else {
                XCTFail("No Motion found in Sequence \(sequence.steps)")
            }
        }
        
        sequence.start()
        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
    func test_delay() {
        let did_complete = expectation(description: "sequence called completed notify closure")
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
            if let motion = sequence.steps.first as? Motion {
                XCTAssertEqual(new_timestamp, timestamp + motion.duration, accuracy: 0.9)
                did_complete.fulfill()
            } else {
                XCTFail("No Motion found in Sequence \(sequence.steps)")
            }
        }
        sequence.delay = 0.2
        
        
        sequence.start()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
 
    func test_repeating() {
        let did_repeat = expectation(description: "sequence called started notify closure")
        let did_complete = expectation(description: "sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, statesForProperties: [PropertyStates(path: "color", end: UIColor.blue)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        
        let sequence = MotionSequence(steps: [group, motion3, motion4], options: [.repeats])
        .cycleRepeated { (sequence) in
            if let motion = sequence.steps.first as? MotionGroup {
                XCTAssertTrue(sequence.currentStep() === motion)
                XCTAssertEqual(sequence.totalProgress, 0.5)
                XCTAssertEqual(sequence.cycleProgress, 0.0)
                XCTAssertEqual(sequence.cyclesCompletedCount, 1)
                
                did_repeat.fulfill()
            } else {
                XCTFail("No Motion found in Sequence \(sequence.steps)")
            }
        }
        .completed { (sequence) in
            if let motion = sequence.steps.last as? Motion {
                XCTAssertTrue(sequence.currentStep() === motion, "should end with last motion")
                XCTAssertEqual(motion.properties[0].current, motion.properties[0].end)
                XCTAssertEqual(motion.totalProgress, 1.0)
                let new_cycles = sequence.repeatCycles + 1
                XCTAssertEqual(sequence.cyclesCompletedCount, new_cycles)
                XCTAssertEqual(sequence.cycleProgress, 1.0)
                XCTAssertEqual(sequence.totalProgress, 1.0)
                XCTAssertEqual(sequence.motionState, MotionState.stopped)
                
                did_complete.fulfill()
            } else {
                XCTFail("No Motion found in Sequence \(sequence.steps)")
            }
        }
        sequence.repeatCycles = 1
        
        sequence.start()
        waitForExpectations(timeout: 2.0, handler: nil)

    }
    
    func test_reversing_contiguous() {
        let did_reverse = expectation(description: "sequence called reversed notify closure")
        let did_complete = expectation(description: "sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, statesForProperties: [PropertyStates(path: "color", end: UIColor.blue)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        
        let sequence = MotionSequence(steps: [group, motion3, motion4], options: [.reverses])
        .reversed({ (sequence) in
            if let motion = sequence.steps.last as? Motion {
                XCTAssertTrue(sequence.totalProgress <= 0.5)
                XCTAssertTrue(sequence.cycleProgress <= 0.5)
                XCTAssertEqual(sequence.motionDirection, MotionDirection.reverse)
                XCTAssertTrue(sequence.currentStep() === motion, "step after reversing should be same step")
                XCTAssertEqual(motion.motionDirection, MotionDirection.reverse, "sequence when reversing should move in reverse")
                
                did_reverse.fulfill()
            } else {
                XCTFail("No Motion found in Sequence \(sequence.steps)")
            }
        })
        .completed { (sequence) in
            guard let group = sequence.steps.first as? MotionGroup, let motion = group.motions.first as? Motion, let last = sequence.steps.last as? Motion else {
                XCTFail("No Motion found in Sequence or Group")
                return
            }
            XCTAssertTrue(sequence.currentStep() === group, "should end with first motion")
            
            // contiguous mode will reverse steps, so they should end back at start value
            XCTAssertEqual(tester.value, 0.0)
            XCTAssertEqual(motion.properties[0].current, motion.properties[0].start)
            XCTAssertEqual(last.properties[0].current, last.properties[0].start)
            
            XCTAssertEqual(motion.totalProgress, 1.0)
            XCTAssertEqual(sequence.cyclesCompletedCount, 1)
            XCTAssertEqual(sequence.cycleProgress, 1.0)
            XCTAssertEqual(sequence.totalProgress, 1.0)
            XCTAssertEqual(sequence.motionState, MotionState.stopped)

            did_complete.fulfill()
        }
        
        sequence.reversingMode = .contiguous
        
        // should turn reversing property on sequence steps
        XCTAssertTrue(group.reversing)
        XCTAssertTrue(motion3.reversing)
        
        sequence.start()

        // should pause first motion while moving the second
        let after_time = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            XCTAssertEqual(group.motionState, MotionState.paused)
            XCTAssertEqual(motion3.motionState, MotionState.moving)
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)

    }
    
    
    func test_reversing_nested_sequence_contiguous() {
        let did_reverse = expectation(description: "sequence called reversed notify closure")
        let did_complete = expectation(description: "sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, statesForProperties: [PropertyStates(path: "color", end: UIColor.blue)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        let motion5 = Motion(target: tester, properties: [PropertyData("value", 80.0)], duration: 0.2)
        let sub_sequence = MotionSequence(steps: [motion3, motion4])
        
        let sequence = MotionSequence(steps: [group, sub_sequence, motion5], options: [.reverses])
            .reversed({ (sequence) in
                guard let motion = sequence.steps.last as? Motion, let subsequence = sequence.steps[1] as? MotionSequence else {
                    XCTFail("No Motion found in Sequence \(sequence.steps)")
                    return
                }
                
                XCTAssertTrue(sequence.totalProgress <= 0.5)
                XCTAssertTrue(sequence.cycleProgress <= 0.5)
                XCTAssertEqual(sequence.motionDirection, MotionDirection.reverse)
                XCTAssertEqual(subsequence.motionDirection, MotionDirection.reverse, "sub sequence when reversing should move in reverse")
                XCTAssertTrue(sequence.currentStep() === motion, "step after reversing should be same step")
                XCTAssertEqual(motion.motionDirection, MotionDirection.reverse, "sequence when reversing should move in reverse")
                
                did_reverse.fulfill()
            })
            .completed { (sequence) in
                guard let group = sequence.steps.first as? MotionGroup, let motion = group.motions.first as? Motion, let last = sequence.steps.last as? Motion, let subsequence = sequence.steps[1] as? MotionSequence, let sequence_motion = subsequence.steps[0] as? Motion else {
                    XCTFail("No Motion found in Sequence or Group")
                    return
                }
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
                XCTAssertEqual(sequence.motionState, MotionState.stopped)
                
                did_complete.fulfill()
        }
        
        sequence.reversingMode = .contiguous
        
        // should turn reversing property on sequence steps
        XCTAssertTrue(group.reversing)
        XCTAssertTrue(sub_sequence.reversing)
        XCTAssertTrue(motion5.reversing)
        
        sequence.start()
        
        // should pause first motion while moving the second
        let after_time = DispatchTime.now() + Double(Int64(0.7 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            XCTAssertEqual(group.motionState, MotionState.paused)
            XCTAssertEqual(sub_sequence.motionState, MotionState.paused)
            XCTAssertEqual(motion5.motionState, MotionState.moving)
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    
    func test_reversing_nested_sequence_in_last_position_contiguous() {
        let did_reverse = expectation(description: "sequence called reversed notify closure")
        let did_complete = expectation(description: "sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, statesForProperties: [PropertyStates(path: "color", end: UIColor.blue)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        let sub_sequence = MotionSequence(steps: [motion3, motion4])
        
        let sequence = MotionSequence(steps: [group, sub_sequence], options: [.reverses])
            .reversed({ (sequence) in
                guard let motion = sequence.steps.first as? MotionGroup, let subsequence = sequence.steps.last as? MotionSequence else {
                    XCTFail("No Motion found in Sequence \(sequence.steps)")
                    return
                }
                
                XCTAssertTrue(sequence.totalProgress <= 0.5)
                XCTAssertTrue(sequence.cycleProgress <= 0.5)
                XCTAssertEqual(sequence.motionDirection, MotionDirection.reverse)
                XCTAssertEqual(subsequence.motionDirection, MotionDirection.reverse, "sub sequence when reversing should move in reverse")
                XCTAssertTrue(sequence.currentStep() === subsequence, "step after reversing should be same step")
                XCTAssertEqual(motion.motionDirection, MotionDirection.reverse, "sequence when reversing should move in reverse")
                
                did_reverse.fulfill()
            })
            .completed { (sequence) in
                guard let group = sequence.steps.first as? MotionGroup, let motion = group.motions.first as? Motion, let subsequence = sequence.steps[1] as? MotionSequence, let sequence_motion = subsequence.steps[0] as? Motion else {
                    XCTFail("No Motion found in Sequence or Group")
                    return
                }
                XCTAssertTrue(sequence.currentStep() === group, "should end with first motion")
                
                // contiguous mode will reverse steps, so they should end back at start value
                XCTAssertEqual(tester.value, 0.0)
                XCTAssertEqual(motion.properties[0].current, motion.properties[0].start)
                XCTAssertEqual(sequence_motion.properties[0].current, sequence_motion.properties[0].start)
                
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(sequence.cyclesCompletedCount, 1)
                XCTAssertEqual(sequence.cycleProgress, 1.0)
                XCTAssertEqual(sequence.totalProgress, 1.0)
                XCTAssertEqual(sequence.motionState, MotionState.stopped)
                
                did_complete.fulfill()
        }
        
        sequence.reversingMode = .contiguous
        
        // should turn reversing property on sequence steps
        XCTAssertTrue(group.reversing)
        XCTAssertTrue(sub_sequence.reversing)
        
        sequence.start()
        
        // should pause first motion while moving the second
        let after_time = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            XCTAssertEqual(group.motionState, MotionState.paused)
            XCTAssertEqual(sub_sequence.motionState, MotionState.moving)
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    
    
    func test_reversing_nested_sequence_noncontiguous() {
        let did_reverse = expectation(description: "sequence called reversed notify closure")
        let did_complete = expectation(description: "sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, statesForProperties: [PropertyStates(path: "color", end: UIColor.blue)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        let sub_sequence = MotionSequence(steps: [motion3, motion4])
        let motion5 = Motion(target: tester, properties: [PropertyData("value", 80.0)], duration: 0.2)

        let sequence = MotionSequence(steps: [group, sub_sequence, motion5], options: [.reverses])
            .reversed({ (sequence) in
                guard let motion = sequence.steps.last as? Motion, let subsequence = sequence.steps[1] as? MotionSequence else {
                    XCTFail("No Motion found in Sequence \(sequence.steps)")
                    return
                }
  
                XCTAssertTrue(sequence.totalProgress <= 0.5)
                XCTAssertTrue(sequence.cycleProgress <= 0.5)
                XCTAssertEqual(sequence.motionDirection, MotionDirection.reverse)
                XCTAssertEqual(subsequence.motionDirection, MotionDirection.forward, "sub sequence when reversing should move in reverse")
                XCTAssertTrue(sequence.currentStep() === sequence.steps.last, "step after reversing should be same step")
                XCTAssertEqual(motion.motionDirection, MotionDirection.forward, "sequence when reversing should move forwards")

                did_reverse.fulfill()
            })
            .completed { (sequence) in
                guard let group = sequence.steps.first as? MotionGroup, let motion = group.motions.first as? Motion, let subsequence = sequence.steps[1] as? MotionSequence, let sequence_motion = subsequence.steps[0] as? Motion, let last = sequence.steps.last as? Motion else {
                    XCTFail("No Motion found in Sequence or Group")
                    return
                }
                
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
                XCTAssertEqual(sequence.motionState, MotionState.stopped)
                
                did_complete.fulfill()
        }
        
        // should not turn reversing property on sequence steps
        XCTAssertFalse(group.reversing)
        XCTAssertFalse(motion3.reversing)
        
        sequence.start()
        
        // should pause first motion while moving the second
        let after_time = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            XCTAssertEqual(group.motionState, MotionState.stopped)
            XCTAssertEqual(motion3.motionState, MotionState.moving)
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    
    func test_reversing_noncontiguous() {
        let did_reverse = expectation(description: "sequence called reversed notify closure")
        let did_complete = expectation(description: "sequence called completed notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, statesForProperties: [PropertyStates(path: "color", end: UIColor.blue)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        let motion3 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let motion4 = Motion(target: tester, properties: [PropertyData("value", 60.0)], duration: 0.2)
        
        let sequence = MotionSequence(steps: [group, motion3, motion4], options: [.reverses])
            .reversed({ (sequence) in
                if let motion = sequence.steps.last as? Motion {
                    
                    XCTAssertTrue(sequence.totalProgress <= 0.5)
                    XCTAssertTrue(sequence.cycleProgress <= 0.5)
                    XCTAssertEqual(sequence.motionDirection, MotionDirection.reverse)
                    XCTAssertTrue(sequence.currentStep() === sequence.steps.last, "step after reversing should be same step")
                    XCTAssertEqual(motion.motionDirection, MotionDirection.forward, "sequence when reversing should move forwards")
                    
                    did_reverse.fulfill()
                } else {
                    XCTFail("Motion not found in Sequence \(sequence.steps)")
                }
            })
            .completed { (sequence) in
                guard let group = sequence.steps.first as? MotionGroup, let motion = group.motions.first as? Motion, let last = sequence.steps.last as? Motion else {
                    XCTFail("Motion not found in Sequence or Group")
                    return
                }
                
                XCTAssertTrue(sequence.currentStep() === group, "should end with first motion")
                
                // noncontiguous mode will not reverse steps, so they should end at normal end value
                XCTAssertEqual(tester.value, 20.0)
                XCTAssertEqual(motion.properties[0].current, motion.properties[0].end)
                XCTAssertEqual(last.properties[0].current, last.properties[0].end)
                
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(sequence.cyclesCompletedCount, 1)
                XCTAssertEqual(sequence.cycleProgress, 1.0)
                XCTAssertEqual(sequence.totalProgress, 1.0)
                XCTAssertEqual(sequence.motionState, MotionState.stopped)
                
                did_complete.fulfill()
        }
        
        // should not turn reversing property on sequence steps
        XCTAssertFalse(group.reversing)
        XCTAssertFalse(motion3.reversing)
        
        sequence.start()
        
        // should pause first motion while moving the second
        let after_time = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            XCTAssertEqual(group.motionState, MotionState.stopped)
            XCTAssertEqual(motion3.motionState, MotionState.moving)
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    
    
    
    // MARK: Moveable methods
    
    func test_start() {
        let did_start = expectation(description: "sequence called started notify closure")

        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .started { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.moving)
            
            did_start.fulfill()
        }
        
        sequence.start()
        
        // should not start when paused
        sequence.pause()
        sequence.start()
        XCTAssertEqual(sequence.motionState, MotionState.paused)
        
        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
    func test_stop() {
        let did_stop = expectation(description: "sequence called stopped notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .stopped { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.stopped)
            
            did_stop.fulfill()
        }
        
        sequence.start()
        
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            sequence.stop()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_pause() {
        let did_pause = expectation(description: "sequence called paused notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .paused { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.paused)
            
            did_pause.fulfill()
        }
        
        sequence.start()
        sequence.pause()
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
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
        XCTAssertEqual(sequence.motionState, MotionState.stopped)
    }
    
    
    func test_resume() {
        let did_resume = expectation(description: "sequence called resumed notify closure")
        let did_complete = expectation(description: "squence called completed notify closure")

        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .resumed { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.moving)
            
            did_resume.fulfill()
        }
        .completed { (sequence) in
            XCTAssertEqual(tester.value, 40.0)
            XCTAssertEqual(sequence.totalProgress, 1.0)
            XCTAssertEqual(sequence.motionState, MotionState.stopped)
            
            did_complete.fulfill()
        }
        sequence.start()
        sequence.pause()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            sequence.resume()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_update() {
        
        let did_update = expectation(description: "sequence called updated notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        .updated { (sequence) in
            XCTAssertEqual(sequence.motionState, MotionState.moving)
            
            did_update.fulfill()
            sequence.stop()
        }
        
        sequence.start()
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_reset() {
        
        let did_reset = expectation(description: "motion called updated notify closure")
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 20.0)], duration: 0.2)
        let motion2 = Motion(target: tester, properties: [PropertyData("value", 40.0)], duration: 0.2)
        let sequence = MotionSequence(steps: [motion, motion2])
        
        sequence.start()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            sequence.reset()
            
            XCTAssertEqual(sequence.totalProgress, 0.0)
            XCTAssertEqual(sequence.cycleProgress, 0.0)
            
            did_reset.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    
}
