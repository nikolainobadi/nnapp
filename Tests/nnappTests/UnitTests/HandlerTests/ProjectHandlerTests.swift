//
//  ProjectHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 9/2/25.
//

import Testing
import Foundation
import Files
import SwiftPicker
@testable import nnapp

@MainActor
final class ProjectHandlerTests: MainActorTempFolderDatasource {
    private let projectName = "TestProject"
    private let existingGroupName = "TestGroup"
    private let existingCategoryName = "TestCategory"
    
    init() throws {
        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])
        
        try super.init(testFolder: .init(name: "ProjectHandlerTests", subFolders: [testCategoryFolder]))
    }
}


// MARK: - Add Project Tests
extension ProjectHandlerTests {
    @Test("Adds project with provided path")
    func addsProjectWithProvidedPath() throws {
        let (sut, context) = try makeSUT()
        let group = try setupTestGroup(context: context)
        let projectFolder = try createSwiftPackage(named: projectName, in: tempFolder)
        
        try sut.addProject(
            path: projectFolder.path,
            group: group.name,
            shortcut: nil,
            isMainProject: false,
            fromDesktop: false
        )
        
        let projects = try context.loadProjects()
        let savedProject = try #require(projects.first)
        
        #expect(projects.count == 1)
        #expect(savedProject.name == projectName)
        #expect(savedProject.type == .package)
    }
    
    @Test("Adds project from group folder selection", .disabled())
    func addsProjectFromGroupFolderSelection() throws {
        let mockPicker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let group = try setupTestGroup(context: context)
        
        // Create a Swift package in the group folder
        let groupFolder = try #require(try tempFolder.subfolder(named: existingGroupName))
        _ = try createSwiftPackage(named: projectName, in: groupFolder)
        
        try sut.addProject(
            path: nil,
            group: group.name,
            shortcut: nil,
            isMainProject: false,
            fromDesktop: false
        )
        
        let projects = try context.loadProjects()
        let savedProject = try #require(projects.first)
        
        #expect(projects.count == 1)
        #expect(savedProject.name == projectName)
        #expect(savedProject.type == .package)
    }
    
    @Test("Adds project from desktop when fromDesktop flag is true")
    func addsProjectFromDesktopWhenFlagIsTrue() throws {
        let fakeDesktop = try createFakeDesktop()
        _ = try createSwiftPackage(named: projectName, in: fakeDesktop)
        
        let (sut, context) = try makeSUT(desktopPath: fakeDesktop.path)
        let group = try setupTestGroup(context: context)
        
        try sut.addProject(
            path: nil,
            group: group.name,
            shortcut: nil,
            isMainProject: false,
            fromDesktop: true
        )
        
        let projects = try context.loadProjects()
        let savedProject = try #require(projects.first)
        
        #expect(projects.count == 1)
        #expect(savedProject.name == projectName)
        #expect(savedProject.type == .package)
    }
    
    @Test("Sets group shortcut when isMainProject is true")
    func setsGroupShortcutWhenIsMainProjectIsTrue() throws {
        let (sut, context) = try makeSUT()
        let group = try setupTestGroup(context: context)
        let projectFolder = try createSwiftPackage(named: projectName, in: tempFolder)
        let shortcut = "testshortcut"
        
        #expect(group.shortcut == nil)
        
        try sut.addProject(
            path: projectFolder.path,
            group: group.name,
            shortcut: shortcut,
            isMainProject: true,
            fromDesktop: false
        )
        
        let updatedGroup = try #require(try context.loadGroups().first)
        
        #expect(updatedGroup.shortcut == shortcut)
    }
    
    @Test("Prompts for main project when group has no shortcut")
    func promptsForMainProjectWhenGroupHasNoShortcut() throws {
        let responses = [
            true, // would you like to add shorcut?
            true, // is this gh url correct?
            true // would you like to make this main project for group?
        ]
        let mockPicker = MockPicker(permissionResponses: responses)
        let (sut, context) = try makeSUT(picker: mockPicker)
        let group = try setupTestGroup(context: context)
        let projectFolder = try createSwiftPackage(named: projectName, in: tempFolder)
        let shortcut = "testshortcut"
        
        #expect(group.shortcut == nil)
        
        try sut.addProject(
            path: projectFolder.path,
            group: group.name,
            shortcut: shortcut,
            isMainProject: false,
            fromDesktop: false
        )
        
        let updatedGroup = try #require(try context.loadGroups().first)
        
        #expect(updatedGroup.shortcut == shortcut)
    }
    
    @Test("Throws error when project name already exists")
    func throwsErrorWhenProjectNameAlreadyExists() throws {
        let (sut, context) = try makeSUT()
        let group = try setupTestGroup(context: context)
        let existingProject = makeProject(name: projectName)
        
        try context.saveProject(existingProject, in: group)
        
        let projectFolder = try createSwiftPackage(named: projectName, in: tempFolder)
        
        #expect(throws: CodeLaunchError.projectNameTaken) {
            try sut.addProject(
                path: projectFolder.path,
                group: group.name,
                shortcut: nil,
                isMainProject: false,
                fromDesktop: false
            )
        }
    }
    
    @Test("Throws error when no valid projects found on desktop")
    func throwsErrorWhenNoValidProjectsFoundOnDesktop() throws {
        let fakeDesktop = try createFakeDesktop()
        try fakeDesktop.createSubfolder(named: "NotAProject")
        
        let (sut, context) = try makeSUT(desktopPath: fakeDesktop.path)
        let group = try setupTestGroup(context: context)
        
        #expect(throws: CodeLaunchError.noProjectInFolder) {
            try sut.addProject(
                path: nil,
                group: group.name,
                shortcut: nil,
                isMainProject: false,
                fromDesktop: true
            )
        }
    }
    
    @Test("Moves project folder to group folder when necessary", .disabled())
    func movesProjectFolderToGroupFolderWhenNecessary() throws {
        let (sut, context) = try makeSUT()
        let group = try setupTestGroup(context: context)
        let projectFolder = try createSwiftPackage(named: projectName, in: tempFolder)
        
        // Verify project is not in group folder initially
        let groupFolder = try #require(try tempFolder.subfolder(named: existingGroupName))
        #expect(!groupFolder.containsSubfolder(named: projectName))
        
        try sut.addProject(
            path: projectFolder.path,
            group: group.name,
            shortcut: nil,
            isMainProject: false,
            fromDesktop: false
        )
        
        // Verify project was moved to group folder
        #expect(groupFolder.containsSubfolder(named: projectName))
    }
}


