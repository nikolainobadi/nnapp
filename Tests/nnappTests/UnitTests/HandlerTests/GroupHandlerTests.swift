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
        let (sut, context) = try makeSUT()
        let group = makeGroup()
        let project = makeProject(shortcut: "newshortcut")
        let category = try #require(try context.loadCategories().first)
        
        #expect(group.shortcut == nil)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        
        #expect(updatedGroup.shortcut == project.shortcut)
    }
    
    @Test("Clears current main project shortcut when switching to new main project")
    func clearsPreviousMainProjectShortcut() throws {
        let shortcut = "groupShortcut"
        let picker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: picker)
        let group = makeGroup(shortcut: shortcut)
        let mainProject = makeProject(name: "MainProject", shortcut: group.shortcut)
        let otherProject = makeProject(name: "OtherProject")
        let category = try #require(try context.loadCategories().first)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(mainProject, in: group)
        try context.saveProject(otherProject, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        let updatedMainProject = try #require(updatedGroup.projects.first { $0.name == "MainProject" })
        let updatedOtherProject = try #require(updatedGroup.projects.first { $0.name == "OtherProject" })
        
        #expect(updatedMainProject.shortcut == nil)
        #expect(updatedOtherProject.shortcut == shortcut)
        #expect(updatedGroup.shortcut == shortcut)
    }
    
    @Test("Uses group shortcut when switching to project without shortcut")
    func usesGroupShortcutWhenProjectHasNone() throws {
        let group = makeGroup(shortcut: "groupcut")
        let mainProject = makeProject(name: "MainProject", shortcut: group.shortcut)
        let newProject = makeProject(name: "NewProject", shortcut: nil)
        let mockPicker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let category = try #require(try context.loadCategories().first)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(mainProject, in: group)
        try context.saveProject(newProject, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        let updatedMainProject = try #require(updatedGroup.projects.first { $0.name == "MainProject" })
        let updatedNewProject = try #require(updatedGroup.projects.first { $0.name == "NewProject" })
        
        #expect(updatedMainProject.shortcut == nil)
        #expect(updatedNewProject.shortcut == "groupcut")
        #expect(updatedGroup.shortcut == "groupcut")
    }
    
    @Test("Prompts for shortcut when neither group nor project has one")
    func promptsForShortcutWhenNeitherHasOne() throws {
        let group = makeGroup()
        let project = makeProject(name: "Project", shortcut: nil)
        let mockPicker = MockPicker(requiredInputResponses: ["newcut"])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let category = try #require(try context.loadCategories().first)
        
        #expect(group.shortcut == nil)
        #expect(project.shortcut == nil)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        let updatedProject = try #require(updatedGroup.projects.first { $0.name == "Project" })
        
        #expect(updatedProject.shortcut == "newcut")
        #expect(updatedGroup.shortcut == "newcut")
    }
    
    @Test("Handles switching from no main project to first main project")
    func handlesFirstMainProjectAssignment() throws {
        let group = makeGroup()
        let project = makeProject(name: "FirstMain", shortcut: "projcut")
        let (sut, context) = try makeSUT()
        let category = try #require(try context.loadCategories().first)
        
        #expect(group.shortcut == nil)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        let updatedProject = try #require(updatedGroup.projects.first { $0.name == "FirstMain" })
        
        #expect(updatedProject.shortcut == "projcut")
        #expect(updatedGroup.shortcut == "projcut")
    }
    
    @Test("Correctly identifies current main project by matching shortcuts")
    func correctlyIdentifiesMainProjectByShortcut() throws {
        let group = makeGroup(shortcut: "main")
        let mainProject = makeProject(name: "MainProject", shortcut: group.shortcut)
        let otherProject1 = makeProject(name: "Other1", shortcut: "other1")
        let otherProject2 = makeProject(name: "Other2", shortcut: "other2")
        let mockPicker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let category = try #require(try context.loadCategories().first)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(mainProject, in: group)
        try context.saveProject(otherProject1, in: group)
        try context.saveProject(otherProject2, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        let updatedMainProject = try #require(updatedGroup.projects.first { $0.name == "MainProject" })
        let updatedOther1 = try #require(updatedGroup.projects.first { $0.name == "Other1" })
        let updatedOther2 = try #require(updatedGroup.projects.first { $0.name == "Other2" })
        
        // Original main project should lose its shortcut
        #expect(updatedMainProject.shortcut == nil)
        // Other1 becomes new main project and gets group shortcut (MockPicker defaults to index 0)
        #expect(updatedOther1.shortcut == "main")
        #expect(updatedOther2.shortcut == "other2")
        #expect(updatedGroup.shortcut == "main")
    }
    
    @Test("Shows current main project message and requires confirmation")
    func showsCurrentMainProjectAndRequiresConfirmation() throws {
        let group = makeGroup(shortcut: "main")
        let mainProject = makeProject(name: "CurrentMain", shortcut: group.shortcut)
        let otherProject = makeProject(name: "Other", shortcut: "other")
        let mockPicker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let category = try #require(try context.loadCategories().first)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(mainProject, in: group)
        try context.saveProject(otherProject, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        let updatedMainProject = try #require(updatedGroup.projects.first { $0.name == "CurrentMain" })
        let updatedOtherProject = try #require(updatedGroup.projects.first { $0.name == "Other" })
        
        // Confirm the switch happened
        #expect(updatedMainProject.shortcut == nil)
        #expect(updatedOtherProject.shortcut == "main")
        #expect(updatedGroup.shortcut == "main")
    }
    
    @Test("Cancels operation when user denies confirmation")
    func cancelsOperationWhenUserDeniesConfirmation() throws {
        let group = makeGroup(shortcut: "main")
        let mainProject = makeProject(name: "CurrentMain", shortcut: "main")
        let otherProject = makeProject(name: "Other", shortcut: "other")
        let mockPicker = MockPicker(permissionResponses: [false])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let category = try #require(try context.loadCategories().first)
        
        try context.saveGroup(group, in: category)
        try context.saveProject(mainProject, in: group)
        try context.saveProject(otherProject, in: group)
        try sut.setMainProject(group: group.name)
        
        let updatedGroup = try #require(try context.loadGroups().first)
        let updatedMainProject = try #require(updatedGroup.projects.first { $0.name == "CurrentMain" })
        let updatedOtherProject = try #require(updatedGroup.projects.first { $0.name == "Other" })
        
        // Confirm no changes were made
        #expect(updatedMainProject.shortcut == "main")
        #expect(updatedOtherProject.shortcut == "other")
        #expect(updatedGroup.shortcut == "main")
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
