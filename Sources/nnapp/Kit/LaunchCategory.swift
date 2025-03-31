//
//  LaunchCategory.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/31/25.
//

import SwiftData

/// Represents a top-level category in the project hierarchy, such as a team, domain, or product line.
/// Each category can contain multiple groups and has a unique path on disk.
@Model
final class LaunchCategory {
    @Attribute(.unique) var name: String
    @Attribute(.unique) var path: String
    @Relationship(deleteRule: .cascade, inverse: \LaunchGroup.category) var groups: [LaunchGroup] = []

    /// Initializes a new `LaunchCategory`.
    /// - Parameters:
    ///   - name: The name of the category.
    ///   - path: The full path to the folder representing this category.
    init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}
