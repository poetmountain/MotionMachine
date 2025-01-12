//
//  AdditiveMotionView.swift
//  MotionSwiftUIExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

struct AdditiveMotionView: View {
    
    @State private var motionState: AdditiveMotionState?

    var body: some View {
        VStack(alignment: .leading) {
            if let motionState {
                ZStack(alignment: .top) {
                    HStack(alignment: .top) {
                        Circle()
                            .fill(Color(uiColor: .systemBlue))
                            .frame(width: motionState.circleWidth, height: motionState.circleWidth)
                            .position(CGPoint(x: motionState.currentPoint.x, y: motionState.currentPoint.y))
                        
                        Text("Tap to move the circle to that point.\nThe path will blend as you continue to tap in other locations.")
                            .font(.system(size: 12))
                            .frame(width: 300, height: 60, alignment: .center)
                            .position(CGPoint(x: 0, y: 25))
                            .multilineTextAlignment(.leading)
                            .padding([.trailing])
                                                                                
                    }
                }
            }
        }
        .background(Color(uiColor: .white))
        .onTapGesture { location in
            motionState?.addMotion(at: location)
        }
        .task {
            motionState = AdditiveMotionState()
         }

    }
}
