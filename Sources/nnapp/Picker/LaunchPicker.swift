//
//  LaunchPicker.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import SwiftPickerKit

protocol LaunchPicker {
    func getInput(_ prompt: String) -> String
    func getPermission(_ prompt: String) -> Bool
    func requiredPermission(_ prompt: String) throws
    func getRequiredInput(_ prompt: String) throws -> String
    func singleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> Item?
    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) throws -> Item
    func treeNavigation<Item: TreeNodePickerItem>(
        prompt: String,
        root: TreeNavigationRoot<Item>,
        newScreen: Bool,
        showPromptText: Bool,
        showSelectedItemText: Bool
    ) -> Item?
}

extension LaunchPicker {
    func confirmDetails(confirmText: String, details: String) throws {
        let options = [confirmText, "Cancel"]
        let selection = try requiredSingleSelection("Does everything look correct?", items: options, layout: .twoColumnStatic(detailText: details))
        
        guard selection == confirmText else {
            throw SwiftPickerError.selectionCancelled
        }
    }
    
    func requiredSingleSelection<Item: DisplayablePickerItem>(_ prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        return try requiredSingleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }
    
    func singleSelection<Item: DisplayablePickerItem>(_ prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) -> Item? {
        return singleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }
    
    func treeNavigation<Item: TreeNodePickerItem>(
        _ prompt: String,
        root: TreeNavigationRoot<Item>,
        newScreen: Bool = true,
        showPromptText: Bool = true,
        showSelectedItemText: Bool = true
    ) -> Item? {
        return treeNavigation(
            prompt: prompt,
            root: root,
            newScreen: newScreen,
            showPromptText: showPromptText,
            showSelectedItemText: showSelectedItemText
        )
    }
}
