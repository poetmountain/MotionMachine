//
//  SequenceMotionState.swift
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
@MainActor final class SequenceMotionState {
    var points: [CGPoint] = []
    var colors: [UIColor] = []

    let circleWidth = 30.0
    let motionsCount = 5

    var sequence: MotionSequence? = MotionSequence(options: [.repeats, .reverses])
    
    init() {
        sequence?.reversingMode = .contiguous
                
        print("init sequence state")
    }
    
    func startMotion() {
        setupMotions()
        sequence?.start()
    }

    func stopMotion() {
        sequence?.stop()
        sequence = nil
    }
    
    func pauseMotion() {
        sequence?.pause()
    }
    
    func resumeMotion() {
        sequence?.resume()
    }

    func setupMotions() {
        let xSpacer = 15.0
        var xPosition = 20.0
        let yStart = 50.0
        let yEnd = 150.0
        
        let startColor = UIColor.systemGreen
        let endColor = UIColor.systemBlue
        
        for x in 0..<motionsCount {
            let newPoint = CGPoint(x: xPosition, y: yStart)
            points.append(newPoint)
            colors.append(startColor)
            
            let pointState = MotionState(keyPath: \SequenceMotionState.points[x], start: CGPoint(x: xPosition, y: yStart), end: CGPoint(x: xPosition, y: yEnd))
            let colorState = MotionState(keyPath: \SequenceMotionState.colors[x], start: startColor, end: endColor)
            
            let motion = Motion(target: self, states: pointState, colorState, duration: 0.6, easing: EasingQuadratic.easeInOut(), options: [.reverses])
            sequence?.add(motion)
            
            xPosition += circleWidth + xSpacer
        }
    }
}
