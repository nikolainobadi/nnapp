//
//  SwiftDataLaunchGroup.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public typealias SwiftDataLaunchGroup = FirstSchema.LaunchGroup


// MARK: - Helpers
public extension SwiftDataLaunchGroup {
    /// Computes the full folder path for the group based on its parent category's path.
    var path: String? {
        guard let category else { return nil }
        return category.path.appendingPathComponent(name)
    }
}
