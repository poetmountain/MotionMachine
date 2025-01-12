//
//  SequenceMotionView.swift
//  MotionSwiftUIExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

struct SequenceMotionView: View {
    
    @State private var motionState: SequenceMotionState?
    
    var body: some View {

        VStack(alignment: .center) {
            ZStack {
                if let motionState {
                    ForEach((0..<motionState.motionsCount), id: \.self) {
                        Circle()
                            .fill(Color(uiColor: motionState.colors[$0]))
                            .frame(width: motionState.circleWidth, height: motionState.circleWidth)
                            .position(CGPoint(x: motionState.points[$0].x, y: motionState.points[$0].y))
                    }
                }
            }
            .task {
                motionState = SequenceMotionState()
                motionState?.startMotion()
             }
        }
        .padding()
        
        .onDisappear {
            motionState?.stopMotion()
        }
    }
    

}

