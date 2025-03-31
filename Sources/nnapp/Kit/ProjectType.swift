//
//  ProjectType.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/31/25.
//

/// Defines the supported types of projects for quick launching.
enum ProjectType: Codable {
    case project
    case package
    case workspace
}


// MARK: - Helpers
extension ProjectType {
    /// A human-readable name for the project type.
    var name: String {
        switch self {
        case .project: return "Xcode Project"
        case .package: return "Swift Package"
        case .workspace: return "XCWorkspace"
        }
    }

    /// The file extension typically used by this project type.
    var fileExtension: String {
        switch self {
        case .project: return "xcodeproj"
        case .package: return "swift"
        case .workspace: return "xcworkspace"
        }
    }
}
