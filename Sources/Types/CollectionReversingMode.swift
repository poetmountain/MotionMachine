//
//  CollectionReversingMode.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// The mode used to define the movement behavior of sequence steps when the ``isReversing`` property of a `MoveableCollection` object is set to `true`.
public enum CollectionReversingMode {
    
    /**
     *  Specifies that when the sequence's ``motionDirection`` property is `reverse`, each sequence step will still move normally, but just in reverse order.
     *
     *  - remark: This mode is useful if you want sequence steps to move consistently, regardless of the state of the ``motionDirection`` property. For example, this mode would be chosen if you have a series of lights that should blink on and off in sequential order, and the only thing that should change is the order in which they blink.
     */
    case sequential
    
    /**
     *  Specifies that when the sequence's ``motionDirection`` property is `reverse`, all ``Moveable`` sequence steps will move in a reverse direction to their normal motion. That is, the values of each sequence step will move in reverse, and in reverse order, thus giving the effect that the whole sequence is fluidly moving in reverse. Additionally, when the sequence's ``motionDirection`` is `forward`, each sequence step will pause after completing their forward movement.
     *
     *  - remark: This mode is useful if you want to create a sequence whose sequence steps reverse in a mirror image of their forward motion. This is a really powerful way of making many separate animations appear to be a single, fluid animation when reversing.
     */
    case contiguous
    
}
