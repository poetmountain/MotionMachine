//
//  Tester.swift
//  MotionMachineTests
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import UIKit
import XCTest

@MainActor final class Tester {
    
    var value: Double = 0.0
    var point = CGPoint.zero
    var size = CGSize.zero
    var rect = CGRect.zero
    var vector = CGVector.zero
    var transform = CGAffineTransform.identity
    var transform3D = CATransform3DIdentity
    var color = UIColor.red
    var ciColor = CIColor.red
    var cgColor = UIColor.red.cgColor
    var insets = UIEdgeInsets.zero
    var offset = UIOffset.zero
    var sub = SubTest()
    
    var simd2: SIMD2<Double> = SIMD2(x: 20, y: 10)
    var simd3: SIMD3<Float> = SIMD3(x: 10, y: 75, z: 10)
    var simd4: SIMD4<Int> = SIMD4(x: 10, y: 10, z: 10, w: 10)
    var simd8: SIMD8<Float> = SIMD8(repeating: 10)
    var simd16: SIMD16<Float> = SIMD16(repeating: 5)
    var simd32: SIMD32<Float> = SIMD32(repeating: 100)
    var simd64: SIMD64<Float> = SIMD64(repeating: 100)
}

@MainActor final class SubTest {
    var rect = CGRect.zero
    var value: Double = 0.0
}

extension XCTestCase {

  func wait(timeout: TimeInterval) {
    let expectation = XCTestExpectation(description: "Waiting for \(timeout) seconds")
    XCTWaiter().wait(for: [expectation], timeout: timeout)
  }

}
