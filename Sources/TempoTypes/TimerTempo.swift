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

/// TimerTempo uses an internal `DispatchSourceTimer` object to send out tempo updates. By default, the update interval is twice the maximum refresh rate of the current display.
public class TimerTempo : TempoProviding {
    
    /**
     *  This `DispatchSourceTimer` object is used to provide tempo updates.
     *
     *  - warning: Do not call the `cancel()` method on this object, as its state is handled by TimerTempo directly.
     */
    public var timer: DispatchSourceTimer?
    
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
#if os(iOS) || os(tvOS)
            let fps = UIScreen.main.maximumFramesPerSecond.toDouble() ?? 60.0
            timerInterval = (1.0 / fps)
#elseif os(macOS)
            let fps = NSScreen.main?.maximumFramesPerSecond.toDouble() ?? 60.0
            timerInterval = (1.0 / fps)
#elseif os(visionOS)
            timerInterval = (1.0 / 90.0)
#else
            timerInterval = (1.0 / 60.0)
#endif
        }
        
        self.init(interval: timerInterval)
    }
    
    private init(interval: TimeInterval?) {
        if let interval {
            timer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue.main)
            timer?.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(8))
            timer?.setEventHandler { [weak self] in
                self?.update()
            }
            timer?.resume()
        }
    }
    
    /// Calling this method cancels the `DispatchSourceTimer` object to prepare for deallocation.
    public func cleanupResources() {
        timer?.cancel()
    }
    
    func update() {
        guard let isCancelled = timer?.isCancelled, isCancelled == false else { return }
        let timestamp: TimeInterval = CFAbsoluteTimeGetCurrent()
        self.delegate?.tempoBeatUpdate(timestamp)
    }
    
}
