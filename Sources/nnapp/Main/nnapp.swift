//
//  Nnapp.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import NnShellKit
import SwiftPickerKit
import ArgumentParser

@main
struct Nnapp: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Utility to manage Xcode Projects and Swift Packages for quick launching with command-line.",
        version: "v0.6.0",
        subcommands: [
            Add.self,
            Create.self,
            Remove.self,
//            Evict.self, // TODO: - will enable soon
            List.self,
            Open.self,
            Finder.self,
            Script.self,
            SetMainProject.self
        ]
    )
    
    nonisolated(unsafe) static var contextFactory: ContextFactory = DefaultContextFactory()
}


// MARK: - Essential Factory Methods
extension Nnapp {
    static func makeShell() -> any Shell {
        return contextFactory.makeShell()
    }
    
    static func makePicker() -> any CommandLinePicker {
        return contextFactory.makePicker()
    }
    
    static func makeContext() throws -> CodeLaunchContext {
        return try contextFactory.makeContext()
    }
    
    static func makeGroupCategorySelector(picker: any CommandLinePicker, context: CodeLaunchContext) -> any GroupCategorySelector {
        return contextFactory.makeGroupCategorySelector(picker: picker, context: context)
    }
    
    static func makeProjectGroupSelector(picker: any CommandLinePicker, context: CodeLaunchContext) -> any ProjectGroupSelector {
        return contextFactory.makeProjectGroupSelector(picker: picker, context: context)
    }
}


// MARK: - Convenience Factory Methods
extension Nnapp {
    static func makeCategoryHandler() throws -> CategoryHandler {
        let picker = makePicker()
        let context = try makeContext()
        
        return .init(picker: picker, context: context)
    }
    
    static func makeGroupHandler() throws -> GroupHandler {
        let picker = makePicker()
        let context = try makeContext()
        let categorySelector = makeGroupCategorySelector(picker: picker, context: context)
        
        return .init(picker: picker, context: context, categorySelector: categorySelector)
    }
    
    static func makeProjectHandler() throws -> ProjectHandler {
        let shell = Nnapp.makeShell()
        let picker = Nnapp.makePicker()
        let context = try Nnapp.makeContext()
        let groupSelector = makeProjectGroupSelector(picker: picker, context: context)
        
        return .init(shell: shell, picker: picker, context: context, groupSelector: groupSelector)
    }
    
    static func makeOpenManager() throws -> OpenProjectHandler {
        let shell = makeShell()
        let picker = makePicker()
        let context = try makeContext()
        let ideLauncher = makeIDELauncher(shell: shell, picker: picker)
        let terminalManager = makeTerminalManager(shell: shell, context: context)
        let urlLauncher = makeURLLauncher(shell: shell, picker: picker)
        let branchSyncChecker = makeBranchSyncChecker(shell: shell)
        let branchStatusNotifier = makeBranchStatusNotifier()

        return .init(picker: picker, context: context, ideLauncher: ideLauncher, terminalManager: terminalManager, urlLauncher: urlLauncher, branchSyncChecker: branchSyncChecker, branchStatusNotifier: branchStatusNotifier)
    }
    
    static func makeIDELauncher(shell: Shell, picker: CommandLinePicker) -> IDELauncher {
        return .init(shell: shell, picker: picker)
    }
    
    static func makeTerminalManager(shell: Shell, context: CodeLaunchContext) -> TerminalManager {
        return .init(shell: shell, context: context)
    }
    
    static func makeURLLauncher(shell: Shell, picker: CommandLinePicker) -> URLLauncher {
        return .init(shell: shell, picker: picker)
    }

    static func makeBranchSyncChecker(shell: Shell) -> BranchSyncChecker {
        return DefaultBranchSyncChecker(shell: shell)
    }

    static func makeBranchStatusNotifier() -> BranchStatusNotifier {
        return DefaultBranchStatusNotifier()
    }
}


// MARK: - Dependencies
protocol ContextFactory {
    func makeShell() -> any Shell
    func makePicker() -> CommandLinePicker
    func makeContext() throws -> CodeLaunchContext
    func makeGroupCategorySelector(picker: CommandLinePicker, context: CodeLaunchContext) -> GroupCategorySelector
    func makeProjectGroupSelector(picker: CommandLinePicker, context: CodeLaunchContext) -> ProjectGroupSelector
}
