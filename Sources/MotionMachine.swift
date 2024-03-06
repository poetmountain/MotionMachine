//
//  MotionMachine.swift
//  MotionMachine
//
//  Created by Brett Walker on 4/19/16.
//  Copyright © 2016-2018 Poet & Mountain, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import CoreGraphics
import QuartzCore

// MARK: Moveable protocol

/**
 *  This protocol declares methods and properties that must be adopted by custom motion classes in order to participate in the MotionMachine ecosystem. All standard MotionMachine motion classes conform to this protocol.
 */
public protocol Moveable: AnyObject {
    
    // Controlling a motion
    
    /**
     *  Stops a motion that is currently moving. (required)
     *
     *  - remark: When this method is called, a motion should only enter a stopped state if it currently moving.
     */
    func stop()
    
    /**
     *  Starts a motion that is currently stopped. (required)
     *
     *  - remark: This method can be chained when initializing the object.
     *  - note: When this method is called, a motion should only start moving if it is stopped.
     *  - returns: A reference to the Moveable instance; used to method chain initialization methods when the Moveable instance is created.
     */
    @discardableResult func start() -> Self
    
    /**
     *  Pauses a motion that is currently moving. (required)
     *
     *  - remark: When this method is called, a motion should only enter a paused state if it is currently moving.
     */
    func pause()
    
    /**
     *  Resumes a motion that is currently paused. (required)
     *
     *  - remark: When this method is called, a motion should only resume moving if it is currently paused.
     */
    func resume()
    
    /**
     *  Resets a motion to its initial state. Custom classes implementing this method must reset all relevant properties, including `totalProgress`.  (required)
     *
     *  - remark: This method is used by `Moveable` collection classes to properly reset child motions for new movement cycles and when starting a motion again using the `start` method.
     */
    func reset()
    
    /**
     *  A `MotionState` enum which represents the current state of the motion operation. This state should be updated by the class implementing this protocol.
     */
    var motionState: MotionState { get }
    
    
    /**
     *  A Boolean which determines whether a motion operation, when it has moved to the ending value, should move from the ending value back to the starting value.
     *
     *  - remark: When set to `true`, the motion plays in reverse after completing a forward motion. In this state, a motion cycle represents the combination of the forward and reverse motions. The default value should be `false`.
     */
    var reversing: Bool { get set }
    
    
    /**
     *  A value between 0.0 and 1.0, which represents the current overall progress of a motion. This value should include all reversing and repeat motion cycles. (read-only)
     *
     */
    var totalProgress: Double { get }

    /**
     *  Provides a delegate for sending `MoveableStatus` updates from a `Moveable` object. This property is used by `Moveable` collection classes. Any custom `Moveable` classes must send status updates using this delegate.
     *
     *  - warning: This delegate is only used by `Moveable` objects to communicate with other `Moveable` objects. End-users should not assign their own delegate to this property. If you need status updates for a `Moveable` object, please use the provided callback closures.
     */
    var updateDelegate: MotionUpdateDelegate? { get set }
    

    // Updating a motion
    
    /**
     *  This method is called to prompt a motion class to update its current movement values.
     *
     *  - parameter currentTime: A timestamp that can be used in easing calculations.
     */
    func update(withTimeInterval currentTime: TimeInterval)
    
}


// MARK: MoveableCollection protocol

/**
 *  This protocol declares methods and properties that must be adopted by custom classes which control other `Moveable` classes in order to participate in the MotionMachine ecosystem. All standard MotionMachine collection classes (MotionSequence, MotionGroup) conform to this protocol.
 */
public protocol MoveableCollection {
    
    /**
     *  A `CollectionReversingMode` enum which defines the behavior of a `Moveable` class when its `reversing` property is set to `true`. In the standard MotionMachine classes only `MotionSequence` currently uses this property to alter its behavior, but they all propagate changes to this property down to their collection children.
     *
     *  - note: Though classes implementing this property don't need to alter their own behavior based on the value that is set, they do need to pass the value to all of its children which conform to this protocol.
     */
    var reversingMode: CollectionReversingMode { get set }
    
}


// MARK: PropertyCollection protocol

public protocol PropertyCollection: AnyObject {
    
    /**
     *  A collection of `PropertyData` instances.
     *
     */
    var properties: [PropertyData] { get }
}


// MARK: Additive protocol

/**
 *  This protocol declares methods and properties that must be adopted by custom `Moveable` classes who participate in additive animations with other MotionMachine classes.
 */
