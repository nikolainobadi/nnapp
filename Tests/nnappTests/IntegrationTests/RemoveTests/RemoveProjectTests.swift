//
//  RemoveProjectTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
import SwiftPickerTesting
@testable import nnapp

private let projectName = "P"
private let projectShortcut = "pshort"

@MainActor
final class RemoveProjectTests: MainActorBaseRemoveTests {
    @Test("Removes project by name")
    func removesProjectByName() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory()
        let group = makeSwiftDataGroup()
        let project = makeSwiftDataProject(name: projectName)

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        try runProjectCommand(factory, name: projectName, shortcut: nil)

        #expect(try context.loadProjects().isEmpty)
    }

    @Test("Removes project by shortcut")
    func removesProjectByShortcut() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory()
        let group = makeSwiftDataGroup()
        let project = makeSwiftDataProject(name: projectName, shortcut: projectShortcut)

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        try runProjectCommand(factory, name: nil, shortcut: projectShortcut)

        #expect(try context.loadProjects().isEmpty)
    }
}


// MARK: - Factory
private extension RemoveProjectTests {
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
private func runProjectCommand(_ factory: MockContextFactory? = nil, name: String?, shortcut: String?) throws {
    try MainActorBaseRemoveTests.runRemoveCommand(factory, argType: .project(name: name, shortcut: shortcut))
}
