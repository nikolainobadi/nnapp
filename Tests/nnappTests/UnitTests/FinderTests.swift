//
//  FinderTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Testing
@testable import nnapp

@MainActor
struct FinderTests {
    @Test("Starting values are empty")
    func emptyStartingValues() {
        let shell = MockShell()
        
        #expect(shell.printedCommands.isEmpty)
    }
    
    @Test("Opens Category folder when only -c is passed as arg", arguments: [nil, "categoryName"])
    func opensCategoryFolder(name: String?) throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let categoryName = name ?? "categoryName"
        let category = makeCategory(name: categoryName)
        
        try context.saveCatgory(category)
        try runCommand(factory, name: name, folderType: .category)
        try assertShell(shell, contains: category.path)
    }
    
    @Test("Opens Group folder when -g is passed as arg", arguments: [
        GroupAndProjectTestInfo(),
        GroupAndProjectTestInfo(name: "groupName"),
        GroupAndProjectTestInfo(name: "groupName", shortcut: "groupShortcut", useShortcut: true),
    ])
    func opensGroupFolder(info: GroupAndProjectTestInfo) throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup(name: info.name ?? "groupName", shortcut: info.shortcut)
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try runCommand(factory, name: info.nameArg, folderType: .group)
        try assertShell(shell, contains: group.path)
    }
    
    @Test("Opens Project folder when -p is passed as arg", arguments: [
        GroupAndProjectTestInfo(),
        GroupAndProjectTestInfo(name: "projectName"),
        GroupAndProjectTestInfo(name: "projectName", shortcut: "projectShortcut", useShortcut: true),
    ])
    func opensProjectFolder(info: GroupAndProjectTestInfo) throws {
        let (factory, shell) = makeTestObjects()
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup()
        let project = makeProject(name: info.name ?? "projectName", shorcut: info.shortcut)
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try context.saveProject(project, in: group)
        try runCommand(factory, name: info.nameArg, folderType: .project)
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


// MARK: - Dependencies
extension FinderTests {
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
}

// MARK: - Extension Dependencies
fileprivate extension LaunchFolderType {
    var argCharacter: Character {
        return rawValue.first!
    }
}
