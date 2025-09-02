//
//  GroupHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 9/2/25.
//

import Darwin
import Testing
import Foundation
import Files
@testable import nnapp

@MainActor
final class GroupHandlerTests: MainActorTempFolderDatasource {
    private let importedGroupName = "ImportedGroup"
    private let existingGroupName = "existingGroupName"
    private let existingCategoryName = "existingCategoryName"
    
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])
        
        try super.init(testFolder: .init(name: "GroupHandlerTests", subFolders: [testCategoryFolder]))
    }
}

// MARK: - ImportGroup Tests
extension GroupHandlerTests {
    @Test("Returns a group with the imported folder name")
    func returnsGroupWithCorrectName() throws {
        let (sut, _) = try makeSUT()
        let folder = try tempFolder.createSubfolder(named: importedGroupName)
        let group = try sut.importGroup(path: folder.path, category: existingCategoryName)

        #expect(group.name == importedGroupName)
    }

    @Test("Persists the imported group in storage")
    func persistsImportedGroup() throws {
        let (sut, context) = try makeSUT()
        let folder = try #require(try tempFolder.createSubfolder(named: importedGroupName))

        _ = try sut.importGroup(path: folder.path, category: existingCategoryName)

        let groups = try #require(try context.loadGroups())
        let firstGroup = try #require(groups.first)
        
        #expect(groups.count == 1)
        #expect(firstGroup.name == importedGroupName)
    }

    @Test("Creates a subfolder under the category directory")
    func createsCategorySubfolder() throws {
        let sut = try makeSUT().sut
        let folder = try #require(try tempFolder.createSubfolder(named: importedGroupName))

        _ = try sut.importGroup(path: folder.path, category: existingCategoryName)

        let categoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        
        #expect(categoryFolder.containsSubfolder(named: importedGroupName))
    }

    @Test("Throws error when group name already exists")
    func throwsErrorWhenGroupNameAlreadyExists() throws {
        let (sut, context) = try makeSUT()
        let existingGroup = makeGroup(name: existingGroupName)
        let existingCategory = try #require(try context.loadCategories().first)
        let folderToImport = try tempFolder.createSubfolder(named: existingGroupName)
        
        try context.saveGroup(existingGroup, in: existingCategory)
        
        #expect(throws: CodeLaunchError.groupNameTaken) {
            try sut.importGroup(path: folderToImport.path, category: existingCategoryName)
        }
    }
    
    @Test("Does not move folder when already in correct location")
    func doesNotMoveFolderWhenAlreadyInCorrectLocation() throws {
        let sut = try makeSUT().sut
        let categoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        let groupFolder = try categoryFolder.createSubfolder(named: existingGroupName)
        
        #expect(categoryFolder.containsSubfolder(named: groupFolder.name))
        
        let importedGroup = try sut.importGroup(path: groupFolder.path, category: existingCategoryName)
        
        #expect(importedGroup.name == existingGroupName)
        #expect(categoryFolder.containsSubfolder(named: existingGroupName))
    }
}


// MARK: - CreateGroup Tests
extension GroupHandlerTests {
    @Test("Creates group with provided name")
    func createsGroupWithProvidedName() throws {
        let (sut, _) = try makeSUT()
        let groupName = "NewTestGroup"
        
        let group = try sut.createGroup(name: groupName, category: existingCategoryName)
        
        #expect(group.name == groupName)
    }
    
    @Test("Persists created group in storage")
    func persistsCreatedGroup() throws {
        let (sut, context) = try makeSUT()
        let groupName = "NewTestGroup"
        
        _ = try sut.createGroup(name: groupName, category: existingCategoryName)
        
        let groups = try #require(try context.loadGroups())
        let firstGroup = try #require(groups.first)
        
        #expect(groups.count == 1)
        #expect(firstGroup.name == groupName)
    }
    
    @Test("Creates group folder on disk")
    func createsGroupFolderOnDisk() throws {
        let sut = try makeSUT().sut
        let groupName = "NewTestGroup"
        
        _ = try sut.createGroup(name: groupName, category: existingCategoryName)
        
        let categoryFolder = try tempFolder.subfolder(named: existingCategoryName)
        #expect(categoryFolder.containsSubfolder(named: groupName))
    }
    
