//
//  RemoveCategoryTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
import SwiftPickerTesting
@testable import nnapp

private let categoryName = "ToDelete"
private let groupName = "G"
private let projectName = "P"

@MainActor
final class RemoveCategoryTests: MainActorBaseRemoveTests {
    @Test("Removes category and cascades delete of groups/projects")
    func removesCategoryAndChildren() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory(name: categoryName)
        let group = makeSwiftDataGroup(name: groupName)
        let project = makeSwiftDataProject(name: projectName)

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        #expect(try context.loadCategories().count == 1)
        #expect(try context.loadGroups().count == 1)
        #expect(try context.loadProjects().count == 1)

        try runCategoryCommand(factory, name: categoryName)

        #expect(try context.loadCategories().isEmpty)
        #expect(try context.loadGroups().isEmpty)
        #expect(try context.loadProjects().isEmpty)
    }

    @Test("Prompts to select category if name is not provided")
    func promptsIfNoCategoryNameProvided() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory(name: "A")
        try context.saveCategory(category)

        try runCategoryCommand(factory, name: nil)

        let categories = try context.loadCategories()
        #expect(categories.isEmpty)
    }
}


// MARK: - Factory
private extension RemoveCategoryTests {
    func makeFactory(picker: MockSwiftPicker? = nil) throws -> MockContextFactory {
        let picker = picker ?? MockSwiftPicker(
            permissionResult: .init(defaultValue: true),
            selectionResult: .init(defaultSingle: .index(0))
        )
        let factory = MockContextFactory(picker: picker)

        return factory
    }
}


// MARK: - Run
@MainActor
private func runCategoryCommand(_ factory: MockContextFactory? = nil, name: String?) throws {
    try MainActorBaseRemoveTests.runRemoveCommand(factory, argType: .category(name: name))
}
