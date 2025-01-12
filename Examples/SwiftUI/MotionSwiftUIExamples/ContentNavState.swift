//
//  ContentNavState.swift
//  MotionSwiftUIExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

struct ContentNavState: Identifiable, Equatable, Hashable {
    enum NavType: String {
        case basic
        case sequence
        case additive
        case path
        
        func title() -> String {
            switch self {
                case .basic:
                    return "Basic Motion"
                case .sequence:
                    return "Sequence Motion"
                case .additive:
                    return "Additive Motion"
                case .path:
                    return "Path Motion"
            }
        }
    }
    
    let id = UUID()
    
    var type: NavType
}
