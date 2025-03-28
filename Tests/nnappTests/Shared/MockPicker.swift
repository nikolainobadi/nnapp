//
//  MockPicker.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Foundation
import SwiftPicker
@testable import nnapp

final class MockPicker {
    private let selectedItemIndex: Int
    private let shouldThrowError: Bool
    private let errorMessage = "MockPicker error"
    private var inputResponses: [String]
    private var requiredInputResponses: [String]
    private var permissionResponses: [Bool]
    private(set) var prompts: [PickerPrompt] = []
    
    init(selectedItemIndex: Int = 0, inputResponses: [String] = [], requiredInputResponses: [String] = [], permissionResponses: [Bool] = [], shouldThrowError: Bool = false) {
        self.selectedItemIndex = selectedItemIndex
        self.shouldThrowError = shouldThrowError
        self.inputResponses = inputResponses
        self.permissionResponses = permissionResponses
        self.requiredInputResponses = requiredInputResponses
    }
}


// MARK: - Picker
extension MockPicker: Picker {
    func getInput(prompt: PickerPrompt) -> String {
        prompts.append(prompt)
        return inputResponses.isEmpty ? "" : inputResponses.removeFirst()
    }
    
    func getRequiredInput(prompt: PickerPrompt) throws -> String {
        prompts.append(prompt)
        if shouldThrowError {
            throw NSError(domain: "MockPicker", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        return requiredInputResponses.isEmpty ? "" : requiredInputResponses.removeFirst()
    }
    
    // permissions (y/n)
    func getPermission(prompt: PickerPrompt) -> Bool {
        prompts.append(prompt)
        return permissionResponses.isEmpty ? false : permissionResponses.removeFirst()
    }
    
    func requiredPermission(prompt: PickerPrompt) throws {
        prompts.append(prompt)
        if shouldThrowError {
            throw NSError(domain: "MockPicker", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
    
    func singleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> Item? {
        // TODO: -
        return nil
    }
    
    func requiredSingleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) throws -> Item {
        prompts.append(title)
        if shouldThrowError {
            throw NSError(domain: "MockPicker", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        return items[selectedItemIndex]
    }
    
    func multiSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> [Item] {
        return []
    }
}

