//
//  LaunchProject.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/31/25.
//

import SwiftData

/// Represents a project (Xcode project, Swift package, or workspace) within a group.
/// Includes metadata such as its type, remote repo, and associated links.
@Model
final class LaunchProject {
    @Attribute(.unique) var name: String
    @Attribute(.unique) var shortcut: String?

    var type: ProjectType
    var remote: ProjectLink?
    var links: [ProjectLink]
    var group: LaunchGroup?

    /// Initializes a new `LaunchProject`.
    /// - Parameters:
    ///   - name: The name of the project.
    ///   - shortcut: Optional quick-launch shortcut.
    ///   - type: The project type (e.g. `.project`, `.package`, `.workspace`).
    ///   - remote: Optional remote repository link.
    ///   - links: Additional user-defined links associated with the project.
    init(name: String, shortcut: String?, type: ProjectType, remote: ProjectLink?, links: [ProjectLink]) {
        self.name = name
        self.shortcut = shortcut
        self.type = type
        self.remote = remote
        self.links = links
    }
}


// MARK: - Helpers
extension LaunchProject {
    /// Returns the expected file name for the project based on its type.
    var fileName: String {
        switch type {
        case .package: return "Package.swift"
        default: return "\(name).\(type.fileExtension)"
        }
    }

    /// Returns the group path this project belongs to, if resolvable.
    var groupPath: String? {
        guard let group, let category = group.category else { return nil }
        return category.path.appendingPathComponent(group.name)
    }

    /// Returns the folder path for the project on disk.
    var folderPath: String? {
        guard let groupPath else { return nil }
        return groupPath.appendingPathComponent(name)
    }

    /// Returns the full path to the project file (e.g. `.xcodeproj`, `Package.swift`).
    var filePath: String? {
        guard let folderPath else { return nil }
        return folderPath.appendingPathComponent(fileName)
    }
}
