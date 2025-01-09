//
//  BezierPath+Extensions.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

// This file based on MIT-licensed code at: https://github.com/louisdh/bezierpath-length
// MIT License
//
// Copyright (c) 2016 Louis D'hauwe
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
public extension PathState {
    
    /// Returns a point on the path, given a percentage representing the length of the path from 0.0 to 1.0.
    /// - Parameters:
    ///   - percent: The percentage along the path from 0.0 to 1.0. Values provided outside of that range will return without a point.
    ///   - elements: The path elements used in determining the location on the path.
    /// - Returns: A point along the path, if one was found.
    internal func point(at percent: CGFloat, with elements: [PathElement]) -> CGPoint? {

        if percent < 0.0 || percent > 1.0 {
            return nil
        }

        let percentLength = self.length * percent
        
        var lengthTraversed: CGFloat = 0

        var firstPointInSubpath: CGPoint?

        /// Holds current point on the path (must never be a control point)
        var currentPoint: CGPoint?

        for pathElement in elements {
            
            switch(pathElement.type) {
            case let .move(to: p0):
                currentPoint = p0

                if firstPointInSubpath == nil {
                    firstPointInSubpath = p0
                }

                break

            case let .addLine(to: p1):

                guard let p0 = currentPoint else {
                    assertionFailure("Expected current point")
                    break
                }

                let l = linearLength(p0: p0, p1: p1)

                if lengthTraversed + l >= percentLength {

                    let lengthInSubpath = percentLength - lengthTraversed

                    let t = lengthInSubpath / l
                    return linearPoint(t: t, p0: p0, p1: p1)

                }

                lengthTraversed += l

                currentPoint = p1

                break

            case let .addQuadCurve(c1, to: p1):

                guard let p0 = currentPoint else {
                    assertionFailure("Expected current point")
                    break
                }

                let l = quadCurveLength(p0: p0, c1: c1, p1: p1)

                if lengthTraversed + l >= percentLength {

                    let lengthInSubpath = percentLength - lengthTraversed

                    let t = lengthInSubpath / l
                    return quadCurvePoint(t: t, p0: p0, c1: c1, p1: p1)

                }

                lengthTraversed += l

                currentPoint = p1

                break

            case let .addCurve(c1, c2, to: p1):

                guard let p0 = currentPoint else {
                    assertionFailure("Expected current point")
                    break
                }

                let l = cubicCurveLength(p0: p0, c1: c1, c2: c2, p1: p1)

                if lengthTraversed + l >= percentLength {

                    let lengthInSubpath = percentLength - lengthTraversed

                    let t = lengthInSubpath / l
                    return cubicCurvePoint(t: t, p0: p0, c1: c1, c2: c2, p1: p1)

                }

                lengthTraversed += l

                currentPoint = p1

                break

            case .closeSubpath:

                guard let p0 = currentPoint else {
                    break
                }

                if let p1 = firstPointInSubpath {

                    let l = linearLength(p0: p0, p1: p1)

                    if lengthTraversed + l >= percentLength {

                        let lengthInSubpath = percentLength - lengthTraversed

                        let t = lengthInSubpath / l
                        return linearPoint(t: t, p0: p0, p1: p1)

                    }

                    lengthTraversed += l

                    currentPoint = p1

                }

                firstPointInSubpath = nil

                break
                    
            case .unknown:
                break
            }

        }

        return nil
    }

    
    /// Calculates the length of the path based on the provided path elements.
    /// - Parameter elements: Path elements used to calculate the total path length.
    /// - Returns: The length of the path.
    func calculateLength(with elements: [PathElement]) -> CGFloat {

        var firstPointInSubpath: CGPoint?

        /// Holds current point on the path (must never be a control point)
        var currentPoint: CGPoint?

        var length: CGFloat = 0

        for element in elements {

            switch(element.type) {
            case let .move(to: p0):
                currentPoint = p0

                if firstPointInSubpath == nil {
                    firstPointInSubpath = p0
                }

                break

            case let .addLine(to: p1):

                guard let p0 = currentPoint else {
                    assertionFailure("Expected current point")
                    break
                }

                length += linearLength(p0: p0, p1: p1)

                currentPoint = p1

                break

            case let .addQuadCurve(c1, to: p1):

                guard let p0 = currentPoint else {
                    assertionFailure("Expected current point")
                    break
                }

                length += quadCurveLength(p0: p0, c1: c1, p1: p1)

                currentPoint = p1

                break

            case let .addCurve(c1, c2, to: p1):

                guard let p0 = currentPoint else {
                    assertionFailure("Expected current point")
                    break
                }

                length += cubicCurveLength(p0: p0, c1: c1, c2: c2, p1: p1)

                currentPoint = p1

                break

            case .closeSubpath:

                guard let p0 = currentPoint else {
                    break
                }

                if let p1 = firstPointInSubpath {

                    length += linearLength(p0: p0, p1: p1)

                    currentPoint = p1

                }

                firstPointInSubpath = nil

                break
                    
            case .unknown:
                break
            }

        }

        return length

    }

