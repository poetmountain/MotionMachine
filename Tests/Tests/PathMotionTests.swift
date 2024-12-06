//
//  PathMotionTests.swift
//  MotionMachineTests
//
///  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit

@MainActor final class PathMotionTests: XCTestCase {

    func test_start_end_values_set_property_data() {

        let path = UIBezierPath(rect: .zero)
        let pathState = PathState(path: path.cgPath)
        let motion = PathMotion(pathState: pathState, duration: 0.2, startPosition: 0.2, endPosition: 0.8)

        XCTAssertEqual(motion.properties[0].start, 0.2)
        XCTAssertEqual(motion.properties[0].end, 0.8)

    }
    
    func test_afterDelay() {
        let path = UIBezierPath(rect: .zero)
        let pathState = PathState(path: path.cgPath)
        
        // afterDelay should add a delay
        let motion = PathMotion(pathState: pathState, duration: 0.2).afterDelay(1.0)
        XCTAssertEqual(motion.delay, 1.0)
    }

    func test_repeats() {
        let path = UIBezierPath(rect: .zero)
        let pathState = PathState(path: path.cgPath)
        
        // repeats should set repeating and amount
        let motion = PathMotion(pathState: pathState, duration: 0.2).repeats(1)
        XCTAssertTrue(motion.repeating)
        XCTAssertEqual(motion.repeatCycles, 1)
        
        // if no value provided, repeating should be infinite
        let motion2 = PathMotion(pathState: pathState, duration: 0.2).repeats()
        XCTAssertTrue(motion2.repeating)
        XCTAssertEqual(motion2.repeatCycles, REPEAT_INFINITE)
        
    }
    
    func test_reverses() {
        let path = UIBezierPath(rect: .zero)
        let pathState = PathState(path: path.cgPath)
        
        // reverses should set reversing and reverseEasing properties
        let easing: EasingUpdateClosure = EasingQuadratic.easeIn()
        let motion = PathMotion(pathState: pathState, duration: 0.2).reverses(withEasing: easing)
        XCTAssertTrue(motion.reversing)
        XCTAssertTrue(motion.reverseEasing != nil)
        
    }
    
    // MARK: Motion tests
    
    func test_motion_should_end_at_specified_value() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
        path.addQuadCurve(to: CGPoint(x: 20, y: 50), controlPoint: CGPoint(x: 100, y: 45))
        path.addCurve(to: CGPoint(x: 150, y: 100), controlPoint1: CGPoint(x: 100, y: 150), controlPoint2: CGPoint(x: 80, y: 0))
        let pathState = PathState(path: path.cgPath)
        
