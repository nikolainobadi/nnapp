//
//  RemoveGroupTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
import SwiftPickerTesting
@testable import nnapp

private let groupName = "G"
private let projectName = "P"

@MainActor
final class RemoveGroupTests: MainActorBaseRemoveTests {
    @Test("Removes group and its projects")
    func removesGroupAndProjects() throws {
        let factory = try makeFactory()
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory()
        let group = makeSwiftDataGroup(name: groupName)
        let project = makeSwiftDataProject(name: projectName)

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)

        #expect(try context.loadGroups().count == 1)
        #expect(try context.loadProjects().count == 1)

        try runGroupCommand(factory, name: groupName)

        #expect(try context.loadGroups().isEmpty)
        #expect(try context.loadProjects().isEmpty)
    }
}


// MARK: - Factory
private extension RemoveGroupTests {
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
private func runGroupCommand(_ factory: MockContextFactory? = nil, name: String?) throws {
    try MainActorBaseRemoveTests.runRemoveCommand(factory, argType: .group(name: name))
}
