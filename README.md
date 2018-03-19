![MotionMachine logo](Guides/mmlogo.png)

![swift](https://img.shields.io/badge/Swift-4.0-005AA5.svg)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20tvOS-005AA5.svg)
![license](https://img.shields.io/badge/license-MIT-005AA5.svg)

MotionMachine is a powerful yet elegant animation library for Swift. It offers sensible default functionality that abstracts most of the hard work away, allowing you to focus on your work. But MotionMachine also makes it easy to dive in and modify for your own needs, whether that be custom motion classes, supporting custom value types, or new easing equations.


## Introduction

MotionMachine provides a modular, generic platform for manipulating values. Its animation engine was built from the ground up to support not just UIKit values, but property values of any class you want to manipulate. MotionMachine does support most major UIKit types out of the box and provides syntactic sugar to easily manipulate them.

* Animation engine built from the ground up (not tied to Core Animation).
* Motions can be grouped, sequenced, and nested in any arrangement.
* Animate properties of UIKit or any generic classes.
* Includes both static and physics-based motion classes, and both support additive animation.
* Powerfully modular – most aspects can be customized or outright replaced to fit your specific needs.
* Provides status callback closures for many types of motion events.
* Fully tested
* Fully [documented](https://poetmountain.github.io/MotionMachine/)

#### Example
![MotionGroup animation](Guides/group.gif)

This complex animation was created with the code sample below. These `Motion` classes animate the NSLayoutConstraints of the circle views (_the constraints object in the `target` parameter is a dictionary of NSLayoutConstraint references_) as well as one of their `backgroundColor` properties. A `MotionGroup` object is used to synchronize the four `Motion` objects and reverse their movements.
```swift
let group = MotionGroup()

.add(Motion(target: constraints["circleX"]!,
        properties: [PropertyData("constant", 200.0)],
          duration: 1.0,
            easing: EasingQuartic.easeInOut()))

.add(Motion(target: constraints["circleY"]!,
        properties: [PropertyData("constant", 250.0)],
          duration: 1.4,
            easing: EasingElastic.easeInOut()))

.add(Motion(target: circle,
        properties: [PropertyData("backgroundColor.blue", 0.9)],
          duration: 1.2,
            easing: EasingQuartic.easeInOut()))

.add(Motion(target: constraints["circle2X"]!,
        properties: [PropertyData("constant", 300.0)],
          duration: 1.2,
            easing: EasingQuadratic.easeInOut())
            .reverses(withEasing: EasingQuartic.easeInOut()))

.start()
```

#### How does this work?

All of the included motion classes in MotionMachine adopt the `Moveable` protocol, which enables them to work seamlessly together. By using the `MotionGroup` and `MotionSequence` collection classes to control multiple motion objects – even nesting multiple layers – you can create complex animations with little effort. If you want to use your own custom motion classes within the MotionMachine ecosystem, simply have them adopt the `Moveable` protocol. However, the base `Motion` class offers such modularity that in most cases you can just add to or replace the components you need with your own implementation.

##### Motion

`Motion` uses a keypath (i.e. "frame.origin.x") to target specific properties of an object and transform their values over a period of time via an easing equation.

```
[Motion] --------------> |
```

##### MotionGroup

`MotionGroup` is a `MoveableCollection` class that manages a group of `Moveable` objects, controlling their movements in parallel. It's handy for controlling and synchronizing multiple `Moveable` objects. `MotionGroup` can even control other `MoveableCollection` objects.

```
[Motion] --------------> |
[Motion] --------------------> |
[MotionSequence] ----------------> |
```

##### MotionSequence

`MotionSequence` is a `MoveableCollection` class which moves a collection of `Moveable` objects in sequential order, even other `MoveableCollection` objects. `MotionSequence` provides a powerful and easy way of chaining together individual motions to create complex and fluid compound animations.

```
0.[Motion] -------> |, 1.[MotionGroup] -------> |, 2.[PhysicsMotion] -------> |
```



## Getting Started

##### Get started with the **[Motion Classes guide](Guides/MoveableClasses.md)** for detailed explanations and examples.

Also check out the [Examples project](Examples) to see all the MotionMachine classes in action, or dive deep into the source [Documentation](https://poetmountain.github.io/MotionMachine/).


## Installation

If you use CocoaPods:

##### Podfile
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

use_frameworks!

target 'target name here' do
    pod 'MotionMachine', '~> 1.1.0'
end
```

Or add the Classes directory to your project.

## Compatibility

MotionMachine currently requires:
* Swift 4.0
* Xcode 9.0 or later
* iOS 8.0 or later, tvOS 9.0 or later

#### Caveats

* MotionMachine uses Key-Value Coding (KVC) to introspect objects and retrieve and set their property values using keypaths. Because Swift currently offers no native ability in this regard, objects whose properties should be modified by MotionMachine must inherit from `NSObject`. If and when more dynamism is added to Swift (and the author of this library hopes that is the case), MotionMachine will hopefully be able to do away with this restriction. Note that as of Swift 4.0, any properties of a custom class you wish to manipulate must be prefixed with `@objc`, or add `@objcMembers` above the class if all properties should be exposed.

* Because native Swift structs cannot inherit from `NSObject`, Swift structs unfortunately cannot be used with MotionMachine at this time.

* The KVC provided by `NSObject` is not able to evaluate Optional values. Properties you wish to modify with MotionMachine must not be Optionals.

* Swift on Linux is not currently supported due to the lack of Foundation and Core Graphics frameworks on that platform.

## Credits

MotionMachine was created by [Brett Walker](https://twitter.com/petsound). It is based on the author's Objective-C library [PMTween](https://github.com/poetmountain/PMTween).


## License

MotionMachine is licensed under the MIT License. See LICENSE for details.

I'd love to know if you use MotionMachine in your projects!
