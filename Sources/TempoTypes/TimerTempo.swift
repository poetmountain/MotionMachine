//
//  TimerTempo.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// TimerTempo uses an internal `Timer` object to send out tempo updates. By default, the update interval is twice the maximum refresh rate of the current display.
public class TimerTempo : TempoProviding {
    
    /**
     *  This `Timer` object is used to provide tempo updates.
     *
     *  - warning: Do not call the `invalidate` method on this object, as its state is handled by TimerTempo directly.
     */
    public var timer: Timer?
        
    public weak var delegate: TempoDelegate?

    /**
     *  Initializes a new `TimerTempo` object and starts the internal timer.
     *
     *  - parameter interval: The rate, in number of seconds, between updates of the timer. If no value is provided, the default value is twice the maximum refresh rate of the current display.
     *  - returns: A new `TimerTempo` object.
     */
    public convenience init(withInterval interval: TimeInterval? = nil) {
        
        var timerInterval = interval
        
        if interval == nil {
#if os(iOS) || os(tvOS) || os(visionOS)
            let fps = UIScreen.main.maximumFramesPerSecond.toDouble() ?? 60.0
            timerInterval = (1.0 / fps)
#elseif os(macOS)
            let fps = NSScreen.main?.maximumFramesPerSecond.toDouble() ?? 60.0
            timerInterval = (1.0 / fps)
#endif
        }
        
        self.init(interval: timerInterval)
    }
    
    private init(interval: TimeInterval?) {
        if let interval {
            let timer = Timer(timeInterval: interval, weakTarget: self, selector: #selector(update(timer:)), userInfo: nil, repeats: true)
            timer.tolerance = 0.008
            self.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    /// Calling this method invalides the `Timer` object to prepare for deallocation.
    public func cleanupResources() {
        timer?.invalidate()
    }
    
    @objc func update(timer: Timer) -> Void {
        let timestamp: TimeInterval = CFAbsoluteTimeGetCurrent()

        delegate?.tempoBeatUpdate(timestamp)
    }
    
}