        let didComplete = expectation(description: "motion called completed notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.2, endPosition: 0.8)
        .completed { (motion, currentPoint)  in

            let finalValue = motion.properties[0].current
            XCTAssertEqual(finalValue, 0.8)

            let expectedPoint = pathState.point(at: 0.8)
            XCTAssertEqual(currentPoint, expectedPoint)
            
            XCTAssertEqual(motion.totalProgress, 1.0)

            didComplete.fulfill()
        }

        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_motion_with_reversed_start_end_values_should_end_at_specified_value() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
        path.addQuadCurve(to: CGPoint(x: 20, y: 50), controlPoint: CGPoint(x: 100, y: 45))
        path.addCurve(to: CGPoint(x: 150, y: 100), controlPoint1: CGPoint(x: 100, y: 150), controlPoint2: CGPoint(x: 80, y: 0))
        let pathState = PathState(path: path.cgPath)
        
        let didComplete = expectation(description: "motion called completed notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.2, startPosition: 0.8, endPosition: 0.0)
        .completed { (motion, currentPoint)  in

            let finalValue = motion.properties[0].current
            XCTAssertEqual(finalValue, 0.0)

            let expectedPoint = pathState.point(at: 0.0)
            XCTAssertEqual(currentPoint, expectedPoint)
            
            XCTAssertEqual(motion.totalProgress, 1.0)

            didComplete.fulfill()
        }

        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_complex_path_motion_should_end_at_specified_value() {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 300, height: 250), cornerRadius: 54)
        path.addQuadCurve(to: CGPoint(x: 20, y: 50), controlPoint: CGPoint(x: 100, y: 45))
        path.addCurve(to: CGPoint(x: 150, y: 100), controlPoint1: CGPoint(x: 100, y: 150), controlPoint2: CGPoint(x: 80, y: 0))
        let pathState = PathState(path: path.cgPath)
        
        let didComplete = expectation(description: "motion called completed notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.5, endPosition: 0.8)
        .completed { (motion, currentPoint)  in

            let finalValue = motion.properties[0].current
            XCTAssertEqual(finalValue, 0.8)

            let expectedPoint = pathState.point(at: 0.8)
            XCTAssertEqual(currentPoint, expectedPoint)
            
            XCTAssertEqual(motion.totalProgress, 1.0)

            didComplete.fulfill()
        }

        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_motion_back_easing_stopping_at_edges() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
        let pathState = PathState(path: path.cgPath)
        let backEasingPoint = pathState.point(at: 1.0)
        
        let didComplete = expectation(description: "motion called completed notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.4, easing: EasingBack.easeOut(), edgeBehavior: .stopAtEdges)
        motion.updated { (motion, currentPoint) in
            guard let backEasingPoint else { return }
            // point should stop at end of path instead of wrapping around when the Back easing takes effect
            if Math.fuzzyCompare(a: currentPoint.x, b: backEasingPoint.x, errorLimit: 0.1) && Math.fuzzyCompare(a: currentPoint.y, b: backEasingPoint.y, errorLimit: 0.1) {
                XCTAssertEqual(currentPoint.x, backEasingPoint.x, accuracy: 0.1)
                XCTAssertEqual(currentPoint.y, backEasingPoint.y, accuracy: 0.1)
                didComplete.fulfill()
            }
            
        }

        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_motion_back_easing_with_continguous_edges() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
        let pathState = PathState(path: path.cgPath)
        let backEasingPoint = pathState.point(at: 0.1)
        
        let didComplete = expectation(description: "motion called completed notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.4, easing: EasingBack.easeOut(), edgeBehavior: .contiguousEdges)
        motion.updated { (motion, currentPoint) in
            guard let backEasingPoint = backEasingPoint else { return }
            // point should wrap around to beginning of path as the Back easing takes effect
            if Math.fuzzyCompare(a: currentPoint.x, b: backEasingPoint.x, errorLimit: 0.1) && Math.fuzzyCompare(a: currentPoint.y, b: backEasingPoint.y, errorLimit: 0.1) {
                XCTAssertEqual(currentPoint.x, backEasingPoint.x, accuracy: 0.1)
                XCTAssertEqual(currentPoint.y, backEasingPoint.y, accuracy: 0.1)
                didComplete.fulfill()
            }
            
        }

        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_delayed_motion() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let didComplete = expectation(description: "motion called completed notify closure")
        let timestamp = CFAbsoluteTimeGetCurrent()
        let motion = PathMotion(pathState: pathState, duration: 0.2, endPosition: 0.8)
            .started({ motion, currentPoint in
                let newTimestamp = CFAbsoluteTimeGetCurrent()
                XCTAssertEqual(newTimestamp, timestamp + 0.2, accuracy: 0.05)
            })
            .completed { (motion, currentPoint)  in
                
                let finalValue = motion.properties[0].current
                XCTAssertEqual(finalValue, 0.8)

                let expectedPoint = pathState.point(at: 0.8)
                XCTAssertEqual(currentPoint, expectedPoint)
                
                XCTAssertEqual(motion.totalProgress, 1.0)
                
                let newTimestamp = CFAbsoluteTimeGetCurrent()
                XCTAssertEqual(newTimestamp, timestamp + motion.duration + 0.2, accuracy: 0.05)
                
                didComplete.fulfill()
        }
        motion.delay = 0.2
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_repeating_motion_should_repeat() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
        path.addQuadCurve(to: CGPoint(x: 20, y: 50), controlPoint: CGPoint(x: 100, y: 45))
        path.addCurve(to: CGPoint(x: 150, y: 100), controlPoint1: CGPoint(x: 100, y: 150), controlPoint2: CGPoint(x: 80, y: 0))
        
        let pathState = PathState(path: path.cgPath)
        
        let didRepeat = expectation(description: "motion called cycleRepeated notify closure")
        let didComplete = expectation(description: "motion called completed notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.4, endPosition: 0.8).repeats()
            .cycleRepeated({ (motion, currentPoint)  in
                XCTAssertEqual(motion.totalProgress, 0.5)
                XCTAssertEqual(motion.cycleProgress, 0.0)
                
                // motion value and current point should reset back to starting values
                XCTAssertEqual(motion.properties[0].current, 0.0)
                
                let expectedPoint = pathState.point(at: 0.0)
                XCTAssertEqual(currentPoint, expectedPoint)
                
                didRepeat.fulfill()
            })
            .completed { (motion, currentPoint)  in
                let finalValue = motion.properties[0].current
                XCTAssertEqual(finalValue, 0.8)
                
                let expectedPoint = pathState.point(at: 0.8)
                XCTAssertEqual(currentPoint, expectedPoint)
                
                let newCycles = motion.repeatCycles + 1
                XCTAssertEqual(motion.cyclesCompletedCount, newCycles)
                XCTAssertEqual(motion.cycleProgress, 1.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, MotionState.stopped)
                
                didComplete.fulfill()
        }
        motion.repeatCycles = 1
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_reversing_motion_should_reverse() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
        path.addQuadCurve(to: CGPoint(x: 20, y: 50), controlPoint: CGPoint(x: 100, y: 45))
        path.addCurve(to: CGPoint(x: 150, y: 100), controlPoint1: CGPoint(x: 100, y: 150), controlPoint2: CGPoint(x: 80, y: 0))
        
        let pathState = PathState(path: path.cgPath)
        let endPosition = 0.8
        
        let did_reverse = expectation(description: "motion called reversed notify closure")
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.4, endPosition: endPosition).reverses()
            .reversed({ (motion, currentPoint)  in
                XCTAssertTrue(motion.totalProgress <= 0.5)
                XCTAssertTrue(motion.cycleProgress <= 0.5)
                XCTAssertEqual(motion.motionDirection, MotionDirection.reverse)

                let finalValue = motion.properties[0].current
                XCTAssertEqual(finalValue, endPosition, accuracy: 0.000001)
                
                if let expectedPoint = pathState.point(at: endPosition)  {
                    XCTAssertEqual(currentPoint.x, expectedPoint.x, accuracy: 0.000001)
                    XCTAssertEqual(currentPoint.y, expectedPoint.y, accuracy: 0.000001)
                } else {
                    XCTFail("Could not generate point on path")
                }
                did_reverse.fulfill()
            })
            .completed { (motion, currentPoint)  in
                // expect final values to be back at beginning state after reversing is complete
                let finalValue = motion.properties[0].current
                XCTAssertEqual(finalValue, 0.0)
                let expectedPoint = pathState.point(at: 0.0)
                XCTAssertEqual(currentPoint, expectedPoint)
                
                XCTAssertEqual(motion.cyclesCompletedCount, 1)
                XCTAssertEqual(motion.cycleProgress, 1.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, MotionState.stopped)
                
                did_complete.fulfill()
        }
        
        motion.start()
        waitForExpectations(timeout: 2.0, handler: nil)
        
    }
    
    func test_reversing_and_repeating_motion_should_reverse_and_repeat() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
        path.addQuadCurve(to: CGPoint(x: 20, y: 50), controlPoint: CGPoint(x: 100, y: 45))
        path.addCurve(to: CGPoint(x: 150, y: 100), controlPoint1: CGPoint(x: 100, y: 150), controlPoint2: CGPoint(x: 80, y: 0))
        let pathState = PathState(path: path.cgPath)
        let endPosition = 0.8
        
        let did_repeat = expectation(description: "motion called cycleRepeated notify closure")
        let did_complete = expectation(description: "motion called completed notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.4, endPosition: endPosition, options: [.reverses, .repeats])
            .reversed({ (motion, currentPoint)  in
                if (motion.cyclesCompletedCount == 0) {
                    XCTAssertTrue(motion.totalProgress <= 0.25)
                    XCTAssertTrue(motion.cycleProgress <= 0.5)
                    
                    let finalValue = motion.properties[0].current
                    XCTAssertEqual(finalValue, endPosition, accuracy: 0.000001)
                    
                    if let expectedPoint = pathState.point(at: endPosition)  {
                        XCTAssertEqual(currentPoint.x, expectedPoint.x, accuracy: 0.000001)
                        XCTAssertEqual(currentPoint.y, expectedPoint.y, accuracy: 0.000001)
                    } else {
                        XCTFail("Could not generate point on path")
                    }
                }
            })
            .cycleRepeated({ (motion, currentPoint)  in
                XCTAssertEqual(motion.totalProgress, 0.5)
                XCTAssertEqual(motion.cycleProgress, 0.0)
                
                // motion value and current point should reset back to starting values
                XCTAssertEqual(motion.properties[0].current, 0.0)
                
                let expectedPoint = pathState.point(at: 0.0)
                XCTAssertEqual(pathState.currentPoint, expectedPoint)
                
                did_repeat.fulfill()
            })
            .completed { (motion, currentPoint)  in
                // expect final values to be back at beginning state after reversing is complete
                let finalValue = motion.properties[0].current
                XCTAssertEqual(finalValue, 0.0)
                let expectedPoint = pathState.point(at: 0.0)
                XCTAssertEqual(currentPoint, expectedPoint)
                
                XCTAssertEqual(motion.cyclesCompletedCount, 2)
                XCTAssertEqual(motion.cycleProgress, 1.0)
                XCTAssertEqual(motion.totalProgress, 1.0)
                XCTAssertEqual(motion.motionState, MotionState.stopped)
                
                did_complete.fulfill()
        }
        motion.repeatCycles = 1
        
        motion.start()
        waitForExpectations(timeout: 3.0, handler: nil)
        
    }
    
    
    
    
    // MARK: Moveable methods
    
    func test_start() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let did_start = expectation(description: "motion called started notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.2)
            .started { (motion, currentPoint)  in
                XCTAssertEqual(motion.motionState, MotionState.moving)
                
                did_start.fulfill()
        }
        
        motion.start()
        motion.stop()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_start_while_paused() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let motion = PathMotion(pathState: pathState, duration: 0.2)
        motion.start()
        motion.pause()
        motion.start()
        
        // should not start again
        XCTAssertEqual(motion.motionState, MotionState.paused)
        
    }
    
    func test_stop() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let did_stop = expectation(description: "motion called stopped notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.2)
            .stopped { (motion, currentPoint)  in
                XCTAssertEqual(motion.motionState, MotionState.stopped)
                
                did_stop.fulfill()
        }
        
        motion.start()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            motion.stop()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_pause() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        let duration = 0.4
        
        let did_pause = expectation(description: "motion called paused notify closure")
        let pauseDelay = 0.2
        
        let motion = PathMotion(pathState: pathState, duration: duration)
        .paused { (motion, currentPoint)  in
            XCTAssertEqual(motion.motionState, MotionState.paused)
            
            did_pause.fulfill()
        }
        
        motion.start()
        
        let after_time = DispatchTime.now() + Double(Int64(pauseDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: after_time, qos: .userInteractive, execute: {
            motion.pause()
        })

        waitForExpectations(timeout: 2.0, handler: nil)

    }
    
    func test_pause_while_stopped() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let motion = PathMotion(pathState: pathState, duration: 0.2)
        motion.start()
        motion.stop()
        motion.pause()
        
        // should not pause while stopped
        XCTAssertEqual(motion.motionState, MotionState.stopped)
        
    }
    
    func test_resume() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let did_resume = expectation(description: "motion called resumed notify closure")
        let did_complete = expectation(description: "motion called completed notify closure")

        let motion = PathMotion(pathState: pathState, duration: 0.4)
        .resumed { (motion, currentPoint)  in
            XCTAssertEqual(motion.motionState, MotionState.moving)
            
            did_resume.fulfill()
        }
        .completed { (motion, currentPoint)  in
            let finalValue = motion.properties[0].current
            XCTAssertEqual(finalValue, 1.0)
            let expectedPoint = pathState.point(at: 1.0)
            XCTAssertEqual(currentPoint, expectedPoint)
            
            XCTAssertEqual(motion.totalProgress, 1.0)
            XCTAssertEqual(motion.motionState, MotionState.stopped)
            
            did_complete.fulfill()
        }
        motion.start()
        motion.pause()
        let after_time = DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: after_time, execute: {
            motion.resume()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_resume_while_stopped() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let motion = PathMotion(pathState: pathState, duration: 0.2)
        motion.start()
        motion.stop()
        motion.resume()
        
        // should not start again
        XCTAssertEqual(motion.motionState, MotionState.stopped)
        
    }
    
    func test_update() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let did_update = expectation(description: "motion called updated notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.2)
            .updated { (motion, currentPoint)  in
                XCTAssertEqual(motion.motionState, MotionState.moving)
                
                did_update.fulfill()
                motion.stop()
        }
        
        motion.start()
        waitForExpectations(timeout: 1.0, handler: nil)
        
    }
    
    func test_reset() {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pathState = PathState(path: path.cgPath)
        
        let did_reset = expectation(description: "motion called updated notify closure")
        
        let motion = PathMotion(pathState: pathState, duration: 0.2)
        
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
