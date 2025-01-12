//
//  AdditiveMotionState.swift
//  MotionSwiftUIExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import MotionMachine

@Observable
@MainActor final class AdditiveMotionState {
    var points: [CGPoint] = []

    let circleWidth = 30.0
    
    var currentPoint: CGPoint = CGPoint(x: 50, y: 25)
    
    var motions: [MotionGroup] = []
    
    func startMotion() {
        
    }

    func stopMotion() {
        motions.forEach { motion in
            motion.stop()
        }
        motions.removeAll()
    }
    
    func addMotion(at point: CGPoint) {
        print("adding motion ending at \(point)")
        points.append(point)
        
        let pointX = PropertyData(keyPath: \AdditiveMotionState.currentPoint.x, start: currentPoint.x, end: point.x)
        let pointY = PropertyData(keyPath: \AdditiveMotionState.currentPoint.y, start: currentPoint.y, end: point.y)
        let duration = 1.6
        
        let motionX = Motion(target: self, properties: [pointX], duration: duration, easing: EasingQuadratic.easeInOut(), options: [.additive])
        let motionY = Motion(target: self, properties: [pointY], duration: duration, easing: EasingQuadratic.easeInOut(), options: [.additive])
        
        let group = MotionGroup(motions: [motionX, motionY])
        
        group.completed { [weak self] group in
            guard let strongSelf = self else { return }
            strongSelf.motions.removeAll(where: { $0.id == group.id })
        }
        motions.append(group)
        
        group.start()
    }
}
