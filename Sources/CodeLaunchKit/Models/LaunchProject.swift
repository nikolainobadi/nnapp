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
    
    private var group: Group?
    
    init(name: String, shortcut: String?, type: ProjectType, remote: ProjectLink?, links: [ProjectLink], group: Group?) {
        self.name = name
        self.shortcut = shortcut
        self.type = type
        self.remote = remote
        self.links = links
        self.group = group
    }
}


// MARK: - Init
public extension LaunchProject {
    init(name: String, shortcut: String?, type: ProjectType, remote: ProjectLink?, links: [ProjectLink]) {
        self.init(name: name, shortcut: shortcut, type: type, remote: remote, links: links, group: nil)
    }
}


// MARK: - Helpers
public extension LaunchProject {
    var groupName: String? {
        return group?.name
    }
    
    var groupPath: String? {
        return group?.path
    }
    
    var folderPath: String? {
        return group?.path?.appendingPathComponent(name)
    }
    
    var filePath: String? {
        return folderPath?.appendingPathComponent(fileName)
    }
    
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
extension LaunchProject {
    struct Group {
        let name: String
        let path: String?
    }
}
