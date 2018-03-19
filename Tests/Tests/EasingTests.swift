//
//  EasingTests.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/22/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import XCTest

class EasingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func test_easing_linear() {
        let easing = EasingLinear.easeNone()
        let mid = easing(50, 0, 100, 100)
        let end = easing(100, 0, 100, 100)
        
        XCTAssertEqual(mid, 50)
        XCTAssertEqual(end, 100)
    }
    
    func test_easing_quadratic() {
        // easeIn
        let ease_in = EasingQuadratic.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, 25)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingQuadratic.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 75)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingQuadratic.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_cubic() {
        // easeIn
        let ease_in = EasingCubic.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, 12.5)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingCubic.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 87.5)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingCubic.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_quartic() {
        // easeIn
        let ease_in = EasingQuartic.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, 6.25)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingQuartic.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 93.75)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingQuartic.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_quintic() {
        // easeIn
        let ease_in = EasingQuintic.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, 3.125)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingQuintic.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 96.875)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingQuintic.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_sine() {
        // easeIn
        let ease_in = EasingSine.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, 29.29, accuracy: 0.01)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingSine.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 70.71, accuracy: 0.01)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingSine.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50.0, accuracy: 0.0000001)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_expo() {
        // easeIn
        let ease_in = EasingExpo.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, 3.125)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingExpo.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 96.875)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingExpo.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50.0)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_circular() {
        // easeIn
        let ease_in = EasingCircular.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, 13.39, accuracy: 0.01)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingCircular.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 86.6, accuracy: 0.01)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingCircular.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50.0)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_elastic() {
        // easeIn
        let ease_in = EasingElastic.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, -1.5625, accuracy: 0.00001)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingElastic.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 101.5625, accuracy: 0.00001)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingElastic.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50.0)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_back() {
        // easeIn
        let ease_in = EasingBack.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, -8.76975, accuracy: 0.000001)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingBack.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 108.76975, accuracy: 0.000001)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingBack.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50.0)
        XCTAssertEqual(end_inout, 100)
    }
    
    func test_easing_bounce() {
        // easeIn
        let ease_in = EasingBounce.easeIn()
        let mid_in = ease_in(50, 0, 100, 100)
        let end_in = ease_in(100, 0, 100, 100)
        
        XCTAssertEqual(mid_in, 23.4375, accuracy: 0.00001)
        XCTAssertEqual(end_in, 100)
        
        // easeOut
        let ease_out = EasingBounce.easeOut()
        let mid_out = ease_out(50, 0, 100, 100)
        let end_out = ease_out(100, 0, 100, 100)
        
        XCTAssertEqual(mid_out, 76.5625, accuracy: 0.00001)
        XCTAssertEqual(end_out, 100)
        
        // easeInOut
        let ease_inout = EasingBounce.easeInOut()
        let mid_inout = ease_inout(50, 0, 100, 100)
        let end_inout = ease_inout(100, 0, 100, 100)
        
        XCTAssertEqual(mid_inout, 50.0)
        XCTAssertEqual(end_inout, 100)
    }

}
