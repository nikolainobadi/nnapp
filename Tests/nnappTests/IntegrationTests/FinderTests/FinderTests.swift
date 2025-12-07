//
//  FinderTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Testing
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

@MainActor
final class FinderTests {
    @Test("Opens Category folder with category subcommand", arguments: [nil, "categoryName"])
    func opensCategoryFolder(name: String?) throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let categoryName = name ?? "categoryName"
        let category = makeSwiftDataCategory(name: categoryName)

        try context.saveCategory(category)
        try runCategoryCommand(factory, name: name)
        try assertShell(shell, contains: category.path)
    }

    @Test("Opens Group folder with group subcommand", arguments: [
        GroupAndProjectTestInfo(),
        GroupAndProjectTestInfo(name: "groupName"),
        GroupAndProjectTestInfo(name: "groupName", shortcut: "groupShortcut", useShortcut: true),
    ])
    func opensGroupFolder(info: GroupAndProjectTestInfo) throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory()
        let group = makeSwiftDataGroup(name: info.name ?? "groupName", shortcut: info.shortcut)

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try runGroupCommand(factory, name: info.nameArg)
        try assertShell(shell, contains: group.path)
    }

    @Test("Opens Project folder with project subcommand", arguments: [
        GroupAndProjectTestInfo(),
        GroupAndProjectTestInfo(name: "projectName"),
        GroupAndProjectTestInfo(name: "projectName", shortcut: "projectShortcut", useShortcut: true),
    ])
    func opensProjectFolder(info: GroupAndProjectTestInfo) throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory()
        let group = makeSwiftDataGroup()
        let project = makeSwiftDataProject(name: info.name ?? "projectName", shortcut: info.shortcut)

        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try runProjectCommand(factory, name: info.nameArg)
        try assertShell(shell, contains: group.path)
    }

    func makeTestObjects(picker: MockSwiftPicker? = nil) -> (factory: MockContextFactory, shell: MockLaunchShell) {
        let shell = MockLaunchShell()
        let picker = picker ?? MockSwiftPicker(selectionResult: .init(defaultSingle: .index(0)))
        let factory = MockContextFactory(shell: shell, picker: picker)

        return (factory, shell)
    }
}


// MARK: - Dependencies
struct GroupAndProjectTestInfo {
    let name: String?
    let shortcut: String?
    let useShortcut: Bool

    var nameArg: String? {
        return useShortcut ? shortcut : name
    }

    init(name: String? = nil, shortcut: String? = nil, useShortcut: Bool = false) {
        self.name = name
        self.shortcut = shortcut
        self.useShortcut = useShortcut
    }
}


// MARK: - Run Commands
@MainActor
private func runCategoryCommand(_ factory: MockContextFactory, name: String? = nil) throws {
    var args = ["finder", "category"]

    if let name {
        args.append(name)
    }

    try Nnapp.testRun(contextFactory: factory, args: args)
}

@MainActor
private func runGroupCommand(_ factory: MockContextFactory, name: String? = nil) throws {
    var args = ["finder", "group"]

    if let name {
        args.append(name)
    }

    try Nnapp.testRun(contextFactory: factory, args: args)
}

@MainActor
private func runProjectCommand(_ factory: MockContextFactory, name: String? = nil) throws {
    var args = ["finder", "project"]

    if let name {
        args.append(name)
    }

    try Nnapp.testRun(contextFactory: factory, args: args)
}


// MARK: - Assertion Helpers
@MainActor
private func assertShell(_ shell: MockLaunchShell, contains path: String?) throws {
    let path = try #require(path)

    #expect(shell.executedCommands.count == 1)
    #expect(shell.executedCommand(containing: path))
}
