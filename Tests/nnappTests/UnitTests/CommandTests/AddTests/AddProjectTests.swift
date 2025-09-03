//
//  AddProjectTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
@testable import nnapp

@MainActor
final class AddProjectTests: MainActorBaseAddTests {
    private let existingGroupName = "Group1"
    private let existingCategoryName = "Category1"

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
        #expect(throws: (any Error).self) {
            try runProjectCommand()
        }
    }
    
    @Test("Throws error if path from arg finds folder without a project type.")
    func throwsErrorWhenNoProjecTypeExists() throws {
        let factory = try #require(try makeFactory())
        let nonProjectFolder = try #require(try tempFolder.createSubfolder(named: "NonProjectFolder"))

        #expect(throws: CodeLaunchError.noProjectInFolder) {
            try runProjectCommand(factory, path: nonProjectFolder.path, group: existingGroupName)
        }
    }
    
    @Test("Throws error if Project name is taken")
    func throwsErrorWhenProjectNameTaken() throws {
        let factory = try #require(try makeFactory())
        let context = try factory.makeContext()
        let group = try #require(context.loadGroups().first)
        let existing = makeProject(name: "MyProject")
        try context.saveProject(existing, in: group)

        let tempProjectFolder = try #require(try tempFolder.createSubfolder(named: "MyProject"))
        try tempProjectFolder.createFile(named: "Package.swift")

        #expect(throws: CodeLaunchError.projectNameTaken) {
            try runProjectCommand(factory, path: tempProjectFolder.path, group: existingGroupName)
        }
    }

    @Test("Throws error if Project shortcut is taken")
    func throwsErrorWhenProjectShortcutTaken() throws {
        let factory = try #require(try makeFactory())
        let context = try factory.makeContext()
        let group = try #require(context.loadGroups().first)
        let existing = makeProject(name: "OtherProject", shortcut: "dup")
        try context.saveProject(existing, in: group)

        let tempProjectFolder = try #require(try tempFolder.createSubfolder(named: "MyProject"))
        try tempProjectFolder.createFile(named: "Package.swift")

        #expect(throws: CodeLaunchError.shortcutTaken) {
            try runProjectCommand(factory, path: tempProjectFolder.path, group: existingGroupName, shortcut: "dup")
        }
    }
    
    @Test("Moves Project folder to Group folder when necessary")
    func movesProjectFolderWhenNecessary() throws {
        let factory = try #require(try makeFactory())
        let groupFolder = try #require(try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName))
        let outsideFolder = try #require(try tempFolder.createSubfolder(named: "MyProject"))
        try outsideFolder.createFile(named: "Package.swift")

        try runProjectCommand(factory, path: outsideFolder.path, group: existingGroupName)

        #expect(groupFolder.containsSubfolder(named: "MyProject"))
    }
    
    @Test("Does not move Project folder to Group folder if it is already there")
    func doesNotMoveProjectFolderWhenAlreadyInGroupFolder() throws {
        let factory = try #require(try makeFactory())
        let groupFolder = try #require(try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName))
        let projectFolder = try #require(try groupFolder.createSubfolder(named: "MyProject"))
        try projectFolder.createFile(named: "Package.swift")

        try runProjectCommand(factory, path: projectFolder.path, group: existingGroupName)

        #expect(groupFolder.containsSubfolder(named: "MyProject"))
    }
    
    @Test("Saves new Project to selected Group")
    func savesNewProjectToGroup() throws {
        let factory = try #require(try makeFactory())
        let groupFolder = try #require(try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName))
        let projectFolder = try #require(try groupFolder.createSubfolder(named: "MyProject"))
        try projectFolder.createFile(named: "Package.swift")

        let context = try factory.makeContext()
        let before = try context.loadProjects()
        #expect(before.isEmpty)

        try runProjectCommand(factory, path: projectFolder.path, group: existingGroupName)

        let after = try context.loadProjects()
        let saved = try #require(after.first)

        #expect(after.count == 1)
        #expect(saved.name == "MyProject")
    }
    
    @Test("Sets the Group shortcut when isMainProject is true")
    func updatesGroupShortcutWhenIsMainProjectIsTrue() throws {
        let factory = try #require(try makeFactory())
        let groupFolder = try #require(try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName))
        let projectFolder = try #require(try groupFolder.createSubfolder(named: "MainApp"))
        try projectFolder.createFile(named: "Package.swift")

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
    func makeFactory() throws -> MockContextFactory {
        let categoryFolder = try #require(try tempFolder.subfolder(named: existingCategoryName))
        let groupFolder = try #require(try categoryFolder.subfolder(named: existingGroupName))
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        let category = makeCategory(name: categoryFolder.name, path: categoryFolder.path)
        let group = makeGroup(name: groupFolder.name)
        try context.saveCategory(category)
        try context.saveGroup(group, in: category)
        
        return factory
    }
}


// MARK: - Run Command
private extension AddProjectTests {
    func runProjectCommand(_ factory: MockContextFactory? = nil, path: String? = nil, group: String? = nil, shortcut: String? = nil, isMainProject: Bool = false) throws {
        try runCommand(factory, argType: .project(path: path, group: group, shortcut: shortcut, isMainProject: isMainProject))
    }
}
