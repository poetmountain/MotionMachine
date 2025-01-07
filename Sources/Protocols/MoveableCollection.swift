//
//  MoveableCollection.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol declares methods and properties that must be adopted by custom classes which control other ``Moveable`` classes in order to participate in the MotionMachine ecosystem. All standard MotionMachine collection classes (``MotionSequence``, ``MotionGroup``) conform to this protocol.
@MainActor public protocol MoveableCollection {
    
    /**
     *  An enum which defines the behavior of a ``Moveable`` class when its ``isReversing`` property is set to `true`. In the standard MotionMachine classes only ``MotionSequence`` currently uses this property to alter its behavior, but they all propagate changes to this property down to their collection children.
     *
     *  - note: Though classes implementing this property don't need to alter their own behavior based on the value that is set, they do need to pass the value to all of its children which conform to this protocol.
     */
    var reversingMode: CollectionReversingMode { get set }
    
}
