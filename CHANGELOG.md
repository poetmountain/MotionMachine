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