public protocol Additive: PropertyCollection {
    
    /**
     *  A Boolean which determines whether this Motion should change its object values additively. Additive animation allows multiple motions to produce a compound effect, creating smooth transitions and blends between different ending value targets. Additive animation is the default behavior for UIKit animations as of iOS 8 and is great for making user interface animations fluid and responsive. MotionMachine uses its own implementation of additive movement, so you can use additive motions on any supported object properties.
     *
     *   By default, each Additive object should apply a strong influence on the movement of a property towards its ending value. This means that two Additive objects with the same duration and moving the same object property to different ending values will fight, and the "winning" value will be the last Additive object to start its movement. If the durations or starting times are different, a transition between the values will occur. If you wish to create additive motions that apply weighted value updates, you can adjust the `additiveWeighting` property. Setting values to that property that are less than 1.0 will create compound additive motions that are blends of each Motion object's ending values.
     *
     *
     */
    var additive: Bool { get set }
    
    /**
     *  A weighting between 0.0 and 1.0 which is applied to this Motion's object value updates when it is using an additive movement. The higher the weighting amount, the more its additive updates apply to the properties being moved. A value of 1.0 will mean the motion will reach the specific `end` value of each `PropertyData` being moved, while a value of 0.0 will not move towards the `end` value at all. When multiple Motions in `additive` mode are moving the same object properties, adjusting this weighting on each Motion can create complex composite motions.
     *
     *  - note: This value only has an effect when `additive` is set to `true`.
     */
    var additiveWeighting: Double { get set }
    
    /**
     *  An operation ID is assigned to an Additive instance when it is moving an object's property and its motion operation is currently in progress. (read-only)
     *
     */
    var operationID: UInt { get }
    
}



// MARK: TempoDelegate protocol

/**
 *  This protocol defines methods that are called on delegate objects which listen for update beats from a `Tempo` object.
 */
public protocol TempoDelegate: AnyObject {
    
    /**
     *  Sends an update beat that should prompt motion classes to recalculate movement values.
     *
     *  - parameter timestamp: A timestamp by which motion classes can calculate new delta values.
     */
    func tempoBeatUpdate(_ timestamp: TimeInterval)
}


// MARK: TempoDriven protocol

/**
 *  This protocol represents objects that subscribe to a `Tempo` object's beats. Every movement of a value occurs because time has changed. These beats drive the motion, sending timestamps by which delta values can be calculated. All standard MotionMachine motion classes conform to this protocol.
 *
 *  - important: While you aren't required to implement this protocol in order to update your own custom `Moveable` classes, it is the preferred way to interact with the MotionMachine ecosystem unless your requirements prevent using `Tempo` objects for updating your value interpolations.
 */
public protocol TempoDriven: TempoDelegate {
    /**
     *  A concrete `Tempo` subclass that provides an update "beat" to drive a motion.
     *
     *  - note: It is expected that classes implementing this protocol also subscribe to the Tempo object's `TempoDelegate` delegate methods.
     */
    var tempo: Tempo? { get set }

    /**
     *  Tells a `TempoDriven` object to cease listening to updates from its `Tempo` object.
     *
     *  - seealso: tempo
     */
    func stopTempoUpdates()
}


// MARK: MotionUpdateDelegate protocol

/// This delegate protocol defines a status update method in order for `Moveable` objects to communicate with one another. MotionMachine collection classes use this protocol method to keep track of child motion status changes. Any custom `Moveable` classes must send `MoveableStatus` status updates using this protocol.
public protocol MotionUpdateDelegate: AnyObject {
    
    /**
     *  This delegate method is called when a `Moveable` object has updated its status.
     *
     *  - parameters:
     *      - mover: A `Moveable` object that calls this delegate method.
     *      - type: The type of status update being sent.
     */
    func motionStatusUpdated(forMotion motion: Moveable, updateType status: MoveableStatus)
    
}


// MARK: ValueAssistant protocol

/// This protocol defines methods and properties that must be adopted for any value assistant.
public protocol ValueAssistant {
    
    init()
    
    /**
     *  This method returns an array of PropertyData instances based on the values of the provided object.
     *
     *  - parameters:
     *      - object:   A supported object to generate PropertyData instances from.
     *      - path:     The base keyPath which points to the target object.
     *      - target:   The object whose properties should be modified.
     *
     *  - returns: An array of PropertyData instances representing the values of the provided object.
     */
    func generateProperties(targetObject target: AnyObject, propertyStates: PropertyStates) throws -> [PropertyData]
    
