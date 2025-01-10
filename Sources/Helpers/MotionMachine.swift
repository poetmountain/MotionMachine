//
//  MotionMachine.swift
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

#if canImport(QuartzCore)
import QuartzCore
#endif


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

#if os(iOS) || os(tvOS) || os(visionOS)
// Taken from: https://gist.github.com/stephanecopin/c746993d7431ceaaee718a9a491a5cfa
/// Avoids retain cycles for CADisplayLinks
final class WeakTarget {
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
#endif


#if os(iOS) || os(tvOS) || os(visionOS)
extension CADisplayLink {
    convenience init(weakTarget: AnyObject, selector: Selector) {
        self.init(target: WeakTarget(weakTarget, selector: selector), selector: WeakTarget.triggerSelector)
    }
}
#endif

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
    
    let fabs_a = abs(a)
    let fabs_b = abs(b)
    let diff = abs(fabs_a - fabs_b)
    
    if (a == 0.0 || b == 0.0 || diff < Double.leastNormalMagnitude) {
        // a or b is zero or both are extremely close to it
        // relative error is less meaningful here
        return diff < (Double.ulpOfOne * Double.leastNormalMagnitude)
    } else {
        return (diff / (fabs_a + fabs_b)) < Double.ulpOfOne
    }
    
}

func ≈≈ (a: any BinaryFloatingPoint, b: any BinaryFloatingPoint) -> Bool {
    guard let doubleA = Double(exactly: a), let doubleB = Double(exactly: b) else { return false }
    
    if (doubleA == doubleB) {
        return true
    }
    
    let abs_a = abs(doubleA)
    let abs_b = abs(doubleB)
    let diff = abs(abs_a - abs_b)
    
    if (doubleA == 0.0 || doubleB == 0.0 || diff < Double.leastNormalMagnitude) {
        // a or b is zero or both are extremely close to it
        // relative error is less meaningful here
        return diff < (Double.ulpOfOne * Double.leastNormalMagnitude)
    } else {
        return (diff / (abs_a + abs_b)) < Double.ulpOfOne
    }
    
}

