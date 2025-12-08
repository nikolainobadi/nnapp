//
//  AddGroupTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Files
import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

private let existingGroupName = "existingGroupName"
private let existingCategoryName = "existingCategoryName"

@MainActor
final class AddGroupTests: MainActorBaseAddTests {
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])

        try super.init(testFolder: .init(name: "addGroupCategoryList", subFolders: [testCategoryFolder]))
    }
}


// MARK: - Tests
extension AddGroupTests {
    @Test("Existing Category Folder exists with existing Group Folder")
    func startingValues() throws {
        let existingCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)

        #expect(existingCategoryFolder.containsSubfolder(named: existingGroupName))
    }

    @Test("Throws error when no category is selected")
    func throwsErrorWhenNoCategorySelected() throws {
        let folderBrowser = MockDirectoryBrowser()
        let factory = MockContextFactory(folderBrowser: folderBrowser)

        #expect(throws: (any Error).self) {
            try runGroupCommand(factory)
        }
    }

    @Test("Throws an error when Group name already exists in Category")
    func throwsErrorWhenGroupNameIsTaken() throws {
        let folderToImport = try tempFolder.createSubfolder(named: existingGroupName)
        let factory = try makeFactory(includeGroup: true, selectedFolder: folderToImport)

        #expect(throws: CodeLaunchError.groupNameTaken) {
            try runGroupCommand(factory, path: folderToImport.path, category: existingCategoryName)
        }
    }

    @Test("Throws an error when Group folder name already exists in Category Folder")
    func throwsErrorWhenGroupFolderNameIsTaken() throws {
        let folderToImport = try tempFolder.createSubfolder(named: existingGroupName)
        let factory = try makeFactory(selectedFolder: folderToImport)

        #expect(throws: CodeLaunchError.groupFolderAlreadyExists) {
            try runGroupCommand(factory, path: folderToImport.path, category: existingCategoryName)
        }
    }

    @Test("Moves imported Group folder to Category Folder")
    func movesGroupFolderToCategoryFolder() throws {
        let folderToImport = try tempFolder.createSubfolder(named: "newGroupName")
        let factory = try makeFactory(selectedFolder: folderToImport)

        try runGroupCommand(factory, path: folderToImport.path, category: existingCategoryName)

        let existingCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)

        #expect(existingCategoryFolder.subfolders.count() == 2)
        #expect(existingCategoryFolder.containsSubfolder(named: folderToImport.name))
    }

    @Test("Does not move imported Group folder to Category Folder when it is already there")
    func doesNotMoveGroupFolderToCategoryFolderWhenAlreadyThere() throws {
        let existingCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        let folderToImport = try tempFolder.createSubfolder(named: "newGroupName")
        let factory = try makeFactory(selectedFolder: folderToImport)

        #expect(existingCategoryFolder.subfolders.count() == 1)

        try runGroupCommand(factory, path: folderToImport.path, category: existingCategoryName)

        let updatedCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)

        #expect(updatedCategoryFolder.subfolders.count() == 2)
        #expect(updatedCategoryFolder.containsSubfolder(named: folderToImport.name))
    }

    @Test("Saves new Group to Category")
    func savesNewGroupToCategory() throws {
        let folderToImport = try tempFolder.createSubfolder(named: "newGroupName")
        let factory = try makeFactory(selectedFolder: folderToImport)
        let context = try factory.makeContext()
        let groups = try context.loadGroups()

        #expect(groups.isEmpty)

        try runGroupCommand(factory, path: folderToImport.path, category: existingCategoryName)

        let updatedGroups = try context.loadGroups()

        #expect(updatedGroups.count == 1)
    }
}



// MARK: - Factory
private extension AddGroupTests {
    func makeFactory(includeGroup: Bool = false, selectedFolder: Folder, grantPermission: Bool = true) throws -> MockContextFactory {
        let existingCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        let folderBrowser = MockDirectoryBrowser()
        folderBrowser.selectedDirectory = FilesDirectoryAdapter(folder: selectedFolder)
        let picker = MockSwiftPicker(permissionResult: .init(defaultValue: grantPermission))
        let factory = MockContextFactory(picker: picker, folderBrowser: folderBrowser)
        let context = try factory.makeContext()
        let category = makeSwiftDataCategory(name: existingCategoryName, path: existingCategoryFolder.path)
        try context.saveCategory(category)

        if includeGroup {
            try context.saveGroup(makeSwiftDataGroup(name: existingGroupName), in: category)
        }

        return factory
    }
}


// MARK: - Run
@MainActor
private func runGroupCommand(_ factory: MockContextFactory? = nil, path: String? = nil, category: String? = nil) throws {
    try MainActorBaseAddTests.runAddCommand(factory, argType: .group(path: path, category: category))
}
