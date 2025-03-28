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
        let shell = MockShell()
        let factory = MockContextFactory(shell: shell)
        let context = try factory.makeContext()
        let category = makeCategory()
        
        try context.saveCatgory(category)
        try runCommand(factory, folderType: .category)
        
        #expect(shell.printedCommands.count == 1)
        #expect(shell.printedCommands.contains(where: { $0.contains(category.path) }))
    }
    
    @Test("Opens Category folder when both name and -c are passed as args")
    func opensCategoryFolderWithNameArg() throws {
        let shell = MockShell()
        let factory = MockContextFactory(shell: shell)
        let context = try factory.makeContext()
        let category = makeCategory()
        
        try context.saveCatgory(category)
        try runCommand(factory, name: category.name, folderType: .category)
        
        #expect(shell.printedCommands.count == 1)
        #expect(shell.printedCommands.contains(where: { $0.contains(category.path) }))
    }
    
    @Test("Opens Group folder when name and -g are passed as args")
    func opensGroupFolder() throws {
        let shell = MockShell()
        let factory = MockContextFactory(shell: shell)
        let context = try factory.makeContext()
        let category = makeCategory()
        let group = makeGroup()
        
        try context.saveCatgory(category)
        try context.saveGroup(group, in: category)
        try runCommand(factory, name: group.name, folderType: .group)
        
        let groupPath = try #require(group.path)
        
        #expect(shell.printedCommands.count == 1)
        #expect(shell.printedCommands.contains(where: { $0.contains(groupPath) }))
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


// MARK: - Helers
private extension FinderTests {
    func makeCategory(name: String = "iOSApps", path: String = "path/to/category") -> LaunchCategory {
        return .init(name: name, path: path)
    }
    
    func makeGroup(name: String = "MyGroup") -> LaunchGroup {
        return .init(name: name)
    }
}


// MARK: - Extension Dependencies
fileprivate extension LaunchFolderType {
    var argCharacter: Character {
        return rawValue.first!
    }
}
