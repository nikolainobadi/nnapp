//
//  LaunchProject.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public struct LaunchProject {
    public var name: String
    public var shortcut: String?
    public var type: ProjectType
    public var remote: ProjectLink?
    public var links: [ProjectLink]
    
    // TODO: - 
    public var groupName: String? {
        return nil
    }
    public var groupPath: String? {
        return nil
    }
    public var folderPath: String? {
        return nil
    }
    public var filePath: String? {
        return nil
    }
    
    public init(name: String, shortcut: String? , type: ProjectType, remote: ProjectLink?, links: [ProjectLink], groupName: String?) {
        self.name = name
        self.shortcut = shortcut
        self.type = type
        self.remote = remote
        self.links = links
    }
}


// MARK: - Helpers
public extension LaunchProject {
    var fileName: String {
        switch type {
        case .package:
            return "Package.swift"
        default:
            return "\(name).\(type.fileExtension)"
        }
    }
}


// MARK: - Dependencies
public enum ProjectType {
    case project, package, workspace
}

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

public struct ProjectLink: Equatable {
    public let name: String
    public let urlString: String
    
    public init(name: String, urlString: String) {
        self.name = name
        self.urlString = urlString
    }
}