func ≈≈ (a: any SIMDScalar, b: any SIMDScalar) -> Bool {
    let doubleA = a.toDouble()
    let doubleB = b.toDouble()
    
    if (doubleA == doubleB) {
        return true
    }
    
    let abs_a = abs(doubleA)
    let abs_b = abs(doubleB)
    let diff = abs(abs_a - abs_b)
    
    if (doubleA == 0.0 || doubleB == 0.0 || diff < Double.leastNormalMagnitude) {
        // a or b is zero or both are extremely close to it
        // relative error is less meaningful here
        return diff < (Double.ulpOfOne * Double.leastNormalMagnitude)
    } else {
        return (diff / (abs_a + abs_b)) < Double.ulpOfOne
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

func !≈ (a: any BinaryFloatingPoint, b: any BinaryFloatingPoint) -> Bool {
    return !(a ≈≈ b)
}

func !≈ (a: any SIMDScalar, b: any SIMDScalar) -> Bool {
    return !(a ≈≈ b)
}

/// Extension to == operator to allow Moveable instances to be compared
func == (a: Moveable, b: Moveable) -> Bool {
    
    if (a === b) {
        return true
    }
    
    return false
}

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)
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
#endif

public extension BinaryFloatingPoint {
    /// Returns a Double value for this `BinaryFloatingPoint` object; either a precise conversion, or an approximate conversion if an exact one isn't available for this type.
    /// - Returns: A Double value, if one could be converted.
    func toDouble() -> Double? {
        return Double(exactly: self) ?? Double(self)
    }

    func toScalar<ScalarType: SIMDScalar>(type: ScalarType) -> ScalarType? {
        if (ScalarType.self == Float.self) {
            return Float(self) as? ScalarType
        } else if (ScalarType.self == Double.self) {
            return Double(self) as? ScalarType
        } else if (ScalarType.self == Float16.self) {
            return Float16(self) as? ScalarType
            
        } else if (ScalarType.self == Int.self) {
            return Int(self) as? ScalarType
        } else if (ScalarType.self == Int16.self) {
            return Int16(self) as? ScalarType
        } else if (ScalarType.self == Int32.self) {
            return Int32(self) as? ScalarType
        } else if (ScalarType.self == Int64.self) {
            return Int64(self) as? ScalarType
        } else if (ScalarType.self == Int8.self) {
            return Int8(self) as? ScalarType
            
        } else if (ScalarType.self == UInt.self) {
            return UInt(self) as? ScalarType
        } else if (ScalarType.self == UInt8.self) {
            return UInt8(self) as? ScalarType
        } else if (ScalarType.self == UInt16.self) {
            return UInt16(self) as? ScalarType
        } else if (ScalarType.self == UInt32.self) {
            return UInt32(self) as? ScalarType
        } else if (ScalarType.self == UInt64.self) {
            return UInt64(self) as? ScalarType
        }
        
        return nil
    }

}

public extension BinaryInteger {
    /// Returns a Double value for this `BinaryInteger` object.
    /// - Returns: A Double value, if one could be converted.
    func toDouble() -> Double? {
        return Double(self)
    }
    
    func toScalar<ScalarType: SIMDScalar>(type: ScalarType) -> ScalarType? {
        if (ScalarType.self == Int.self) {
            return Int(self) as? ScalarType
        } else if (ScalarType.self == Int16.self) {
            return Int16(self) as? ScalarType
        } else if (ScalarType.self == Int32.self) {
            return Int32(self) as? ScalarType
        } else if (ScalarType.self == Int64.self) {
            return Int64(self) as? ScalarType
        } else if (ScalarType.self == Int8.self) {
            return Int8(self) as? ScalarType
            
        } else if (ScalarType.self == UInt.self) {
            return UInt(self) as? ScalarType
        } else if (ScalarType.self == UInt8.self) {
            return UInt8(self) as? ScalarType
        } else if (ScalarType.self == UInt16.self) {
            return UInt16(self) as? ScalarType
        } else if (ScalarType.self == UInt32.self) {
            return UInt32(self) as? ScalarType
        } else if (ScalarType.self == UInt64.self) {
            return UInt64(self) as? ScalarType
        }
        
        return nil
    }
}



public extension SIMDScalar {
    
    func toDouble() -> Double {
        
        if let value = self as? Float {
            return Double(value)
            
        } else if let value = self as? Double {
            return value

        } else if let value = self as? Float16 {
            return Double(value)
            
        } else if let value = self as? Int {
            return Double(value)
        } else if let value = self as? Int16 {
            return Double(value)
        } else if let value = self as? Int32 {
            return Double(value)
        } else if let value = self as? Int64 {
            return Double(value)
        } else if let value = self as? Int8 {
            return Double(value)
            
        } else if let value = self as? UInt {
            return Double(value)
        } else if let value = self as? UInt8 {
            return Double(value)
        } else if let value = self as? UInt16 {
            return Double(value)
        } else if let value = self as? UInt32 {
            return Double(value)
        } else if let value = self as? UInt64 {
            return Double(value)
        } else {
            return 0
        }
        
    }
    

}

// Workaround for deficiency in Swift's handling of optional KeyPaths
// see: https://forums.swift.org/t/crash-during-optional-key-path-access-what-is-going-on/69141
public extension Optional {
    // Produce the `default` value if `self` is nil.
    subscript(default value: Wrapped) -> Wrapped {
        get { return self ?? value }
        set { self = newValue }
    }

    // Act like optional chaining on read, while allowing "writes" that drop
    // the value on the floor if `self` is nil.
    subscript<T>(droppingWritesOnNil path: WritableKeyPath<Wrapped, T>) -> T? {
        get { return self?[keyPath: path] }
        set {
            if let newValue = newValue {
                self?[keyPath: path] = newValue
            }
        }
    }
}

