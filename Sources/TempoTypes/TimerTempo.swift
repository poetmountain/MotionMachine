//
//  TimerTempo.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

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
        if let interval {
            let timer = Timer(timeInterval: interval, weakTarget: self, selector: #selector(update), userInfo: nil, repeats: true)
            self.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    /// Calling this method invalides the `Timer` object to prepare for deallocation.
    public override func cleanupResources() {
        timer?.invalidate()
    }
    
    @objc func update() -> Void {
        let time_stamp: CFTimeInterval = CFAbsoluteTimeGetCurrent()
        delegate?.tempoBeatUpdate(time_stamp)
    }
    
}
