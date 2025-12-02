//
//  DisplayablePickerItemConformance.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Files
import SwiftPickerKit

extension LaunchCategory: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension LaunchGroup: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension LaunchProject: DisplayablePickerItem {
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

extension ProjectLink: DisplayablePickerItem {
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