    @Test("Throws error when creating group with existing name")
    func throwsErrorWhenCreatingGroupWithExistingName() throws {
        let (sut, context) = try makeSUT()
        let existingGroup = makeGroup(name: existingGroupName)
        let existingCategory = try #require(try context.loadCategories().first)
        
        try context.saveGroup(existingGroup, in: existingCategory)
        
        #expect(throws: CodeLaunchError.groupNameTaken) {
            try sut.createGroup(name: existingGroupName, category: existingCategoryName)
        }
    }
}


// MARK: - GetGroup Tests
extension GroupHandlerTests {
    @Test("Returns existing group when found")
    func returnsExistingGroupWhenFound() throws {
        let (sut, context) = try makeSUT()
        let existingGroup = makeGroup(name: "FoundGroup")
        let existingCategory = try #require(try context.loadCategories().first)
        
        try context.saveGroup(existingGroup, in: existingCategory)
        
        let result = try sut.getGroup(named: "foundgroup") // case-insensitive
        
        #expect(result.name == existingGroup.name)
    }
    
    @Test("Creates new group from selection")
    func createsNewGroupFromSelection() throws {
        let mockPicker = MockPicker(requiredInputResponses: ["CreatedFromSelection"], permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let group = makeGroup(name: "TestGroup")
        let category = try #require(try context.loadCategories().first)
        
        try context.saveGroup(group, in: category)
        
        let result = try sut.getGroup(named: nil)
        
        #expect(result.name == group.name)
    }
}


// MARK: - RemoveGroup Tests
extension GroupHandlerTests {
    @Test("Removes group by name")
    func removesGroupByName() throws {
        let (sut, context) = try makeSUT(permissionResponses: [true])
        let groupToDelete = makeGroup(name: "GroupToDelete")
        let existingCategory = try #require(try context.loadCategories().first)
        
        try context.saveGroup(groupToDelete, in: existingCategory)
        
        try sut.removeGroup(name: "groupToDelete") // case-insensitive
        
        let groups = try context.loadGroups()
        #expect(groups.isEmpty)
    }
    
    @Test("Prompts user to select group when no name")
    func promptsUserToSelectGroupWhenNoName() throws {
        let groupToDelete = makeGroup(name: "GroupToDelete")
        let mockPicker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let category = try #require(try context.loadCategories().first)

        try context.saveGroup(groupToDelete, in: category)
        
        try sut.removeGroup(name: nil)
        
        let groups = try context.loadGroups()
        
        #expect(groups.isEmpty)
    }
    
    @Test("Requires confirmation before delete")
    func requiresConfirmationBeforeDelete() throws {
        let mockPicker = MockPicker(permissionResponses: [false], shouldThrowError: true)
        let (sut, context) = try makeSUT(picker: mockPicker)
        let groupToKeep = makeGroup(name: "GroupToKeep")
        let existingCategory = try #require(try context.loadCategories().first)
        
        try context.saveGroup(groupToKeep, in: existingCategory)
        
        #expect(throws: NSError.self) {
            try sut.removeGroup(name: "GroupToKeep")
        }
        
        let groups = try context.loadGroups()
        #expect(groups.count == 1)
        #expect(groups.first?.name == "GroupToKeep")
    }
}


// MARK: - SetMainProject Tests
extension GroupHandlerTests {
    @Test("Updates group shortcut to match project when group shortcut is empty")
    func updatesGroupShortcutToMatchProject() throws {
        let group = makeGroup()
        let project = makeProject(shortcut: "newshortcut")
        let (sut, context) = try makeSUT()
        let category = try #require(try context.loadCategories().first)
        
        #expect(group.shortcut == nil)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        
        #expect(updatedGroup.shortcut == project.shortcut)
    }
}


// MARK: - Helper Methods
private extension GroupHandlerTests {
    func makeSUT(picker: MockPicker? = nil, permissionResponses: [Bool] = []) throws -> (sut: GroupHandler, context: CodeLaunchContext) {
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        let existingCategoryFolder = try #require(try tempFolder.createSubfolderIfNeeded(withName: existingCategoryName))
        let category = makeCategory(name: existingCategoryFolder.name, path: existingCategoryFolder.path)
        
        try context.saveCategory(category)
        
        let mockPicker = picker ?? MockPicker(permissionResponses: permissionResponses)
        let mockCategorySelector = MockCategorySelector(context: context)
        let sut = GroupHandler(picker: mockPicker, context: context, categorySelector: mockCategorySelector)
        
        return (sut, context)
    }
}
