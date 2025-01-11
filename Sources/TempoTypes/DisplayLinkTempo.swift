//
//  DisplayLinkTempo.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// DisplayLinkTempo chooses the appropriate TempoProviding class to send tempo updates that are synchronized with the refresh rate of the display. On Mac, the ``MacDisplayLinkTempo`` class is used, and on other platforms the ``CATempo`` class is used. Both classes use `CADisplayLink`.
@MainActor public class DisplayLinkTempo: TempoProviding {
    
    public var delegate: (any TempoDelegate)? {
        get {
            return tempo?.delegate
        }
        set {
            tempo?.delegate = newValue
        }
    }
    
    public var tempo: TempoProviding?
    
    init() {
#if os(iOS) || os(tvOS) || os(visionOS)
        tempo = CATempo()
#elseif os(macOS)
        tempo = MacDisplayLinkTempo()
#else
        tempo = TimerTempo()
#endif
    }
    
    public func cleanupResources() {
        tempo?.cleanupResources()
    }
    
    
    
}