// MARK: - Remove Project Tests
extension ProjectHandlerTests {
    @Test("Removes project by name")
    func removesProjectByName() throws {
        let mockPicker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let group = try setupTestGroup(context: context)
        let project = makeProject(name: projectName, shortcut: "testcut")
        
        try context.saveProject(project, in: group)
        
        let projects = try context.loadProjects()
        #expect(projects.count == 1)
        
        try sut.removeProject(name: projectName, shortcut: nil)
        
        let remainingProjects = try context.loadProjects()
        #expect(remainingProjects.isEmpty)
    }
    
    @Test("Removes project by shortcut")
    func removesProjectByShortcut() throws {
        let mockPicker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let group = try setupTestGroup(context: context)
        let shortcut = "testcut"
        let project = makeProject(name: projectName, shortcut: shortcut)
        
        try context.saveProject(project, in: group)
        
        let projects = try context.loadProjects()
        #expect(projects.count == 1)
        
        try sut.removeProject(name: nil, shortcut: shortcut)
        
        let remainingProjects = try context.loadProjects()
        #expect(remainingProjects.isEmpty)
    }
    
    @Test("Prompts user to select project when no parameters provided")
    func promptsUserToSelectProjectWhenNoParameters() throws {
        let mockPicker = MockPicker(permissionResponses: [true])
        let (sut, context) = try makeSUT(picker: mockPicker)
        let group = try setupTestGroup(context: context)
        let project = makeProject(name: projectName, shortcut: "testcut")
        
        try context.saveProject(project, in: group)
        
        let projects = try context.loadProjects()
        #expect(projects.count == 1)
        
        try sut.removeProject(name: nil, shortcut: nil)
        
        let remainingProjects = try context.loadProjects()
        #expect(remainingProjects.isEmpty)
    }
    
    @Test("Requires confirmation before deletion")
    func requiresConfirmationBeforeDeletion() throws {
        let mockPicker = MockPicker(permissionResponses: [false], shouldThrowError: true)
        let (sut, context) = try makeSUT(picker: mockPicker)
        let group = try setupTestGroup(context: context)
        let project = makeProject(name: projectName, shortcut: "testcut")
        
        try context.saveProject(project, in: group)
        
        let projects = try context.loadProjects()
        #expect(projects.count == 1)
        
        #expect(throws: NSError.self) {
            try sut.removeProject(name: projectName, shortcut: nil)
        }
        
        let remainingProjects = try context.loadProjects()
        #expect(remainingProjects.count == 1)
        #expect(remainingProjects.first?.name == projectName)
    }
}


// MARK: - Helper Methods
private extension ProjectHandlerTests {
    func makeSUT(picker: MockPicker? = nil, permissionResponses: [Bool] = [], desktopPath: String? = nil) throws -> (sut: ProjectHandler, context: CodeLaunchContext) {
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        let existingCategoryFolder = try #require(try tempFolder.createSubfolderIfNeeded(withName: existingCategoryName))
        let category = makeCategory(name: existingCategoryFolder.name, path: existingCategoryFolder.path)
        
        try context.saveCategory(category)
        
        let picker = picker ?? MockPicker(permissionResponses: permissionResponses)
        let groupSelector = MockGroupSelector(context: context)
        
        let shell = MockShell()
        let sut = ProjectHandler(shell: shell, picker: picker, context: context, groupSelector: groupSelector, desktopPath: desktopPath)
        
        return (sut, context)
    }
    
    /// Creates a fake Desktop folder in the temp directory for testing --from-desktop
    func createFakeDesktop() throws -> Folder {
        return try tempFolder.createSubfolder(named: "Desktop")
    }
    
    /// Creates a Swift package folder with Package.swift file
    func createSwiftPackage(named name: String, in folder: Folder) throws -> Folder {
        let packageFolder = try folder.createSubfolder(named: name)
        let packageContent = """
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "\(name)",
    products: [
        .library(name: "\(name)", targets: ["\(name)"])
    ],
    targets: [
        .target(name: "\(name)")
    ]
)
"""
        try packageFolder.createFile(named: "Package.swift", contents: Data(packageContent.utf8))
        return packageFolder
    }
    
    func setupTestGroup(context: CodeLaunchContext) throws -> LaunchGroup {
        let category = try #require(try context.loadCategories().first)
        _ = try #require(try tempFolder.createSubfolderIfNeeded(withName: existingGroupName))
        let group = makeGroup(name: existingGroupName)
        
        try context.saveGroup(group, in: category)
        return group
    }
}
