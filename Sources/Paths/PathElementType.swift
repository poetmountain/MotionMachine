//
//  PathElementType.swift
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

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
/// An enum representing types of path elements, used in defining animation along the path.
public enum PathElementType {

    /// The path element that starts a new subpath. The element holds a single point for the destination.
    case move(to: CGPoint)

    /// The path element that adds a line from the current point to a new point. The element holds a single point for the destination.
    case addLine(to: CGPoint)

    /// The path element that adds a quadratic curve from the current point to the specified point. The element holds a control point and a destination point.
    case addQuadCurve(CGPoint, to: CGPoint)

    /// The path element that adds a cubic curve from the current point to the specified point. The element holds two control points and a destination point.
    case addCurve(CGPoint, CGPoint, to: CGPoint)

    /// The path element that closes and completes a subpath. The element does not contain any points.
    case closeSubpath
    
    /// An unknown type (should only happen if Apple adds a new element type some day).
    case unknown
    
    /// Initializer.
    /// - Parameter element: The path element to represent.
    public init(element: CGPathElement) {
        switch element.type {
        case .moveToPoint:
            self = .move(to: element.points[0])
        case .addLineToPoint:
            self = .addLine(to: element.points[0])
        case .addQuadCurveToPoint:
            self = .addQuadCurve(element.points[0], to: element.points[1])
        case .addCurveToPoint:
            self = .addCurve(element.points[0], element.points[1], to: element.points[2])
        case .closeSubpath:
            self = .closeSubpath
        @unknown default:
            self = .unknown
        }
    }
}
#endif
