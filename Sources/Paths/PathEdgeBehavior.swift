//
//  PathEdgeBehavior.swift
//  MotionMachine
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This enum defines the behavior a path motion takes when at an edge of the path.
public enum PathEdgeBehavior {
    
    /// If a motion travels beyond the path's edge, such as with some easing equations, the motion's point value will not move beyond the edge.
    case stopAtEdges
    
    /// Denotes that a path's starting and ending edges should be treated as connected, contiguous points. If a motion travels beyond the path's edge, as can happen with some easing equation classes like ``EasingElastic`` and ``EasingBack``, the motion will continue in the current direction at the beginning of the other edge.
    case contiguousEdges
}
