//
//  DisplayablePickerItemConformance.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import CodeLaunchKit
import SwiftPickerKit

// MARK: - Folder
extension Folder: @retroactive DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

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


// MARK: - LaunchProject
extension LaunchProject: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}


// MARK: - ProjectLink
extension ProjectLink: DisplayablePickerItem {
    public var displayName: String {
        return "\(name.bold) - \(urlString)"
    }
}


// MARK: - LaunchProjectFolder
extension ProjectFolder: DisplayablePickerItem {
    var displayName: String {
        return name
    }
}


// MARK: - AssignCategoryType
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


// MARK: - AssignGroupType
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


// MARK: - DirectoryContainer
extension DirectoryContainer: DisplayablePickerItem {
    var displayName: String {
        return directory.name
    }
}


// MARK: - OLD
extension SwiftDataProjectLink: DisplayablePickerItem {
    public var displayName: String {
        return "\(name.bold) - \(urlString)"
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
