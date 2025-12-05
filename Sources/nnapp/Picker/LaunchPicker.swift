//
//  LaunchPicker.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import SwiftPickerKit

protocol LaunchPicker {
    func requiredPermission(_ prompt: String) throws
    func getRequiredInput(_ prompt: String) throws -> String
    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) throws -> Item
}

extension LaunchPicker {
    func requiredSingleSelection<Item: DisplayablePickerItem>(_ prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        return try requiredSingleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }
}
