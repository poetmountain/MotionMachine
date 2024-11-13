//
//  Tester.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/21/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import Foundation
import UIKit
import XCTest

@objcMembers
@MainActor class Tester: NSObject {
    
    var value: Double = 0.0
    var rect = CGRect.zero
    var vector = CGVector.zero
    var transform = CGAffineTransform.identity
    var transform3D = CATransform3DIdentity
    var color = UIColor.red
    var insets = UIEdgeInsets.zero
    var offset = UIOffset.zero
    var sub = SubTest()
}

@objcMembers
@MainActor class SubTest: NSObject {
    var rect = CGRect.zero
}

extension XCTestCase {

  func wait(timeout: TimeInterval) {
    let expectation = XCTestExpectation(description: "Waiting for \(timeout) seconds")
    XCTWaiter().wait(for: [expectation], timeout: timeout)
  }

}
