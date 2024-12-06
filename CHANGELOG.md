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
