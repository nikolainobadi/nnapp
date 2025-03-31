//
//  LaunchGroup.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/31/25.
//

import SwiftData

/// Represents a group within a category, typically used to organize related projects.
/// Groups may include a shortcut for quick-launch purposes and belong to a specific category.
@Model
final class LaunchGroup {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \LaunchProject.group)
    public var projects: [LaunchProject] = []

    var shortcut: String?
    var category: LaunchCategory?

    /// Initializes a new `LaunchGroup`.
    /// - Parameters:
    ///   - name: The group name.
    ///   - shortcut: Optional quick-launch shortcut string.
    init(name: String, shortcut: String? = nil) {
        self.name = name
        self.shortcut = shortcut
    }
}


// MARK: - Helpers
extension LaunchGroup {
    /// Computes the full folder path for the group based on its parent category's path.
    var path: String? {
        guard let category else { return nil }
        return category.path.appendingPathComponent(name)
    }
}
