//
//  AddProjectTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Files
import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

private let existingGroupName = "Group1"
private let existingCategoryName = "Category1"

@MainActor
final class AddProjectTests: MainActorBaseAddTests {
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])

        try super.init(testFolder: .init(name: "AddProjectTestRoot", subFolders: [testCategoryFolder]))
    }
}


// MARK: - Unit Tests
extension AddProjectTests {
    @Test("Throws an error if no group is selected")
    func throwsErrorWhenNoGroupSelected() throws {
        let folderBrowser = MockDirectoryBrowser()
        let factory = MockContextFactory(folderBrowser: folderBrowser)

        #expect(throws: (any Error).self) {
            try runProjectCommand(factory)
        }
    }

    @Test("Throws error if path from arg finds folder without a project type.")
    func throwsErrorWhenNoProjecTypeExists() throws {
        let nonProjectFolder = try tempFolder.createSubfolder(named: "NonProjectFolder")
        let factory = try makeFactory(selectedFolder: nonProjectFolder)

        #expect(throws: CodeLaunchError.noProjectInFolder) {
            try runProjectCommand(factory, path: nonProjectFolder.path, group: existingGroupName)
        }
    }

    @Test("Throws error if Project name is taken")
    func throwsErrorWhenProjectNameTaken() throws {
        let tempProjectFolder = try tempFolder.createSubfolder(named: "MyProject")
        try tempProjectFolder.createFile(named: "Package.swift")
        let factory = try makeFactory(selectedFolder: tempProjectFolder)
        let context = try factory.makeContext()
        let group = try #require(context.loadGroups().first)
        let existing = makeSwiftDataProject(name: "MyProject")
        try context.saveProject(existing, in: group)

        #expect(throws: CodeLaunchError.projectNameTaken) {
            try runProjectCommand(factory, path: tempProjectFolder.path, group: existingGroupName)
        }
    }

    @Test("Throws error if Project shortcut is taken")
    func throwsErrorWhenProjectShortcutTaken() throws {
        let tempProjectFolder = try tempFolder.createSubfolder(named: "MyProject")
        try tempProjectFolder.createFile(named: "Package.swift")
        let factory = try makeFactory(selectedFolder: tempProjectFolder)
        let context = try factory.makeContext()
        let group = try #require(context.loadGroups().first)
        let existing = makeSwiftDataProject(name: "OtherProject", shortcut: "dup")
        try context.saveProject(existing, in: group)

        #expect(throws: CodeLaunchError.shortcutTaken) {
            try runProjectCommand(factory, path: tempProjectFolder.path, group: existingGroupName, shortcut: "dup")
        }
    }

    @Test("Moves Project folder to Group folder when necessary")
    func movesProjectFolderWhenNecessary() throws {
        let outsideFolder = try tempFolder.createSubfolder(named: "MyProject")
        try outsideFolder.createFile(named: "Package.swift")
        let factory = try makeFactory(selectedFolder: outsideFolder)
        let groupFolder = try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName)

        try runProjectCommand(factory, path: outsideFolder.path, group: existingGroupName)

        #expect(groupFolder.containsSubfolder(named: "MyProject"))
    }

    @Test("Does not move Project folder to Group folder if it is already there")
    func doesNotMoveProjectFolderWhenAlreadyInGroupFolder() throws {
        let groupFolder = try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName)
        let projectFolder = try groupFolder.createSubfolder(named: "MyProject")
        try projectFolder.createFile(named: "Package.swift")
        let factory = try makeFactory(selectedFolder: projectFolder)

        try runProjectCommand(factory, path: projectFolder.path, group: existingGroupName)

        #expect(groupFolder.containsSubfolder(named: "MyProject"))
    }

    @Test("Saves new Project to selected Group")
    func savesNewProjectToGroup() throws {
        let groupFolder = try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName)
        let projectFolder = try groupFolder.createSubfolder(named: "MyProject")
        try projectFolder.createFile(named: "Package.swift")
        let factory = try makeFactory(selectedFolder: projectFolder)
        let context = try factory.makeContext()
        let before = try context.loadProjects()

        #expect(before.isEmpty)

        try runProjectCommand(factory, path: projectFolder.path, group: existingGroupName)

        let after = try context.loadProjects()
        let saved = try #require(after.first)

        #expect(after.count == 1)
        #expect(saved.name == "MyProject")
    }

    @Test("Sets the Group shortcut when isMainProject is true", .disabled())
    func updatesGroupShortcutWhenIsMainProjectIsTrue() throws {
        let groupFolder = try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName)
        let projectFolder = try groupFolder.createSubfolder(named: "MainApp")
        try projectFolder.createFile(named: "Package.swift")
        let factory = try makeFactory(selectedFolder: projectFolder)
        let shortcut = "mainapp"

        try runProjectCommand(factory, path: projectFolder.path, group: existingGroupName, shortcut: shortcut, isMainProject: true)

        let context = try factory.makeContext()
        let groups = try context.loadGroups()
        let group = try #require(groups.first)

        #expect(group.shortcut == shortcut)
    }
}


// MARK: - Factory
private extension AddProjectTests {
    func makeFactory(selectedFolder: Folder) throws -> MockContextFactory {
        let categoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        let groupFolder = try categoryFolder.subfolder(named: existingGroupName)
        let folderBrowser = MockDirectoryBrowser()
        folderBrowser.selectedDirectory = FilesDirectoryAdapter(folder: selectedFolder)
        let picker = MockSwiftPicker(
            inputResult: .init(defaultValue: "shortcut"),
            selectionResult: .init(defaultSingle: .index(0))
        )
        let factory = MockContextFactory(picker: picker, folderBrowser: folderBrowser)
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory(name: categoryFolder.name, path: categoryFolder.path)
        let group = makeSwiftDataGroup(name: groupFolder.name)
        try context.saveCategory(category)
        try context.saveGroup(group, in: category)

        return factory
    }
}


// MARK: - Run
@MainActor
private func runProjectCommand(_ factory: MockContextFactory? = nil, path: String? = nil, group: String? = nil, shortcut: String? = nil, isMainProject: Bool = false) throws {
    try MainActorBaseAddTests.runAddCommand(factory, argType: .project(path: path, group: group, shortcut: shortcut, isMainProject: isMainProject))
}
