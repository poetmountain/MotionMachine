//
//  TempoDriven.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/**
 *  This protocol represents objects that subscribe to a ``TempoProviding`` object's update beats. Every movement of a value occurs because time has changed. These beats drive the motion, sending timestamps by which delta values can be calculated. All standard MotionMachine motion classes conform to this protocol.
 *
 *  - important: While you aren't required to implement this protocol in order to update your own custom ``Moveable`` classes, it is the preferred way to interact with the MotionMachine ecosystem unless your requirements prevent using ``TempoProviding`` objects for updating your value interpolations.
 */
@MainActor public protocol TempoDriven: TempoDelegate {
    /**
     *  An object conforming to the ``TempoProviding`` protocol which provides an update "beat" to drive a motion.
     *
     *  - note: It is expected that classes implementing this protocol also subscribe to this object's ``TempoDelegate`` delegate methods.
     */
    var tempo: TempoProviding? { get set }

    /**
     *  Tells a `TempoDriven` object to cease listening to updates from its ``TempoProviding`` object.
     *
     */
    func stopTempoUpdates()
}
