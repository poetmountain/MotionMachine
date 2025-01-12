//
//  PathMotionState.swift
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
@MainActor final class PathMotionState {
    var path: CGPath
    var motion: PathMotion?

    var point: CGPoint = .zero
    
    init(path: CGPath) {
        self.path = path
    }
    
    func startMotion() {
        setupMotion()
        motion?.start()
    }
    
    func stopMotion() {
        motion?.stop()
        motion = nil
    }
    
    private func setupMotion() {
        motion = PathMotion(path: path,
                        duration: 2.0,
                          easing: EasingQuadratic.easeInOut())
        motion?.reverses(withEasing: EasingQuartic.easeInOut())
        motion?.repeats()
        
        motion?.updated({ [weak self] (motion, currentPoint) in
            self?.point = currentPoint
        })
    }
}
