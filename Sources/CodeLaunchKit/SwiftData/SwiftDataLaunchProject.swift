//
//  SwiftDataLaunchProject.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public typealias SwiftDataLaunchProject = FirstSchema.LaunchProject
public typealias SwiftDataProjectType = FirstSchema.ProjectType
public typealias SwiftDataProjectLink = FirstSchema.ProjectLink


// MARK: - Helpers
public extension SwiftDataLaunchProject {
    /// Returns the expected file name for the project based on its type.
    var fileName: String {
        switch type {
        case .package:
            return "Package.swift"
        default:
            return "\(name).\(type.fileExtension)"
        }
    }

    /// Returns the group path this project belongs to, if resolvable.
    var groupPath: String? {
        guard let group, let category = group.category else {
            return nil
        }
        
        return category.path.appendingPathComponent(group.name)
    }

    /// Returns the folder path for the project on disk.
    var folderPath: String? {
        guard let groupPath else {
            return nil
        }
        
        return groupPath.appendingPathComponent(name)
    }

    /// Returns the full path to the project file (e.g. `.xcodeproj`, `Package.swift`).
    var filePath: String? {
        guard let folderPath else {
            return nil
        }
        
        return folderPath.appendingPathComponent(fileName)
    }
}


// MARK: - Extension Dependencies
public extension SwiftDataProjectType {
    /// A human-readable name for the project type.
    var name: String {
        switch self {
        case .project:
            return "Xcode Project"
        case .package:
            return "Swift Package"
        case .workspace:
            return "XCWorkspace"
        }
    }
    
    /// The file extension typically used by this project type.
    var fileExtension: String {
        switch self {
        case .project:
            return "xcodeproj"
        case .package:
            return "swift"
        case .workspace:
            return "xcworkspace"
        }
    }
}
