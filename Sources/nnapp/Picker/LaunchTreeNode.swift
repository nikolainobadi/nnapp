//
//  LaunchTreeNode.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

import SwiftPickerKit

enum LaunchTreeNode {
    case category(SwiftDataLaunchCategory, selectable: Bool)
    case group(SwiftDataLaunchGroup, selectable: Bool)
    case project(SwiftDataLaunchProject, selectable: Bool)
}


// MARK: - TreeNodePickerItem
extension LaunchTreeNode: TreeNodePickerItem {
    var displayName: String {
        switch self {
        case .category(let category, _):
            return category.name
        case .group(let group, _):
            if let shortcut = group.shortcut {
                return "\(group.name) [\(shortcut)]"
            }
            return group.name
        case .project(let project, _):
            if let shortcut = project.shortcut {
                return "\(project.name) [\(shortcut)]"
            }
            return project.name
        }
    }

    var hasChildren: Bool {
        switch self {
        case .category(let category, _):
            return !category.groups.isEmpty
        case .group(let group, _):
            return !group.projects.isEmpty
        case .project:
            return false
        }
    }

    func loadChildren() -> [LaunchTreeNode] {
        switch self {
        case .category(let category, let selectable):
            return category.groups.map { .group($0, selectable: selectable) }
        case .group(let group, let selectable):
            return group.projects.map { .project($0, selectable: selectable) }
        case .project:
            return []
        }
    }

    var metadata: TreeNodeMetadata? {
        switch self {
        case .category:
            return .init(icon: "🗂️")
        case .group:
            return .init(icon: "📁")
        case .project(let project, _):
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

    var isSelectable: Bool {
        switch self {
        case .category(_, let selectable),
             .group(_, let selectable),
             .project(_, let selectable):
            return selectable
        }
    }
}
