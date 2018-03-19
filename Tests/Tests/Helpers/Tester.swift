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
    var transform3D = CATransform3D(m11: 0.0, m12: 0.0, m13: 0.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0)
    var color = UIColor.red
    var insets = UIEdgeInsets.zero
    var offset = UIOffset.zero
}
