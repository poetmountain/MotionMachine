//
//  MacDisplayLinkTempo.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

#if canImport(AppKit)
import AppKit
#endif

#if os(macOS)
/// This class uses a `CADisplayLink` object to send out tempo updates that are synchronized with the refresh rate of the currently-active Mac display.
@MainActor public class MacDisplayLinkTempo: TempoProviding {
    
    /**
     *  This `CADisplayLink` object is used to provide tempo updates.
     *
     *  - remarks: This class provides several mechanisms for adjusting the update rate. See the `CADisplayLink` documentation for more information.
     *
     *  - warning: Do not call the `addToRunLoop:forMode:`, `removeFromRunLoop:forMode:`, or `invalidate` methods on this object, as its state is handled by CATempo directly.
     */
    public var displayLink: CADisplayLink?
    
    public weak var delegate: TempoDelegate?

    
    /**
     *  Initializes a new `CATempo` object and adds the internal `CADisplayLink` object to the main run loop.
     *
     */
    public init() {
        
        displayLink = NSScreen.main?.displayLink(target: self, selector: #selector(update(sender:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Calling this method invalides the `CADisplayLink` object to prepare for deallocation.
    public func cleanupResources() {
        displayLink?.invalidate()

    }

    @objc func update(sender: CADisplayLink) -> Void {
        let timestamp: CFTimeInterval = self.displayLink?.timestamp ?? 0.0
        delegate?.tempoBeatUpdate(timestamp)
    }
    
}
#endif
