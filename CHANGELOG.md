### 3.1.0

- Added support for watchOS!
- Updates to support Linux and other non-Apple Swift platforms. Replaced code specific to Apple platforms with core Swift classes.
- Improved timing accuracy of `PhysicsMotion` and `PathPhysicsMotion`, as well as `TimerTempo`.

### 3.0.0
- MotionMachine's use of `NSObject` Key-Value Coding paths (i.e. "frame.origin.x") to read and write property values has been replaced with modern Swift KeyPaths (i.e. `\UIView.frame.origin.x`). This significant change provides more type safety and compile-time type checking, eliminates unsafe code, and now allows for the use of Optional properties and structs. Please see the [Motion Classes guide](Guides/MoveableClasses.md) for implementation examples. Tests and examples project have also been updated to reflect these changes.
- Added support for macOS! MotionMachine may now be used in AppKit projects in macOS 14.0 or higher.
- Added a new value assistant `SIMDAssistant` to support using all current `SIMD` types as `MotionState` states. Added tests for this class.
- Added a new value assistant `CGColorAssistant` to support using `CGColor` as a `MotionState` state. Added tests for this class.
- Added a new value assistant `NumericAssistant` which is now the default assistant for top-level properties on the target object which are numeric values. This supports all of the many numeric types that conform to either `BinaryFloatingPoint` or `BinaryInteger`, as well as `NSNumber`. Added tests for this class.
- Fixed `velocityDecayLimit` not being settable on `PhysicsMotion`.
- Improved internal platform availability checks. Theoretically this may allow MotionMachine to now run on non-Apple platforms on which Swift is available, though this has not been tested.
- With this update the minimum supported versions of iOS and tvOS have been increased to 16.0 in order to support KeyPaths in a generic way. If you need to support earlier versions of iOS or tvOS, please continue to use MotionMachine release `2.2.1`.
- Support for Swift 5.10 has been dropped due to the adoption of a Swift 6 feature (parameter pack iteration). If you require an older version of Swift, please use MotionMachine release `2.2.1` or older.

### 2.2.1
- Added support for visionOS
- Fixed some access permission issues
- Added convenience inits for `PathMotion` and `PathPhysicsMotion` to remove the need to pass in a `PathState` manually
- Added `setupPerformanceMode` convenience method to `PathMotion` and `PathPhysicsMotion` classes (which call `PathState`'s method internally)

### 2.2.0
- Added `PathMotion` class to allow a `CGPoint` to be animated along the length of a `CGPath`! `PathMotion` conforms to the `Moveable` protocol and interacts with the MotionMachine ecosystem as you'd expect from the other motion classes, and you can use all of the normal easing equations. Using the `startPosition` and `endPosition` parameters you can even specify a portion of the path to animate along.
- Added `PathPhysicsMotion` class to allow a `CGPoint` to be animated along the length of a `CGPath` using the same physics system that `PhysicsMotion` uses! Like `PathMotion`, it conforms to the `Moveable` protocol and interacts with the MotionMachine ecosystem as you'd expect from the other motion classes.
- Added simple collision handling to `PhysicsSystem`, the physics engine that powers `PhysicsMotion` and `PathPhysicsMotion`. Collision points can be specified using the starting and ending points of a motion, and a `restitution` value to control how much velocity is lost during a collision can be set using the new `PhysicsConfiguration` object.
- Added tests, documentation, and examples for `PathMotion` and `PathPhysicsMotion`.

### 2.1.0
- Support for Swift 6.0 and strict concurrency mode
- Removed many legacy forced unwrappings of Optionals
- Changed PhysicsMotion's DispatchSourceTimer to regular Timer to solve concurrency crash

### 2.0.1
- Fixed some retain cycles that were holding on to target objects
- Updated examples project

#### 2.0.0
- Support for Swift 5.0
- Updated syntax in MotionOptions for newer Swift naming conventions
- Updated Swift package file to newest version, requires Xcode 11 to import
- Bumped version to 2.0.0 due to breaking change in MotionOptions (Swift Package Manager requires packages use semantic versioning)

#### 1.3.3
- Support for Swift 4.2

#### 1.3.2
- fixed bugs which prevented some CGStructs from being updated when using `Motion`’s statesForProperties convenience initializer
- added targetsNestedStruct static method to `CGStructAssistant`, which determines whether a specified keyPath targets a struct of a CGRect
- added and improved tests
- improved readability and streamlined some code

#### 1.3.1
- renamed Classes directory to Sources
- miscellaneous package changes

#### 1.3.0
- Refactored the "finalState" convenience initializer for the Motion class to now take an Array of `PropertyStates` objects. This allows you to provide both starting and ending representational value objects for easy animation properties creation. Most of the `ValueAssistant` objects had significant updates to support this.
- A new "buildPropertyData(fromObject: AnyObject, propertyStates: [PropertyStates])" public method has been added to the `Motion` class, which creates and returns an array of `PropertyData` objects. This method is used in conjunction with the above convenience initializer, but can be called ad hoc to generate `PropertyData` objects from a set of state objects you pass in.
- Bugfix: `ValueAssistant`s now won't exclude properties from being created when the ending value is the same as the object's original value, but the specified starting value is different.
- Minor updates for Swift 4 compatibility. The Examples and Tests projects now target Swift 4.
- Updated tests, and additional test coverage for `ValueAssistant` classes.

#### 1.2.0
Support for Swift 4.0.

#### 1.1.1
Fixes for compiler warnings and deprecations.

#### 1.1.0
Support for Swift 3.0.

#### 1.0.0
Initial release