    /**
     *  This method replaces an element of an AnyObject subclass by assigning new values.
     *
     *  - parameters:
     *      - object:   The object that should be updated.
     *      - newValues:    A dictionary of keyPaths and associated values of the object to be updated.
     *
     *  - returns: An updated version of the object, if the object property was found and is supported.
     */
    func updateValue(inObject object: Any, newValues: Dictionary<String, Double>) -> NSObject?
    
    /**
     *  This method retrieves the current value of the target object being moved (as opposed to the saved value within a `PropertyData` instance).
     *
     *  - parameters:
     *      - property: The `PropertyData` instance whose target object's value should be queried.
     *
     *  - returns: The retrieved value of the target object.
     */
    func retrieveCurrentObjectValue(forProperty property: PropertyData) -> Double?
    
    /**
     *  This method retrieves the value of a supported AnyObject type.
     *
     *  - parameters:
     *      - object:   The object whose property value should be retrieved.
     *      - path:    The key path of the object property to be updated. If `object` is an NSValue instance, the path should correspond to an internal struct value path. E.g. a NSValue instance containing a NSRect might have a path property of "origin.x".
     *
     *  - returns: The retrieved value, if the object property was found and is supported.
     */
    func retrieveValue(inObject object: Any, keyPath path: String) throws -> Double?
    
    /**
     *  This method calculates a new value an object property.
     *
     *  - parameters:
     *      - property:   The PropertyData instance whose property should be calculated.
     *      - newValue: The new value to be applied to the object property.
     *
     *  - returns: An updated version of the object, if the object property was found and is supported.
     */
    func calculateValue(forProperty property: PropertyData, newValue: Double) -> NSObject?

    
    /**
     *  Verifies whether this class can update the specified object type.
     *
     *  - parameters:
     *      - object: An object to verify support for.
     *
     *  - returns: A Boolean value representing whether the object is supported by this class.
     */
    func supports(_ object: AnyObject) -> Bool
    
    /**
     *  Verifies whether this object can accept a keyPath.
     *
     *  - parameters:
     *      - object: An object to verify support for.
     *
     *  - returns: A Boolean value representing whether the object is supported by this class.
     */
    func acceptsKeypath(_ object: AnyObject) -> Bool
    
    
    /**
     *  A Boolean which determines whether to update a value using additive updates. When the value is `true`, values passed in to `updateValue` are added to the existing value instead of replacing it. The default is `false`.
     *
     *  - seealso: additiveWeighting
     */
    var additive: Bool { get set }
    
    /**
     *  A weighting between 0.0 and 1.0 which is applied to a value updates when the ValueAssistant is updating additively. The higher the weighting amount, the more that a new value will be applied in the `updateValue` method. A value of 1.0 will apply the full value to the existing value, and a value of 0.0 will apply nothing to it.
     *
     *  - note: This value only has an effect when `additive` is set to `true`. The default value is 1.0.
     *  - seealso: additive
     */
    var additiveWeighting: Double { get set }
    
}

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
    
    func applyTo(value: inout Double, newValue: Double) {
        if (additive) {
            value += (newValue * additiveWeighting)
        } else {
            value = newValue
        }
        
    }
    
    func applyTo(value: inout CGFloat, newValue: CGFloat) {
        if (additive) {
            value += (newValue * CGFloat(additiveWeighting))
        } else {
            value = newValue
        }
    }
    
    func lastComponent(forPath path: String) -> String {
        let components = path.components(separatedBy: ".")
        return components.last!
    }
    
}

/// This error is thrown when a `ValueAssistant` receives the wrong type.
public enum ValueAssistantError : Error {
    
    case typeRequirement(String)
    
    public func printError(fromFunction function: String) {
        if (MMConfiguration.sharedInstance.printsErrors) {
            print("ERROR: ValueAssistantError.\(self) -- Incorrect type supplied from function \(function).")
        }
    }
    
}


// Taken from: https://gist.github.com/stephanecopin/c746993d7431ceaaee718a9a491a5cfa
/// Avoids retain cycles for Timers and CADisplayLinks
class WeakTarget: NSObject {
    private(set) weak var target: AnyObject?
    let selector: Selector

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



public final class MMConfiguration {
    public static let sharedInstance = MMConfiguration()
    
