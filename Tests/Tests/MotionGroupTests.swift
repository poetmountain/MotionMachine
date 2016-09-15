//
//  GroupTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/22/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

class MotionGroupTests: XCTestCase {


    // MARK: Setup tests

    func test_add() {
        let tester = Tester()
        let group = MotionGroup()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        let motion3 = Motion(target: tester, duration: 1.0)

        // add should add a Moveable object to the group list
        group.add(motion)
        XCTAssertEqual(group.motions.count, 1)
        
        // add array should add all Moveable objects to the group list
        group.add([motion2, motion3])
        XCTAssertEqual(group.motions.count, 3)
    }
    
    func test_afterDelay() {
        let tester = Tester()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        // afterDelay should add a delay
        let group = MotionGroup(motions: [motion, motion2]).afterDelay(1.0)
        XCTAssertEqual(group.delay, 1.0)
    }
    
    func test_repeats() {
        let tester = Tester()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        
        // repeats should set repeating and amount
        let group = MotionGroup(motions: [motion, motion2]).repeats(1)
        XCTAssertTrue(group.repeating)
        XCTAssertEqual(group.repeatCycles, 1)
        
        // if no value provided, repeating should be infinite
        let group2 = MotionGroup(motions: [motion, motion2]).repeats()
        XCTAssertTrue(group2.repeating)
        XCTAssertEqual(group2.repeatCycles, REPEAT_INFINITE)
    }
    
    func test_reverses() {
        let tester = Tester()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)
        
