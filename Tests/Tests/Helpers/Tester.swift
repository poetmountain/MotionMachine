//
//  Tester.swift
//  MotionMachineTests
//
//  Created by Brett Walker on 5/21/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
class Tester: NSObject {
    
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
class SubTest: NSObject {
    var rect = CGRect.zero
}
