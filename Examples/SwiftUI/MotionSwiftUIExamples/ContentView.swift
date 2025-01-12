//
//  ContentView.swift
//  MotionSwiftUIExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

struct ContentView: View {
    @State private var navItems: [ContentNavState] = [ContentNavState(type: .basic), ContentNavState(type: .sequence), ContentNavState(type: .additive), ContentNavState(type: .path)]

    var body: some View {
        
        VStack {
            NavigationStack {
                List(navItems) { item in
                    NavigationLink(item.type.title(), value: item)
                }
                .navigationDestination(for: ContentNavState.self) { item in
                    switch item.type {
                        case .basic:
                            BasicMotionView()
                        case .sequence:
                            SequenceMotionView()
                        case .additive:
                            AdditiveMotionView()
                        case .path:
                            PathMotionView()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                 .toolbar {
                     ToolbarItem(placement: .principal) {
                         VStack {
                             Text("SwiftUI Examples").font(.headline)
                         }
                     }
                 }
            }
        }
    }
}

#Preview {
    ContentView()
}
