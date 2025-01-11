![MotionMachine logo](Guides/mmlogo.png)

![swift](https://img.shields.io/badge/Swift-6.0-005AA5.svg)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20visionOS%20%7C%20watchOS%20%7C%20tvOS-005AA5.svg) ![license](https://img.shields.io/badge/license-MIT-005AA5.svg)

MotionMachine provides a modular, powerful, and generic platform for manipulating values, whether that be animating UI elements or interpolating property values in your own classes. It offers sensible default functionality that abstracts most of the hard work away, allowing you to focus on your work. While it is type-agnostic, MotionMachine does support most major Apple platform types as object states out of the box and provides syntactic sugar to easily manipulate them. But it's also easy to dive in and modify for your own needs, whether that be custom motion classes, supporting custom value types, or new easing equations.

* Animation engine built from the ground up (not tied to Core Animation).
* Animate system properties, UI elements, or any generic classes using many easing equations.
* Provides static and physics-based motion classes to modifying multiple property values, and both support additive animation.
* Provides static and physics-based motion classes that can animate a `CGPoint` along a `CGPath`, even part of a path.
* All motion classes can be grouped, sequenced, and nested in any arrangement and have reversing and repeating actions applied at any level.
* Powerfully modular – most aspects can be customized or outright replaced to fit your specific needs.
* Provides status callback closures for many types of motion events.
* Fully tested
* Fully [documented](https://poetmountain.github.io/MotionMachine/)


## Getting Started

#### Get started with the **[Motion Classes guide](Guides/MoveableClasses.md)** for detailed explanations and examples.

If you're upgrading from a previous version of MotionMachine, check out the [3.0 Migration Guide](Guides/MigrationGuide3.0.md) for breaking changes.

Also check out the [Examples project](Examples) to see all the MotionMachine classes in action, or dive deep into the source [Documentation](https://poetmountain.github.io/MotionMachine/).

## Introduction
![MotionGroup animation](Guides/group.gif)

This complex animation was created with the code sample below. These `Motion` classes animate the NSLayoutConstraints of the circle views as well as one of their `backgroundColor` properties. A `MotionGroup` object is used to synchronize the four `Motion` objects and reverse their movements.
```swift
let group = MotionGroup(options: [.reverses])

.add(Motion(target: circleViewXConstraint,
        properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, end: 200.0)],
          duration: 1.0,
            easing: EasingQuartic.easeInOut()))

.add(Motion(target: circleViewYConstraint,
        properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, end: 250.0)],
          duration: 1.4,
            easing: EasingElastic.easeInOut()))

.add(Motion(target: circleView,
            states: MotionState(keyPath: \UIView.backgroundColor[default: .black], end: .systemBlue),
          duration: 1.2,
            easing: EasingQuartic.easeInOut()))

let circle2Motion = secondCircleXConstraint,
        properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, end: 300.0)],
          duration: 1.2,
            easing: EasingQuadratic.easeInOut())
.reverses(withEasing: EasingQuartic.easeInOut())
circle2Motion.reverseEasing = EasingQuartic.easeInOut()
group.add(circle2Motion)

group.start()
```


#### How does this work?

All of the included motion classes in MotionMachine adopt the `Moveable` protocol, which enables them to work seamlessly together. By using the `MotionGroup` and `MotionSequence` collection classes to control multiple motion objects – even nesting multiple layers – you can create complex animations with little effort.


#### Motion

`Motion` uses Swift's KeyPaths to target specific properties of an object and transform their values over a period of time via an easing equation. Althought we can provide those transformation instructions directly via `PropertyData` objects, that can become unweildy when interpolating many object values. To alleviate this, `Motion` also accepts `MotionState` objects that provide representations of end states for objects. In this example we're providing a `CGAffineTransform` object for the transform and a `UIColor` object for the backgroundColor of the target view. `Motion` will automatically create `PropertyData` objects from these states.

```swift
let transformState = MotionState(keyPath: \UIView.transform, end: circle.transform.scaledBy(x: 1.5, y: 1.5))
let colorState = MotionState(keyPath: \UIView.backgroundColor[default: .black], end: .systemBlue)

// The `states` parameter here is a parameter pack of `MotionState` objects which have unique generic types. Pass them in as you would a normal variadic parameter. 
motion = Motion(target: circleView,
                states: transformState, colorState,
              duration: 2.0,
                easing: EasingBack.easeInOut(overshoot: 0.5))
.reverses()
.start()
```

![Motion animation](Guides/mm_motion.gif)


#### MotionGroup

`MotionGroup` is a `MoveableCollection` class that manages a group of `Moveable` objects, controlling their movements in parallel. It's handy for controlling and synchronizing multiple `Moveable` objects. `MotionGroup` can even control other `MoveableCollection` objects. In the below example, we told the MotionGroup to reverse and synchronize its child motions while doing so. What this means is that it will pause all motions after the forward movement is done, and only then will it reverse them. In this case, the horizontal movements pause while waiting for the Motion which modifies the second circle's backgroundColor to finish its 3 second duration.

```swift

// the MotionGroup will wait for all child motions to finish moving forward before starting their reverse motions
group = MotionGroup().reverses(syncsChildMotions: true)

// move first circle horizontally
let horizontal1 = Motion(target: constraints["x1"]!,
                         properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, end: 250.0)],
                         duration: 1.5,
                         easing: EasingSine.easeOut())
.reverses()
group.add(horizontal1)

// reverse and repeat horizontal movement of second circle once, with a subtle overshoot easing
let horizontal2 = Motion(target: constraints["x2"]!,
                  properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, end: 250.0)],
                  duration: 1.0,
                  easing: EasingBack.easeOut(overshoot: 0.12))
.reverses()
group.add(horizontal2)

// Change the backgroundColor of the second circle. The "default" subscript in the keyPath is due to UIView's `backgroundColor` property being an optional.
let color = Motion(target: circles[1],
                   states: MotionState(keyPath: \UIView.backgroundColor[default: .black], end: .systemBlue),
                 duration: 3.0,
                   easing: EasingQuadratic.easeInOut())
group.add(color)

.start()
```

![MotionGroup animation](Guides/mm_group.gif)


#### MotionSequence

`MotionSequence` is a `MoveableCollection` class which moves a collection of `Moveable` objects in sequential order, even other `MoveableCollection` objects. `MotionSequence` provides a powerful and easy way of chaining together value transformations of object properties to do keyframing or to create complex and fluid compound animations of many objects.

```swift

// Create a reversing MotionSequence with its reversingMode set to contiguous to create a fluid animation from its child motions. We could make these one Motion with multiple states, but we want to use different easing equations and durations on the view properties.
sequence = MotionSequence().reverses(.contiguous)

// set up motions for each circle and add them to the MotionSequence
for circle in circles {
    // motion to animate a UIView's origin
    let down = Motion(target: circle,
                      properties: [PropertyData(keyPath: \UIView.frame.origin.y, end: 60.0)],
                      duration: 0.4,
                      easing: EasingQuartic.easeInOut())

    // motion to change background color of circle
    let color = Motion(target: circle,
                       states: MotionState(keyPath: \UIView.backgroundColor[default: .black], end: .systemBlue),
                       duration: 0.3,
                       easing: EasingQuadratic.easeInOut())

    // wrap the Motions in a MotionGroup and set it to reverse
    let group = MotionGroup(motions: [down, color]).reverses(syncsChildMotions: true)

    // add group to the MotionSequence
    sequence.add(group)
}
sequence.start()
```

![MotionSequence animation](Guides/mm_sequence_contiguous.gif)


## Installation

You can add MotionMachine to an Xcode project by adding it as a Swift package dependency.
```swift
.product(name: "MotionMachine", package: "MotionMachine")
```

## Compatibility

MotionMachine currently requires:
* Swift 6.0 or above
* Xcode 16+
* iOS 16.0 or later, macOS 14.0 or later, visionOS 1.0 or later, watchOS 9.0 or later, tvOS 16.0 or later

#### Caveats

* Structs cannot be used as the top level of a KeyPath, though you can use them as a descendent of the top level object.

* Optionals in key paths are supported, however you must provide a default value for them via a subscript when declaring the path, using the format `\Object.someOptional[default: <some default value>]`.

## Credits

MotionMachine was created by [Brett Walker](https://bsky.app/profile/petsound.bsky.social). It is loosely based on the author's Objective-C library [PMTween](https://github.com/poetmountain/PMTween).


## License

MotionMachine is licensed under the MIT License. See LICENSE for details.

I'd love to know if you use MotionMachine in your projects!
