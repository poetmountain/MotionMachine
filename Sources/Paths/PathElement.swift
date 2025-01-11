//
//  PathElement.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS) || os(watchOS)
/// This model represents a single path element in a path.
public struct PathElement {
    
    /// Represents the type of path element.
    let type: PathElementType
    
    /// A point along the path representing this element.
    var point: CGPoint
    
    /// The control points associated with this path element.
    var controlPoints: [CGPoint]
    
    /// Initializer.
    /// - Parameters:
    ///   - type: The type of path element.
    ///   - point: A point along the path representing this element.
    ///   - controlPoints: The control points associated with this path element.
    public init(type: PathElementType, point: CGPoint, controlPoints: [CGPoint]) {
        self.type = type
        self.point = point
        self.controlPoints = controlPoints
    }
}
#endif
