//
//  FinderTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Files
import Testing
@testable import nnapp

@MainActor
final class FinderTests {
    @Test("Starting values are empty")
    func emptyStartingValues() {
        let shell = MockShell()
        
        #expect(shell.printedCommands.isEmpty)
    }
    
    @Test("Opens Category folder when only -c is passed as arg")
    func opensCategoryFolder() throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        
        try context.saveCatgory(category)
        try runCommand(factory, folderType: .category)
        try assertShell(shell, contains: category.path)
    }
    
    @Test("Opens Category folder when both name and -c are passed as args")
    func opensCategoryFolderWithNameArg() throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        
        try context.saveCatgory(category)
        try runCommand(factory, name: category.name, folderType: .category)
        try assertShell(shell, contains: category.path)
    }
    
    @Test("Opens Group folder when -g is passed as arg")
    func opensGroupFolder() throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup()
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try runCommand(factory, folderType: .group)
        try assertShell(shell, contains: group.path)
    }
    
    @Test("Opens Group folder when both name and -g are passed as args")
    func opensGroupFolderWithNameArg() throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup()
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try runCommand(factory, name: group.name, folderType: .group)
        try assertShell(shell, contains: group.path)
    }
    
    @Test("Opens Group folder when both shortcut (as name) and -g are passed as args")
    func opensGroupFolderWithShortcutArg() throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup(shortcut: "shortcut")
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try runCommand(factory, name: group.shortcut, folderType: .group)
        try assertShell(shell, contains: group.path)
    }
    
    @Test("Opens Project folder when -p is passed as arg")
    func opensProjectFolder() throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup()
        let project = makeProject()
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try runCommand(factory, folderType: .project)
        try assertShell(shell, contains: group.path)
    }
    
    @Test("Opens Project folder when both name and -p are passed as args")
    func opensProjectFolderWithNameArg() throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup()
        let project = makeProject()
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try runCommand(factory, name: project.name, folderType: .project)
        try assertShell(shell, contains: group.path)
    }
    
    @Test("Opens Project folder when both shortcut (as name) and -p are passed as args")
    func opensProjectFolderWithShortcutArg() throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup(shortcut: "shortcut")
        let project = makeProject(shorcut: group.shortcut)
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try runCommand(factory, name: project.shortcut, folderType: .project)
        try assertShell(shell, contains: group.path)
    }
}


// MARK: - Factory
extension FinderTests {
    func makeTestObjects() -> (factory: MockContextFactory, shell: MockShell) {
        let shell = MockShell()
        let factory = MockContextFactory(shell: shell)
        
        return (factory, shell)
    }
    
    func makeCategory(name: String = "iOSApps", path: String = "path/to/category") -> LaunchCategory {
        return .init(name: name, path: path)
    }
    
    func makeGroup(name: String = "MyGroup", shortcut: String? = nil) -> LaunchGroup {
        return .init(name: name, shortcut: shortcut)
    }
    
    func makeProject(name: String = "MyProject", shorcut: String? = nil) -> LaunchProject {
        return .init(name: name, shortcut: shorcut, type: .package, remote: nil, links: [])
    }
}


// MARK: - Run
private extension FinderTests {
    func runCommand(_ factory: MockContextFactory, name: String? = nil, folderType: LaunchFolderType = .project) throws {
        var args = ["finder"]
        
        if let name {
            args.append(name)
        }
        
        args.append("-\(folderType.argCharacter)")
        
        try Nnapp.testRun(contextFactory: factory, args: args)
    }
}


// MARK: - Assertion Helpers
private extension FinderTests {
    func assertShell(_ shell: MockShell, contains path: String?) throws {
        let path = try #require(path)
        
        #expect(shell.printedCommands.count == 1)
        #expect(shell.printedCommands.contains(where: { $0.contains(path) }))
    }
}


// MARK: - Extension Dependencies
fileprivate extension LaunchFolderType {
    var argCharacter: Character {
        return rawValue.first!
    }
}
