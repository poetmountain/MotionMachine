//
//  BasicMotionView.swift
//  MotionSwiftUIExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

struct BasicMotionView: View {
    
    @State private var motionState: BasicMotionState?
    
    var body: some View {

        VStack {
            if let motionState {
                GeometryReader { proxy in
                    Circle()
                        .fill(Color(uiColor: motionState.color))
                        .frame(width: motionState.size.width, height: motionState.size.height)
                        .position(CGPoint(x: proxy.size.width/2, y: 100))
                }
                
            }
        }
        .padding()
        .task {
            motionState = BasicMotionState()
            motionState?.startMotion()
         }
        
        .onDisappear {
            motionState?.stopMotion()
        }
    }
}
