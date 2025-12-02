//
//  RemoveTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
import SwiftPickerTesting
@testable import nnapp

@MainActor
final class RemoveTests: MainActorTempFolderDatasource {
    @Test("Removes category and cascades delete of groups/projects")
    func removesCategoryAndChildren() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeCategory(name: "ToDelete")
        let group = makeGroup(name: "G")
        let project = makeProject(name: "P")

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        #expect(try context.loadCategories().count == 1)
        #expect(try context.loadGroups().count == 1)
        #expect(try context.loadProjects().count == 1)

        try runCommand(factory, args: ["remove", "category", "ToDelete"])

        #expect(try context.loadCategories().isEmpty)
        #expect(try context.loadGroups().isEmpty)
        #expect(try context.loadProjects().isEmpty)
    }

    @Test("Prompts to select category if name is not provided")
    func promptsIfNoCategoryNameProvided() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeCategory(name: "A")
        try context.saveCategory(category)

        try runCommand(factory, args: ["remove", "category"])

        let categories = try context.loadCategories()
        #expect(categories.isEmpty)
    }
}


// MARK: - Group Tests
extension RemoveTests {
    @Test("Removes group and its projects")
    func removesGroupAndProjects() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup(name: "G")
        let project = makeProject(name: "P")

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        #expect(try context.loadGroups().count == 1)
        #expect(try context.loadProjects().count == 1)

        try runCommand(factory, args: ["remove", "group", "G"])

        #expect(try context.loadGroups().isEmpty)
        #expect(try context.loadProjects().isEmpty)
    }
}


// MARK: - Project Test
extension RemoveTests {
    @Test("Removes project by name")
    func removesProjectByName() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup()
        let project = makeProject(name: "P")

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        try runCommand(factory, args: ["remove", "project", "P"])

        #expect(try context.loadProjects().isEmpty)
    }

    @Test("Removes project by shortcut")
    func removesProjectByShortcut() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup()
        let project = makeProject(name: "P", shortcut: "pshort")

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        try runCommand(factory, args: ["remove", "project", "--shortcut", "pshort"])

        #expect(try context.loadProjects().isEmpty)
    }
}


// MARK: - ProjectLink Tests
extension RemoveTests {
    @Test("Prints message when no links exist")
    func noLinksToRemove() throws {
        let factory = MockContextFactory()
        let output = try Nnapp.testRun(contextFactory: factory, args: ["remove", "link"])
        #expect(output.contains("No Project Links to remove"))
    }

    @Test("Removes selected link")
    func removesSelectedLink() throws {
        let picker = MockSwiftPicker(selectionResult: .init(defaultSingle: .index(0)))
        let factory = MockContextFactory(picker: picker)
        let context = try factory.makeContext()
        context.saveProjectLinkNames(["One", "Two"])

        try runCommand(factory, args: ["remove", "link"])

        let updated = context.loadProjectLinkNames()
        #expect(updated == ["Two"])
    }
}


// MARK: - Factory
private extension RemoveTests {
    func makeFactory(picker: MockSwiftPicker? = nil) throws -> MockContextFactory {
        let picker = picker ?? MockSwiftPicker(
            permissionResult: .init(defaultValue: true),
            selectionResult: .init(defaultSingle: .index(0))
        )
        let factory = MockContextFactory(picker: picker)
        
        return factory
    }

    func runCommand(_ factory: MockContextFactory, args: [String]) throws {
        try Nnapp.testRun(contextFactory: factory, args: args)
    }
}
