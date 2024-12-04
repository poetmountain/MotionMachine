//
//  MotionMachine.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import CoreGraphics
import QuartzCore

// MARK: Moveable protocol

public extension Moveable {
    func cleanupResources() {}
}


// MARK: PropertyCollection protocol

/// This protocol represents an object that holds a collection of `PropertyData` objects, such as a ``Motion`` class.
@MainActor public protocol PropertyCollection: AnyObject {
    
    /**
     *  A collection of `PropertyData` instances.
     *
     */
    var properties: [PropertyData] { get }
}

// MARK: ValueAssistant protocol

public extension ValueAssistant {
    
    func retrieveCurrentObjectValue(forProperty property: PropertyData) -> Double? {
        
        guard let unwrapped_object = property.targetObject else { return nil }
        
        if let path_value = unwrapped_object.value(forKeyPath: property.parentKeyPath) {
            if let unwrapped_object = path_value as? NSObject {
                if let retrieved_value = try? retrieveValue(inObject: unwrapped_object, keyPath: property.path) {
                    return retrieved_value
                }
            }
        }
        
        return nil
    }
    
}

// utility methods for ValueAssistant
public extension ValueAssistant {
    
    
    /// Applies a new Double value to an existing one, either adding to it if ``additive`` mode is active, or simply replacing it.
    /// - Parameters:
    ///   - value: The Double value to modify.
    ///   - newValue: The Double value used to modify the existing value.
    func applyTo(value: inout Double, newValue: Double) {
        if (additive) {
            value += (newValue * additiveWeighting)
        } else {
            value = newValue
        }
        
    }
    
    /// Applies a new CGFloat value to an existing value, either adding to it if ``additive`` mode is active, or simply replacing it.
    /// - Parameters:
    ///   - value: The CGFloat value to modify.
    ///   - newValue: The CGFloat value used to modify the existing value.
    func applyTo(value: inout CGFloat, newValue: CGFloat) {
        if (additive) {
            value += (newValue * CGFloat(additiveWeighting))
        } else {
            value = newValue
        }
    }
    
    /// Returns the last component in a period-delimited String path.
    /// - Parameter path: The String path to search.
    /// - Returns: The path component, if one was found.
    func lastComponent(forPath path: String) -> String? {
        return path.components(separatedBy: ".").last
    }
    
    /// Returns the last two components in a period-delimited String path.
    /// - Parameter path: The String path to search.
    /// - Returns: An array of path components, if any were found.
    func lastTwoComponents(forPath path: String) -> [String]? {
        let components = path.components(separatedBy: ".")
        var val: [String]?
        if (components.count > 1) {
            let strings = components[components.count-2...components.count-1]
            val = Array(strings)
        }
        
        return val
    }
    
}

/// This error is thrown when a `ValueAssistant` receives the wrong type.
public enum ValueAssistantError : Error {
    
    /// Represents an error that an incorrect type was supplied.
    case typeRequirement(String)
    
    /// Prints an error statement.
    /// - Parameter function: The function where the error occurred.
    @MainActor public func printError(fromFunction function: String) {
        if (MMConfiguration.sharedInstance.printsErrors) {
            print("ERROR: ValueAssistantError.\(self) -- Incorrect type supplied from function \(function).")
        }
    }
    
}


// Taken from: https://gist.github.com/stephanecopin/c746993d7431ceaaee718a9a491a5cfa
/// Avoids retain cycles for Timers and CADisplayLinks
final class WeakTarget: NSObject {
    private(set) weak var target: AnyObject?
    let selector: Selector
    
    /// The selector to call when the timer updates.
    static let triggerSelector = #selector(WeakTarget.timerDidTrigger(parameter:))

    init(_ target: AnyObject, selector: Selector) {
        self.target = target
        self.selector = selector
    }

    @objc private func timerDidTrigger(parameter: Any) {
        _ = self.target?.perform(self.selector, with: parameter)
    }
}

extension Timer {
    convenience init(timeInterval ti: TimeInterval, weakTarget: AnyObject, selector: Selector, userInfo: Any?, repeats: Bool) {
        self.init(timeInterval: ti, target: WeakTarget(weakTarget, selector: selector), selector: WeakTarget.triggerSelector, userInfo: userInfo, repeats: repeats)
    }

    class func scheduledTimer(timeInterval ti: TimeInterval, weakTarget: AnyObject, selector: Selector, userInfo: Any?, repeats: Bool) -> Timer {
        return self.scheduledTimer(timeInterval: ti, target: WeakTarget(weakTarget, selector: selector), selector: WeakTarget.triggerSelector, userInfo: userInfo, repeats: repeats)
    }
}

extension CADisplayLink {
    convenience init(weakTarget: AnyObject, selector: Selector) {
        self.init(target: WeakTarget(weakTarget, selector: selector), selector: WeakTarget.triggerSelector)
    }
}


/// A singleton configuration class for MotionMachine.
@MainActor public final class MMConfiguration {
    public static let sharedInstance = MMConfiguration()
    
    /// A Boolean representing whether MotionMachine errors should be logged.
    public var printsErrors: Bool = true
    
    private init() {
    }
}



/// Any easing types used by a Motion object should implement this closure.
public typealias EasingUpdateClosure = (_ elapsedTime: TimeInterval, _ startValue: Double, _ valueRange: Double, _ duration: TimeInterval) -> Double


/// Represents an infinite number of repeat motion cycles.
public let REPEAT_INFINITE: UInt = 0

