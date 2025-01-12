//
//  BasicMotionState.swift
//  MotionSwiftUIExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import UIKit
import MotionMachine

@Observable
@MainActor final class BasicMotionState {
    var size: CGSize = .zero
    var color: UIColor = .blue
    
    var motion: Motion<BasicMotionState>?
    
    func startMotion() {
        setupMotion()
        motion?.start()
    }
    
    func stopMotion() {
        motion?.stop()
        motion = nil
    }
    
    private func setupMotion() {
        let sizeState = MotionState(keyPath: \BasicMotionState.size, start: CGSize(width: 50, height: 50), end: CGSize(width: 200, height: 200))
        let colorState = MotionState(keyPath: \BasicMotionState.color, end: UIColor.magenta)
        motion = Motion(target: self, states: sizeState, colorState, duration: 1.5, easing: EasingBack.easeInOut(), options: [.repeats, .reverses])
    }

}
