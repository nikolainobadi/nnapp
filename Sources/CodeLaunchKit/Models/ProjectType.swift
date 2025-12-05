//
//  ProjectType.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public enum ProjectType {
    case project, package, workspace
}


// MARK: - Helpers
public extension ProjectType {
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
