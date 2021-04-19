//
//  CATempo.swift
//  MotionMachine
//
//  Created by Brett Walker on 4/19/16.
//  Copyright © 2016-2018 Poet & Mountain, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

/**
 *  CATempo uses a `CADisplayLink` object to send out tempo updates that are synchronized with the refresh rate of the display on iOS.
 */
public class CATempo : Tempo {
    
    /**
     *  This `CADisplayLink` object is used to provide tempo updates.
     *
     *  - remarks: This class provides several mechanisms for adjusting the update rate. See the `CADisplayLink` documentation for more information.
     *
     *  - warning: Do not call the `addToRunLoop:forMode:`, `removeFromRunLoop:forMode:`, or `invalidate` methods on this object, as its state is handled by CATempo directly.
     */
    public var displayLink: CADisplayLink?
    
    /**
     *  Initializes a new `CATempo` object and adds the internal `CADisplayLink` object to the main run loop.
     *
     */
    public override init() {
        super.init()
        
        displayLink = CADisplayLink(weakTarget: self, selector: #selector(update))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    

    @objc func update() -> Void {
        let time_stamp: CFTimeInterval = self.displayLink?.timestamp ?? 0.0
        delegate?.tempoBeatUpdate(time_stamp)
    }
    
}