    public var printsErrors: Bool = true
    
    private init() {
    }
}



/// Any easing types used by a Motion object should implement this closure.
public typealias EasingUpdateClosure = (_ elapsedTime: TimeInterval, _ startValue: Double, _ valueRange: Double, _ duration: TimeInterval) -> Double


/// Enum representing the state of a motion operation.
public enum MotionState {
    /// The state of a motion operation when it is moving.
    case moving
    
    /// The state of a motion operation when it is stopped.
    case stopped
    
    /// The state of a motion operation when it is paused.
    case paused
    
    /// The state of a motion operation when it is delayed.
    case delayed
}


/// Enum representing the direction a motion is moving in.
public enum MotionDirection {
    /// The motion is moving in a forward direction, from the starting value to the ending value.
    case forward
    /// The motion is moving in a reverse direction, from the ending value to the starting value.
    case reverse
}



/// Enum representing possible status types being sent by a `Moveable` object to its `MotionUpdateDelegate` delegate.
public enum MoveableStatus {
    
    /// A `Moveable` object's motion operation has started.
    case started
    
    /// A `Moveable` object's motion operation has been stopped manually (when the stop() method is called) prior to completion.
    case stopped
    
    /**
     *  A `Moveable` object's motion operation has completed 50% of its total movement.
     *
     *  - remark: This status should only be sent when half of the activity related to the motion has ceased. For instance, if a `Moveable` class is set to repeat two times and its `reversing` property is set to `true`, it should send this status after the second reversal of direction.
     */
    case halfCompleted
    
    /**
     *  A `Moveable` object's motion operation has fully completed.
     *
     *  - remark: This status should only be posted when all activity related to the motion has ceased. For instance, if a `Moveable` class allows a movement to be repeated multiple times, this status should only be sent when all repetitions have finished.
     */
    case completed
    
    /// A `Moveable` object's motion operation has updated the properties it is moving.
    case updated
    
    /// A `Moveable` object's motion operation has reversed its movement direction.
    case reversed
    
    /// A `Moveable` object's motion operation has started a new repeat cycle.
    case repeated
    
    /// A `Moveable` object's motion operation has paused.
    case paused
    
    /// A `Moveable` object's motion operation has resumed.
    case resumed
    
    /// A `Moveable` object sequence collection (such as `MotionSequence`) when its movement has advanced to the next sequence step.
    case stepped
}

/**
 *  The mode used to define the movement behavior of sequence steps when the `reversing` property of a `MoveableCollection` is set to `true`.
 */
public enum CollectionReversingMode {
    
    /**
     *  Specifies that when the sequence's `motionDirection` property is `Reverse`, each sequence step will still move normally, but just in reverse order.
     *
     *  - remark: This mode is useful if you want sequence steps to move consistently, regardless of the state of the `motionDirection` property. For example, this mode would be chosen if you have a series of lights that should blink on and off in sequential order, and the only thing that should change is the order in which they blink.
     */
    case sequential
    
    /**
     *  Specifies that when the sequence's `motionDirection` property is `.Reverse`, all `Moveable` sequence steps will move in a reverse direction to their normal motion. That is, the values of each sequence step will move in reverse, and in reverse order, thus giving the effect that the whole sequence is fluidly moving in reverse. Additionally, when the sequence's `motionDirection` is `.Forward`, each sequence step will pause after completing their forward movement.
     *
     *  - remark: This mode is useful if you want to create a sequence whose sequence steps reverse in a mirror image of their forward motion. This is a really powerful way of making many separate animations appear to be a single, fluid animation when reversing.
     */
    case contiguous
    
}


/// An integer options set providing possible initialization options for a `Moveable` object.
public struct MotionOptions : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    /// No options are specified.
    public static let none                     = MotionOptions([])
    
    /// Specifies that a motion should repeat.
    public static let repeats                   = MotionOptions(rawValue: 1 << 0)
    
    /// Specifies that a motion should reverse directions after moving in the forward direction.
    public static let reverses                  = MotionOptions(rawValue: 1 << 1)
    
    /**
     *  Specifies that a motion's property (or parent, if property is not KVC-compliant) should be reset to its starting value on repeats or restarts.
     *
     *  - remark: `Motion` and `PhysicsMotion` are the only MotionMachine classes that currently accept this option.
     */
    public static let resetsStateOnRepeat       = MotionOptions(rawValue: 1 << 2)
}


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
