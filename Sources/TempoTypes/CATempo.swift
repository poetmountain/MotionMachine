//
//  CATempo.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/**
 *  CATempo uses a `CADisplayLink` object to send out tempo updates that are synchronized with the refresh rate of the display on iOS.
 */
@MainActor public class CATempo : Tempo {
    
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
    
    /// Calling this method invalides the `CADisplayLink` object to prepare for deallocation.
    public override func cleanupResources() {
        displayLink?.invalidate()

    }

    @objc func update() -> Void {
        let time_stamp: CFTimeInterval = self.displayLink?.timestamp ?? 0.0
        delegate?.tempoBeatUpdate(time_stamp)
    }
    
}