        // reverses should set reversing and syncMotionsWhenReversing
        let group = MotionGroup(motions: [motion, motion2]).reverses(syncsChildMotions: true)
        XCTAssertTrue(group.reversing)
        XCTAssertTrue(group.syncMotionsWhenReversing)
        
    }
    

    func test_use_child_tempo() {
        let tester = Tester()
        let group = MotionGroup.init()
        let motion = Motion(target: tester, duration: 1.0)
        
        // specifying a group's child motion should use its own tempo should not override it with group tempo
        group.add(motion, useChildTempo: true)
        XCTAssertNotNil(motion.tempo, "child tempo should not be removed")
        
    }
    
    func test_remove() {
        let tester = Tester()
        let group = MotionGroup()
        let motion = Motion(target: tester, duration: 1.0)
        let motion2 = Motion(target: tester, duration: 1.0)

        group.add(motion)

        // remove should remove a Moveable object to the group list
        group.remove(motion)
        XCTAssertEqual(group.motions.count, 0)
        
        // remove should fail gracefully when object not in group list
        group.remove(motion2)
        XCTAssertEqual(group.motions.count, 0)

    }
    

    // MARK: Motion tests

    func test_should_end_motions_at_proper_ending_values() {
        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])

        // should assign tempo to group but remove child tempos
        XCTAssertNil(motion.tempo, "child tempo should be removed")
        XCTAssertNotNil(group.tempo, "group tempo should not be removed")
        
        let did_complete = expectation(description: "group called completed notify closure")

        group.completed { (group) in
            let motion = group.motions[0] as? Motion
            XCTAssertEqual(motion?.properties[0].current, motion?.properties[0].end)
            XCTAssertEqual(motion?.totalProgress, 1.0)
            let motion2 = group.motions[1] as? Motion
            XCTAssertEqual(motion2?.properties[0].current, motion2?.properties[0].end)
            XCTAssertEqual(motion2?.totalProgress, 1.0)
            
            did_complete.fulfill()
        }
        
        group.start()
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_delay() {
        
        let did_complete = expectation(description: "group called completed notify closure")
        let timestamp = CFAbsoluteTimeGetCurrent()
        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        .completed { (group) in
            
            let final_value = tester.value
            XCTAssertEqual(final_value, 10.0)
            XCTAssertEqual(group.totalProgress, 1.0)
            let new_timestamp = CFAbsoluteTimeGetCurrent()
            let motion = group.motions.first as! Motion
            XCTAssertEqualWithAccuracy(new_timestamp, timestamp + motion.duration, accuracy: 0.9)
            
            did_complete.fulfill()
        }
        group.delay = 0.2
        
        group.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    
    func test_repeating() {
        
        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 100.0)], duration: 0.2)
        
        let did_repeat = expectation(description: "group called cycleRepeated notify closure")
        let did_complete = expectation(description: "group called completed notify closure")
        
        let group = MotionGroup(motions: [motion, motion2], options: [.Repeat])
        .cycleRepeated({ (group) in
            XCTAssertEqual(group.totalProgress, 0.5)
            XCTAssertEqual(group.cycleProgress, 0.0)
            XCTAssertEqual(group.cyclesCompletedCount, 1)

            did_repeat.fulfill()
        })
        .completed { (group) in
            XCTAssertEqual(tester.value, 100.0)
            XCTAssertEqual(tester2.value, 100.0)
            let motion = group.motions.first as? Motion
            XCTAssertEqual(motion?.properties[0].current, motion?.properties[0].end)
            XCTAssertEqual(motion?.totalProgress, 1.0)
            let new_cycles = group.repeatCycles + 1
            XCTAssertEqual(group.cyclesCompletedCount, new_cycles)
            XCTAssertEqual(group.cycleProgress, 1.0)
            XCTAssertEqual(group.totalProgress, 1.0)
            XCTAssertEqual(group.motionState, MotionState.stopped)
            
            did_complete.fulfill()
        }
        .repeats(1)
        
        group.start()
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        
    }
    
    func test_reversing() {
        
        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 100.0)], duration: 0.2)
        
        let did_reverse = expectation(description: "group called reversed notify closure")
        let did_complete = expectation(description: "group called completed notify closure")
        
        let group = MotionGroup(motions: [motion, motion2], options: [.Reverse])
            .reversed({ (group) in
                XCTAssertTrue(group.totalProgress <= 0.5)
                XCTAssertTrue(group.cycleProgress <= 0.5)
                XCTAssertEqual(group.motionDirection, MotionDirection.reverse)
                
                did_reverse.fulfill()
            })
            .completed { (group) in
                XCTAssertEqual(tester.value, 0.0)
                XCTAssertEqual(tester2.value, 0.0)
                let motion = group.motions.first as? Motion
                XCTAssertEqual(motion?.properties[0].current, motion?.properties[0].start)
                XCTAssertEqual(motion?.totalProgress, 1.0)
                XCTAssertEqual(group.cyclesCompletedCount, 1)
                XCTAssertEqual(group.cycleProgress, 1.0)
                XCTAssertEqual(group.totalProgress, 1.0)
                XCTAssertEqual(group.motionState, MotionState.stopped)
                
                did_complete.fulfill()
        }
        
        // should turn on reversing for all child motions
        XCTAssertTrue(motion.reversing)
        XCTAssertTrue(motion2.reversing)
        
        group.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_reversing_when_syncMotionsWhenReversing_is_true() {
        
        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 100.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 100.0)], duration: 0.5)
        
        let did_reverse = expectation(description: "group called reversed notify closure")
        let did_complete = expectation(description: "group called completed notify closure")
        
        let group = MotionGroup(motions: [motion, motion2])
            .reversed({ (group) in
                print("reversed")
                XCTAssertTrue(group.totalProgress <= 0.5)
                XCTAssertTrue(group.cycleProgress <= 0.5)
                XCTAssertEqual(group.motionDirection, MotionDirection.reverse)
                
                did_reverse.fulfill()
                
            })
            .completed { (group) in
                XCTAssertEqual(tester.value, 0.0)
                XCTAssertEqual(tester2.value, 0.0)
                let motion = group.motions.first as? Motion
                XCTAssertEqual(motion?.properties[0].current, motion?.properties[0].start)
                XCTAssertEqual(motion?.totalProgress, 1.0)
                XCTAssertEqual(group.cyclesCompletedCount, 1)
                XCTAssertEqual(group.cycleProgress, 1.0)
                XCTAssertEqual(group.totalProgress, 1.0)
                XCTAssertEqual(group.motionState, MotionState.stopped)
                
                did_complete.fulfill()
        }
        .reverses(syncsChildMotions: true)
        .start()

        let after_time = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            // motion with the shorter duration should wait for the other motion to finish before group reverses
            XCTAssertEqual(motion.motionState, MotionState.paused)
            XCTAssertEqual(motion2.motionState, MotionState.moving)
            XCTAssertEqual(group.motionDirection, MotionDirection.forward)
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    
    // MARK: Moveable methods
    
    func test_start() {
        
        let did_start = expectation(description: "group called started notify closure")

        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        .started { (group) in
            XCTAssertEqual(group.motionState, MotionState.moving)
            
            did_start.fulfill()
        }
        
        group.start()
        
        // should not start when paused
        group.pause()
        group.start()
        XCTAssertEqual(group.motionState, MotionState.paused)
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_stop() {
        
        let did_stop = expectation(description: "group called stopped notify closure")
        
        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        .stopped { (group) in
            XCTAssertEqual(group.motionState, MotionState.stopped)
            
            did_stop.fulfill()
        }
        
        group.start()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            group.stop()
        })

        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_pause() {
        
        let did_pause = expectation(description: "group called paused notify closure")
        
        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        .paused { (group) in
            XCTAssertEqual(group.motionState, MotionState.paused)
            
            did_pause.fulfill()
        }
        
        group.start()
        group.pause()
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_pause_while_stopped() {
        
        let tester = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion])

        
        group.start()
        group.stop()
        group.pause()
        
        // should not pause while stopped
        XCTAssertEqual(group.motionState, MotionState.stopped)
    }
    
    func test_resume() {
        
        let did_resume = expectation(description: "group called resumed notify closure")
        let did_complete = expectation(description: "group called completed notify closure")

        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        .resumed { (group) in
            XCTAssertEqual(group.motionState, MotionState.moving)
            
            did_resume.fulfill()
        }
        .completed { (group) in
            XCTAssertEqual(tester.value, 10.0)
            XCTAssertEqual(group.totalProgress, 1.0)
            XCTAssertEqual(group.motionState, MotionState.stopped)
            
            did_complete.fulfill()
        }
        group.start()
        group.pause()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            group.resume()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_update() {
        
        let did_update = expectation(description: "group called updated notify closure")
        
        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
            .updated { (group) in
                XCTAssertEqual(group.motionState, MotionState.moving)
                
                did_update.fulfill()
                group.stop()
        }
        
        group.start()
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_reset() {
        
        let did_reset = expectation(description: "motion called updated notify closure")

        let tester = Tester()
        let tester2 = Tester()
        let motion = Motion(target: tester, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let motion2 = Motion(target: tester2, properties: [PropertyData("value", 10.0)], duration: 0.2)
        let group = MotionGroup(motions: [motion, motion2])
        
        group.start()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            group.reset()
            
            XCTAssertEqual(group.totalProgress, 0.0)
            XCTAssertEqual(group.cycleProgress, 0.0)
            XCTAssertEqual(group.cyclesCompletedCount, 0)
            
            did_reset.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    
}
