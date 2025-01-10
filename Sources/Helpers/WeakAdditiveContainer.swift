//
//  WeakAdditiveContainer.swift
//  MotionMachine
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Contains a value as a weak reference to an object
@MainActor public final class WeakAdditiveContainer: Identifiable {
    private(set) weak var object: (any Additive)?
    
    public let id: UUID

    init(value: (any Additive)?, identifier: UUID) {
        self.object = value
        self.id = identifier
    }
    
}

extension WeakAdditiveContainer: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension WeakAdditiveContainer: Equatable {
    nonisolated public static func == (lhs: WeakAdditiveContainer, rhs: WeakAdditiveContainer) -> Bool {
        return (lhs.id == rhs.id)
    }
}
