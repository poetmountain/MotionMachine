//
//  PathState.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import CoreGraphics

/// This state object is used in conjunction with ``PathMotion`` to handle the movement of a point along a path.
public final class PathState: NSObject, @unchecked Sendable {

    /// A point representing the current location along the path during an animation.
    public private(set) var currentPoint: CGPoint = .zero
    
    /// The percentage complete of the animation along the path. This property is used by the containing ``PathMotion`` instance to drive the path animation, and should not be modified directly. Values range from 0.0 to 1.0.
    @objc public var percentageComplete: Double = 0.0
    
    /// Returns the length of the path.
    public var length: CGFloat = 0.0
    
    /// An array containing pre-calculated points on the path that are used to animate along it, allowing large performance gains compared to looking up points on the path in real-time.
    public private(set) var lookupTable = [CGPoint]()
    
    /// This value is multiplied by the length of the path to determine how many points are generated in the lookup table. The default value is 2, which gives double the number of points for the path's length and avoids jitter in most cases.
    ///
    /// > Note: In large paths increasing this number can have significant increases in the lookup table generation time. For animating visual properties, the default value should be enough in most cases.
    public var lookupTablePrecision: Int = 2
    
    /// An array of models representing the segments of the path.
    public private(set) var pathElements = [PathElement]()
    
    /// The `CGPath` instance to animate along.
    public private(set) var path: CGPath
    
    /// This enum defines the behavior a motion takes when at an edge of the path. The default value is `stopAtEdges`.
    internal var edgeBehavior: PathEdgeBehavior = .stopAtEdges
        
    /// This value specifies the number of steps used in determining a curve's length. Higher values increase precision of the length calculation, but at a performance cost when a lookup table is not used. The default value is 5. This value can be changed in the initializer.
    private(set) var curveLengthGenerationSteps: Int = 5
    
    /// A dispatch queue used to generate the path lookup table off of the main thread.
    private let accessQueue: DispatchQueue = DispatchQueue(label: "com.poetmountain.motionmachine.lookuptable", qos: .userInitiated)
    
    /// Internal property which denotes whether performance mode is active and the lookup table should be used.
    private var shouldUseLookupTable: Bool = false
    
    /// An internal property specifying the maximum number of points to calculate for the lookup table.
    private var lookupTableCapacity: Int = 1
    
    
    /// An initializer.
    /// - Parameters:
    ///   - path: The path to animate along.
    ///   - curveLengthGenerationSteps: Determines the number of steps used in determining the lengths of curves. The default value of `50` is fine in most cases; higher values can marginally increase accuracy, at the cost of performance.
    init(path: CGPath, curveLengthGenerationSteps: Int? = nil) {
        self.path = path
        super.init()

        if let curveLengthGenerationSteps {
            self.curveLengthGenerationSteps = curveLengthGenerationSteps
        }
        
        buildPathElements()
        
        length = calculateLength(with: pathElements)
    }
    

    /// Moves the animation point to a place on the path specified by the percentage value.
    /// - Parameters:
    ///   - percentage: A percentage value from 0.0 to 1.0 which represents a position on the path.
    public func movePoint(to percentage: Double, startEdge: Double? = nil, endEdge: Double? = nil) {
        
        var adjustedPercentage: Double = percentage
        let start = startEdge ?? 0.0
        let end = endEdge ?? 1.0
        
        switch edgeBehavior {
            case .stopAtEdges:
                // we can start moving at start of path or end of path, so handle both cases here
                if (end > start) {
                    adjustedPercentage = min(max(percentage, start), end)
                } else {
                    adjustedPercentage = min(max(percentage, end), start)
                }
            case .contiguousEdges:
                if (percentage > 1.0) {
                    adjustedPercentage = min(percentage, 2.0) - 1.0
                } else if (percentage < 0.0) {
                    adjustedPercentage = abs(max(percentage, -2.0) + 1.0)
                }
        }
                
        let point = (shouldUseLookupTable) ? lookupPoint(at: adjustedPercentage) : self.point(at: adjustedPercentage)
        if let point {
            self.currentPoint = point
        }
    }

    /// Returns a point on the lookup table corresponding to a current percentage along the path.
    /// - Parameter percentage: A value representing a current placement along the path. This normal value range is 0.0 to 1.0, but may overshoot in either direction.
    /// - Returns: A point in the lookup table corresponding to the specified path location, if one was found.
    public func lookupPoint(at percentage: Double) -> CGPoint? {
        guard lookupTable.count > 0 else { return nil }
                
        let maxIndex = lookupTable.count - 1
        
        let index = Int(floor(Double(maxIndex) * percentage))
        
        if (index < lookupTable.count && index >= 0) {
            return lookupTable[index]
        } else {
            return nil
        }
        
    }
    

    /// Sets up performance mode, generating an internal lookup table for faster position calculations. To use the performance mode, this method must be used before calling `start()` on a ``PathMotion``.
    ///
    /// > Note: With large paths, the lookup table generation could take a second or longer to complete. Be aware that the lookup table generation runs synchronously on another dispatch queue, blocking the return of this async call until the generation has completed. Be sure to call this method as early as possible to give the operation time to complete before your ``PathMotion`` needs to begin.
    /// - Parameter lookupCapacity: An optional capacity that caps the maximum lookup table amount.
    public func setupPerformanceMode(lookupCapacity: Int? = nil) async {
        if let lookupCapacity {
            self.lookupTableCapacity = lookupCapacity
        }
        self.length = self.calculateLength(with: pathElements)
        print("MotionMachine: Calculated length of path: \(length)")
        lookupTableCapacity = lookupCapacity ?? Int(Double(length) * Double(lookupTablePrecision))
        
        shouldUseLookupTable = true

        await self.generateLookupTable()

    }
    
    
    /// Builds model objects for every path element.
    private func buildPathElements() {
        pathElements.removeAll()
        let elements = path.pm_retrieveElements()
        pathElements.append(contentsOf: elements)
    }
    
    /// Generates a lookup table of points along the path. This yields significant performance gains compared to manually calculating each point location in real-time.
    private func generateLookupTable() async {
        
        await withCheckedContinuation { continuation in
            
            lookupTable.removeAll()
            let lookupCapacity = self.lookupTableCapacity
            lookupTable.reserveCapacity(lookupCapacity)
            
            //let startTest = Date().timeIntervalSince1970
            
            accessQueue.sync(flags: .barrier) { [weak self] in
                for x in 0..<lookupCapacity {
                    
                    let percentage = Double(x) / Double(lookupCapacity)
                    if let point = self?.point(at: percentage) {
                        self?.lookupTable.append(point)
                    }
                }
                            
            }
            
//            let endTest = Date().timeIntervalSince1970
//            let diff = endTest - startTest
//            let diffString = String(format: "%.12f", arguments: [diff])
//            print("elapsed time \(diffString) :: table count \(lookupTable.count)")
                        
            continuation.resume()
        }
        


    }
    
    /// Returns a point on the path, given a percentage representing the length of the path from 0.0 to 1.0.
    ///
    /// - Parameter percent: The percentage along the path from 0.0 to 1.0. Values provided outside of that range will return without a point.
    /// - Returns: A point along the path, if one was found.
    public func point(at percent: CGFloat) -> CGPoint? {
        return point(at: percent, with: pathElements)
    }
    
}