    // MARK: - Linear

    internal func linearLength(p0: CGPoint, p1: CGPoint) -> CGFloat {
        return p0.distance(to: p1)
    }

    internal func linearPoint(t: CGFloat, p0: CGPoint, p1: CGPoint) -> CGPoint {

        let x = linearValue(t: t, p0: p0.x, p1: p1.x)
        let y = linearValue(t: t, p0: p0.y, p1: p1.y)

        return CGPoint(x: x, y: y)
    }

    internal func linearValue(t: CGFloat, p0: CGFloat, p1: CGFloat) -> CGFloat {

        var value: CGFloat = 0.0

        // (1-t) * p0 + t * p1
        value += (1-t) * p0
        value += t * p1

        return value

    }

    // MARK: - Quadratic

    internal func quadCurveLength(p0: CGPoint, c1: CGPoint, p1: CGPoint) -> CGFloat {

        var approxDist: CGFloat = 0

        for i in 0..<curveLengthGenerationSteps {

            let t0 = CGFloat(i) / CGFloat(curveLengthGenerationSteps)
            let t1 = CGFloat(i+1) / CGFloat(curveLengthGenerationSteps)

            let a = quadCurvePoint(t: t0, p0: p0, c1: c1, p1: p1)
            let b = quadCurvePoint(t: t1, p0: p0, c1: c1, p1: p1)

            approxDist += a.distance(to: b)

        }

        return approxDist
    }

    internal func quadCurvePoint(t: CGFloat, p0: CGPoint, c1: CGPoint, p1: CGPoint) -> CGPoint {

        let x = quadCurveValue(t: t, p0: p0.x, c1: c1.x, p1: p1.x)
        let y = quadCurveValue(t: t, p0: p0.y, c1: c1.y, p1: p1.y)

        return CGPoint(x: x, y: y)

    }

    internal func quadCurveValue(t: CGFloat, p0: CGFloat, c1: CGFloat, p1: CGFloat) -> CGFloat {

        var value: CGFloat = 0.0

        // (1-t)^2 * p0 + 2 * (1-t) * t * c1 + t^2 * p1
        value += pow(1-t, 2) * p0
        value += 2 * (1-t) * t * c1
        value += pow(t, 2) * p1

        return value

    }

    // MARK: - Cubic

    internal func cubicCurveLength(p0: CGPoint, c1: CGPoint, c2: CGPoint, p1: CGPoint) -> CGFloat {

        var approxDist: CGFloat = 0

        for i in 0..<curveLengthGenerationSteps {

            let t0 = CGFloat(i) / CGFloat(curveLengthGenerationSteps)
            let t1 = CGFloat(i+1) / CGFloat(curveLengthGenerationSteps)

            let a = cubicCurvePoint(t: t0, p0: p0, c1: c1, c2: c2, p1: p1)
            let b = cubicCurvePoint(t: t1, p0: p0, c1: c1, c2: c2, p1: p1)

            approxDist += a.distance(to: b)

        }

        return approxDist

    }

    internal func cubicCurvePoint(t: CGFloat, p0: CGPoint, c1: CGPoint, c2: CGPoint, p1: CGPoint) -> CGPoint {

        let x = cubicCurveValue(t: t, p0: p0.x, c1: c1.x, c2: c2.x, p1: p1.x)
        let y = cubicCurveValue(t: t, p0: p0.y, c1: c1.y, c2: c2.y, p1: p1.y)

        return CGPoint(x: x, y: y)

    }

    internal func cubicCurveValue(t: CGFloat, p0: CGFloat, c1: CGFloat, c2: CGFloat, p1: CGFloat) -> CGFloat {

        var value: CGFloat = 0.0

        // (1-t)^3 * p0 + 3 * (1-t)^2 * t * c1 + 3 * (1-t) * t^2 * c2 + t^3 * p1
        value += pow(1-t, 3) * p0
        value += 3 * pow(1-t, 2) * t * c1
        value += 3 * (1-t) * pow(t, 2) * c2
        value += pow(t, 3) * p1

        return value
    }

}


extension CGPoint {

    func distance(to point: CGPoint) -> CGFloat {
        let a = self
        let b = point
        return hypot(a.x-b.x, a.y-b.y)
    }

}
#endif
