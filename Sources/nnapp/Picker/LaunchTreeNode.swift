//
//  LaunchTreeNode.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/8/25.
//

import CodeLaunchKit
import SwiftPickerKit

struct LaunchTreeNode {
    private let children: [LaunchTreeNode]
    private let canSelect: Bool
    
    let type: NodeType
    
    init(type: NodeType, canSelect: Bool, children: [LaunchTreeNode]) {
        self.canSelect = canSelect
        self.children = children
        self.type = type
    }
}


// MARK: - TreeNodePickerItem
extension LaunchTreeNode: TreeNodePickerItem {
    var hasChildren: Bool {
        return !children.isEmpty
    }
    
    var isSelectable: Bool {
        return canSelect
    }
    
    var displayName: String {
        switch type {
        case .category(let category):
            return category.name
        case .group(let group):
            if let shortcut = group.shortcut {
                return "\(group.name) [\(shortcut)]"
            }
            return group.name
        case .project(let project):
            if let shortcut = project.shortcut {
                return "\(project.name) [\(shortcut)]"
            }
            return project.name
        }
    }
    
    var metadata: TreeNodeMetadata? {
        switch type {
        case .category:
            return .init(icon: "🗂️")
        case .group:
            return .init(icon: "📁")
        case .project(let project):
            let icon: String
            switch project.type {
            case .project:
                icon = "📄"
            case .package:
                icon = "📦"
            case .workspace:
                icon = "🧰"
            }
            return .init(icon: icon)
        }
    }
    
    func loadChildren() -> [LaunchTreeNode] {
        return children
    }
}


// MARK: - Dependencies
extension LaunchTreeNode {
    enum NodeType {
        case category(LaunchCategory)
        case group(LaunchGroup)
        case project(LaunchProject)
    }
}


// MARK: - Helpers
extension LaunchTreeNode {
    static func categoryNodes(
        categories: [LaunchCategory],
        canSelect: Bool = true,
        canSelectGroups: Bool = true,
        canSelectProjects: Bool = true,
        includeProjects: Bool = true
    ) -> [LaunchTreeNode] {
        return categories.map { category in
            let groupNodes = groupNodes(
                groups: category.groups,
                canSelect: canSelectGroups,
                canSelectProjects: canSelectProjects,
                includeProjects: includeProjects
            )
            
            return .init(type: .category(category), canSelect: canSelect, children: groupNodes)
        }
    }
    
    static func groupNodes(groups: [LaunchGroup], canSelect: Bool, canSelectProjects: Bool, includeProjects: Bool = true) -> [LaunchTreeNode] {
        return groups.map { group in
            let projectNodes = projectNodes(projects: group.projects, canSelect: canSelectProjects, shouldInclude: includeProjects)
            
            return .init(type: .group(group), canSelect: canSelect, children: projectNodes)
        }
    }
    
    static func projectNodes(projects: [LaunchProject], canSelect: Bool, shouldInclude: Bool) -> [LaunchTreeNode] {
        return shouldInclude ? projects.map({ .init(type: .project($0), canSelect: canSelect, children: []) }) : []
    }
}
