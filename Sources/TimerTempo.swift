//
//  TimerTempo.swift
//  MotionMachine
//
//  Created by Brett Walker on 5/20/16.
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

import Foundation

/**
 *  TimerTempo uses an internal `NSTimer` object to send out tempo updates.
 */
public class TimerTempo : Tempo {
    
    /**
     *  This `NSTimer` object is used to provide tempo updates.
     *
     *  - warning: Do not call the `invalidate` method on this object, as its state is handled by TimerTempo directly.
     */
    public var timer: Timer?
    
    /**
     *  Initializes a new `TimerTempo` object and starts the internal timer.
     *
     *  - parameter interval: The rate, in number of seconds, between updates of the timer. The default value is 60 updates/second.
     *  - returns: A new `TimerTempo` object.
     */
    public convenience init(withInterval interval: TimeInterval?=(1.0/60.0)) {
        self.init(interval: interval)
    }
    
    private init(interval: TimeInterval?) {
        super.init()
        timer = Timer(timeInterval: interval!, weakTarget: self, selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)

    }
    
    deinit {
        timer?.invalidate()
    }
    
    
    @objc func update() -> Void {
        let time_stamp: CFTimeInterval = CFAbsoluteTimeGetCurrent()
        delegate?.tempoBeatUpdate(time_stamp)
    }
    
}