/// Utility methods
public struct MotionUtils {
    
    static let MM_PI_2 = Double.pi / 2
    
}


// MARK: - Utility extensions

// Extends Array to use Set's isDisjointWith to test for presence of Array members in the Set sequence
extension Array where Element: Hashable {
    func containsAny(_ set: Set<Element>) -> Bool {
        return !set.isDisjoint(with: self)
    }
}

/// Custom operators to do a "fuzzy" comparison of floating-point numbers.
/// The fuzzy equal character is created using the Option-X key combination.
/// see: http://stackoverflow.com/questions/4915462/how-should-i-do-floating-point-comparison
infix operator ≈≈ : ComparisonPrecedence

func ≈≈ (a: Float, b: Float) -> Bool {

    if (a == b) {
        return true
    }
    
    let fabs_a = abs(a)
    let fabs_b = abs(b)
    let diff = abs(fabs_a - fabs_b)
    
    if (a == 0.0 || b == 0.0 || diff < Float.leastNormalMagnitude) {
        // a or b is zero or both are extremely close to it
        // relative error is less meaningful here
        return diff < (Float.ulpOfOne * Float.leastNormalMagnitude)
    } else {

        return (diff / (fabs_a + fabs_b)) < Float.ulpOfOne
    }
}


func ≈≈ (a: Double, b: Double) -> Bool {
    if (a == b) {
        return true
    }
    
    let fabs_a = fabs(a)
    let fabs_b = fabs(b)
    let diff = fabs(fabs_a - fabs_b)
    
    if (a == 0.0 || b == 0.0 || diff < Double.leastNormalMagnitude) {
        // a or b is zero or both are extremely close to it
        // relative error is less meaningful here
        return diff < (Double.ulpOfOne * Double.leastNormalMagnitude)
    } else {
        return (diff / (fabs_a + fabs_b)) < Double.ulpOfOne
    }
    
}

/// Custom operators to do a "fuzzy" not-equal comparison of floating-point numbers.
/// The fuzzy equal character is created using the Option-X key combination.
/// see: http://stackoverflow.com/questions/4915462/how-should-i-do-floating-point-comparison
infix operator !≈ : ComparisonPrecedence

func !≈ (a: Float, b: Float) -> Bool {
    return !(a ≈≈ b)
   
}

func !≈ (a: Double, b: Double) -> Bool {
    return !(a ≈≈ b)
}


/// Extension to == operator to allow Moveable instances to be compared
func == (a: Moveable, b: Moveable) -> Bool {
    
    if (a === b) {
        return true
    }
    
    return false
}


extension CGPath {
    
    /// Introspects the path and returns all path elements as models.
    /// - Returns: An array of models representing this path's elements.
    public func pm_retrieveElements() -> [PathElement] {
        var points_on_path = [PathElement]()
        let bezierPoints = NSMutableArray()
        
        var firstPoint: CGPoint?
        var counter: Int = 0
        
        self.applyWithBlock { element in

            let points = element.pointee.points
            let type = element.pointee.type
            
            // we need to save the first point here so we can use it as the point of a closeSubpath type
            // (this was crashing on paths created from a CGRect)
            if counter == 0 {
                firstPoint = points.pointee
                counter += 1
            }
            
            let numberOfPoints: Int = {
                switch type {
                case .moveToPoint, .addLineToPoint: // contains 1 point
                    return 1
                case .addQuadCurveToPoint: // contains 2 points
                    return 2
                case .addCurveToPoint: // contains 3 points
                    return 3
                case .closeSubpath:
                    return 1
                @unknown default:
                    return 0
                }
            }()
            
            switch type {
            case .moveToPoint:
                bezierPoints.add([NSNumber(value: Float(points[0].x)), NSNumber(value: Float(points[0].y))])

            case .addLineToPoint:
                bezierPoints.add([NSNumber(value: Float(points[0].x)), NSNumber(value: Float(points[0].y))])

            case .addQuadCurveToPoint:
                bezierPoints.add([NSNumber(value: Float(points[0].x)), NSNumber(value: Float(points[0].y))])
                bezierPoints.add([NSNumber(value: Float(points[1].x)), NSNumber(value: Float(points[1].y))])

            case .addCurveToPoint:
                bezierPoints.add([NSNumber(value: Float(points[0].x)), NSNumber(value: Float(points[0].y))])
                bezierPoints.add([NSNumber(value: Float(points[1].x)), NSNumber(value: Float(points[1].y))])
                bezierPoints.add([NSNumber(value: Float(points[2].x)), NSNumber(value: Float(points[2].y))])

            case .closeSubpath:
                if let firstPoint {
                    bezierPoints.add([NSNumber(value: Float(firstPoint.x)), NSNumber(value: Float(firstPoint.y))])
                }
            @unknown default:
                break
            }
            
            var cgPoints = [CGPoint]()
            for index in 0..<(numberOfPoints) {
                if type != .closeSubpath {
                    let point = element.pointee.points[index]
                    cgPoints.append(point)
                } else if let firstPoint {
                    cgPoints.append(firstPoint)
                }
            }

            if (cgPoints.count > 0) {
                let elementType = PathElementType(element: element.pointee)
                let index = (numberOfPoints > 0) ? (numberOfPoints - 1) : numberOfPoints
                let pathElement = PathElement(type: elementType, point: cgPoints[index], controlPoints: cgPoints)
                points_on_path.append(pathElement)
            }
        }
        

        return points_on_path
    }
    
}
