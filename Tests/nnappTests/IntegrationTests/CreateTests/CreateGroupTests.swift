//
//  CreateGroupTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Files
import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

private let existingGroupName = "existingGroupName"
private let existingCategoryName = "existingCategoryName"

@MainActor
final class CreateGroupTests: MainActorBaseCreateTests {
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])

        try super.init(testFolder: .init(name: "createGroupCategoryList", subFolders: [testCategoryFolder]))
    }
}


// MARK: - Unit Tests
extension CreateGroupTests {
    @Test("Throws error when no Category is selected")
    func throwsErrorWhenNoCategorySelected() throws {
        let folderBrowser = MockDirectoryBrowser()
        let factory = MockContextFactory(folderBrowser: folderBrowser)

        #expect(throws: (any Error).self) {
            try runGroupCommand(factory: factory)
        }
    }

    @Test("Throws error when name is taken by existing Group")
    func throwsErrorWhenGroupNameIsTaken() throws {
        let factory = try makeFactory(includeGroup: true)

        #expect(throws: CodeLaunchError.groupNameTaken) {
            try runGroupCommand(factory: factory, name: existingGroupName, category: existingCategoryName)
        }
    }

    @Test("Throws error when name is taken by existing folder in Category folder")
    func throwsErrorWhenGroupFolderNameIsTaken() throws {
        let factory = try makeFactory(includeGroup: false)

        #expect(throws: CodeLaunchError.groupFolderAlreadyExists) {
            try runGroupCommand(factory: factory, name: existingGroupName, category: existingCategoryName)
        }
    }

    @Test("Creates a new Group folder in an existing Category folder")
    func createsNewGroupFolderInExistingCategoryFolder() throws {
        let groupName = "newGroupName"
        let factory = try makeFactory()

        try runGroupCommand(factory: factory, name: groupName, category: existingCategoryName)

        let context = try factory.makeContext()
        let newGroup = try #require(context.loadGroups().first)
        let newGroupPath = try #require(newGroup.path)
        let updatedCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        let newGroupFolder = try updatedCategoryFolder.subfolder(named: groupName)

        #expect(newGroup.name == groupName)
        #expect(newGroupPath == newGroupFolder.path)
    }
}


// MARK: - Factory
private extension CreateGroupTests {
    func makeFactory(includeGroup: Bool = false) throws -> MockContextFactory {
        let existingCategoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        let folderBrowser = MockDirectoryBrowser()
        folderBrowser.selectedDirectory = FilesDirectoryAdapter(folder: existingCategoryFolder)
        let factory = MockContextFactory(folderBrowser: folderBrowser)
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
private func runGroupCommand(factory: MockContextFactory? = nil, name: String? = nil, category: String? = nil) throws {
    try MainActorBaseCreateTests.runCreateCommand(factory, argType: .group(name: name, category: category))
}
