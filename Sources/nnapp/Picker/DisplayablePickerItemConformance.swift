//
//  DisplayablePickerItemConformance.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import CodeLaunchKit
import SwiftPickerKit

// MARK: - LaunchCategory
extension LaunchCategory: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

// MARK: - LaunchGroup
extension LaunchGroup: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension SwiftDataLaunchCategory: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension SwiftDataLaunchGroup: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension SwiftDataLaunchProject: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension Folder: @retroactive DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension ProjectFolder: DisplayablePickerItem {
    var displayName: String {
        return name
    }
}

extension SwiftDataProjectLink: DisplayablePickerItem {
    public var displayName: String {
        return "\(name.bold) - \(urlString)"
    }
}

extension AssignCategoryType: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .select:
            return "Select an existing Category"
        case .create:
            return "Create new Category and folder"
        case .import:
            return "Import existing folder to create new Category"
        }
    }
}

extension AssignGroupType: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .select:
            return "Select an existing Group"
        case .create:
            return "Create new Group and folder"
        case .import:
            return "Import existing folder to create new Group"
        }
    }
}
