////
////  AddProjectTests.swift
////  nnapp
////
////  Created by Nikolai Nobadi on 3/29/25.
////
//
//import Testing
//import CodeLaunchKit
//import SwiftPickerTesting
//@testable import nnapp
//
//@MainActor
//final class AddProjectTests: MainActorBaseAddTests {
//    private let existingGroupName = "Group1"
//    private let existingCategoryName = "Category1"
//
//    init() throws {
//        let testGroupFolder = TestFolder(name: existingGroupName, subFolders: [])
//        let testCategoryFolder = TestFolder(name: existingCategoryName, subFolders: [testGroupFolder])
//        
//        try super.init(testFolder: .init(name: "AddProjectTestRoot", subFolders: [testCategoryFolder]))
//    }
//}
//
//
//
//// MARK: - Unit Tests
//extension AddProjectTests {
//    @Test("Throws an error if no group is selected")
//    func throwsErrorWhenNoGroupSelected() {
//        do {
//            try runProjectCommand()
//            Issue.record("expected an error but none were thrown")
//        } catch { }
//    }
//    
//    @Test("Throws error if path from arg finds folder without a project type.")
//    func throwsErrorWhenNoProjecTypeExists() throws {
//        let factory = try makeFactory()
//        let nonProjectFolder = try tempFolder.createSubfolder(named: "NonProjectFolder")
//
//        do {
//            try runProjectCommand(factory, path: nonProjectFolder.path, group: existingGroupName)
//            Issue.record("expected an error but none were thrown")
//        } catch let codeLaunchError as CodeLaunchError {
//            switch codeLaunchError {
//            case .noProjectInFolder:
//                break
//            default:
//                Issue.record("unexpected error")
//            }
//        }
//    }
//    
//    @Test("Throws error if Project name is taken")
//    func throwsErrorWhenProjectNameTaken() throws {
//        let factory = try makeFactory()
//        let context = try factory.makeContext()
//        let group = try #require(context.loadGroups().first)
//        let existing = makeSwiftDataProject(name: "MyProject")
//        try context.saveProject(existing, in: group)
//
//        let tempProjectFolder = try tempFolder.createSubfolder(named: "MyProject")
//        try tempProjectFolder.createFile(named: "Package.swift")
//
//        do {
//            try runProjectCommand(factory, path: tempProjectFolder.path, group: existingGroupName)
//
//            Issue.record("expected an error but none were thrown")
//        } catch let codeLaunchError as CodeLaunchError {
//            switch codeLaunchError {
//            case .projectNameTaken:
//                break
//            default:
//                Issue.record("unexpected error")
//            }
//        }
//    }
//
//    @Test("Throws error if Project shortcut is taken")
//    func throwsErrorWhenProjectShortcutTaken() throws {
//        let factory = try makeFactory()
//        let context = try factory.makeContext()
//        let group = try #require(context.loadGroups().first)
//        let existing = makeSwiftDataProject(name: "OtherProject", shortcut: "dup")
//        try context.saveProject(existing, in: group)
//
//        let tempProjectFolder = try tempFolder.createSubfolder(named: "MyProject")
//        try tempProjectFolder.createFile(named: "Package.swift")
//
//        do {
//            try runProjectCommand(factory, path: tempProjectFolder.path, group: existingGroupName, shortcut: "dup")
//            Issue.record("expected an error but none were thrown")
//        } catch let codeLaunchError as CodeLaunchError {
//            switch codeLaunchError {
//            case .shortcutTaken:
//                break
//            default:
//                Issue.record("unexpected error")
//            }
//        }
//    }
//    
//    @Test("Moves Project folder to Group folder when necessary")
//    func movesProjectFolderWhenNecessary() throws {
//        let factory = try makeFactory()
//        let groupFolder = try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName)
//        let outsideFolder = try tempFolder.createSubfolder(named: "MyProject")
//        try outsideFolder.createFile(named: "Package.swift")
//
//        try runProjectCommand(factory, path: outsideFolder.path, group: existingGroupName)
//
//        #expect(groupFolder.containsSubfolder(named: "MyProject"))
//    }
//    
//    @Test("Does not move Project folder to Group folder if it is already there")
//    func doesNotMoveProjectFolderWhenAlreadyInGroupFolder() throws {
//        let factory = try makeFactory()
//        let groupFolder = try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName)
//        let projectFolder = try groupFolder.createSubfolder(named: "MyProject")
//        try projectFolder.createFile(named: "Package.swift")
//
//        try runProjectCommand(factory, path: projectFolder.path, group: existingGroupName)
//
//        #expect(groupFolder.containsSubfolder(named: "MyProject"))
//    }
//    
//    @Test("Saves new Project to selected Group")
//    func savesNewProjectToGroup() throws {
//        let factory = try makeFactory()
//        let groupFolder = try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName)
//        let projectFolder = try groupFolder.createSubfolder(named: "MyProject")
//        try projectFolder.createFile(named: "Package.swift")
//
//        let context = try factory.makeContext()
//        let before = try context.loadProjects()
//        #expect(before.isEmpty)
//
//        try runProjectCommand(factory, path: projectFolder.path, group: existingGroupName)
//
//        let after = try context.loadProjects()
//        let saved = try #require(after.first)
//
//        #expect(after.count == 1)
//        #expect(saved.name == "MyProject")
//    }
//    
//    @Test("Sets the Group shortcut when isMainProject is true", .disabled()) // TODO: - 
//    func updatesGroupShortcutWhenIsMainProjectIsTrue() throws {
//        let factory = try makeFactory()
//        let groupFolder = try tempFolder.subfolder(named: existingCategoryName).subfolder(named: existingGroupName)
//        let projectFolder = try groupFolder.createSubfolder(named: "MainApp")
//        try projectFolder.createFile(named: "Package.swift")
//
//        let shortcut = "mainapp"
//        try runProjectCommand(factory, path: projectFolder.path, group: existingGroupName, shortcut: shortcut, isMainProject: true)
//
//        let context = try factory.makeContext()
//        let groups = try context.loadGroups()
//        let group = try #require(groups.first)
//
//        #expect(group.shortcut == shortcut)
//    }
//}
//
//
//// MARK: - Factory
//private extension AddProjectTests {
//    func makeFactory() throws -> MockContextFactory {
//        let categoryFolder = try tempFolder.subfolder(named: existingCategoryName)
//        let groupFolder = try categoryFolder.subfolder(named: existingGroupName)
//        let picker = MockSwiftPicker(
//            inputResult: .init(defaultValue: "shortcut"),
//            selectionResult: .init(defaultSingle: .index(0))
//        )
//        let factory = MockContextFactory(picker: picker)
//        let context = try factory.makeContext()
//        let category = makeSwiftDataCategory(name: categoryFolder.name, path: categoryFolder.path)
//        let group = makeSwiftDataGroup(name: groupFolder.name)
//        try context.saveCategory(category)
//        try context.saveGroup(group, in: category)
//
//        return factory
//    }
//}
//
//
//// MARK: - Run Command
//private extension AddProjectTests {
//    func runProjectCommand(_ factory: MockContextFactory? = nil, path: String? = nil, group: String? = nil, shortcut: String? = nil, isMainProject: Bool = false) throws {
//        try runCommand(factory, argType: .project(path: path, group: group, shortcut: shortcut, isMainProject: isMainProject))
//    }
//}
