//
//  PathMotionView.swift
//  MotionSwiftUIExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

struct PathMotionView: View {
    
    @State private var motionState: PathMotionState?
    
    var body: some View {
        HStack(alignment: .top) {
            Spacer()
            VStack(alignment: .center) {
                if let motionState {
                    Path(motionState.path)
                        .stroke(.black, lineWidth: 2.0)
                        .frame(width: 200, height: 200)
                        .alignmentGuide(HorizontalAlignment.center) { _ in 150 }
                    
                    VStack {
                        Circle()
                            .fill(Color(uiColor: .systemBlue))
                            .frame(width: 15, height: 15)
                            .position(motionState.point)
                            .offset(CGSize(width: 0, height: -208))
                            .alignmentGuide(HorizontalAlignment.center) { _ in 150 }
                        
                    }
                    .frame(width: 200, height: 200)
                }
            }
            .task {
                let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
                path.addQuadCurve(to: CGPoint(x: 20, y: 50), controlPoint: CGPoint(x: 100, y: 45))
                
                motionState = PathMotionState(path: path.cgPath)
                motionState?.startMotion()
             }
            
            Spacer()

        }
        
        Spacer()
        
        VStack {
            HStack {
                Button {
                    motionState?.pauseMotion()
                } label: {
                    Text("Pause")
                }
                .padding()
                
                Button {
                    motionState?.resumeMotion()
                } label: {
                    Text("Resume")
                }
                .padding()
            }
        }
        .padding()
        
        .onDisappear {
            motionState?.stopMotion()
        }
    }
    
}
