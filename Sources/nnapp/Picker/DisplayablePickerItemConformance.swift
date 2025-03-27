//
//  DisplayablePickerItemConformance.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import SwiftPicker

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
