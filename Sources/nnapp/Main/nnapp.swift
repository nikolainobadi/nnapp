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

    static func makeFolderBrowser(picker: any CommandLinePicker) -> any FolderBrowser {
        return contextFactory.makeFolderBrowser(picker: picker)
    }
}


// MARK: - Convenience Factory Methods
extension Nnapp {
    static func makeCategoryHandler() throws -> CategoryHandler {
        let picker = makePicker()
        let context = try makeContext()
        let folderBrowser = makeFolderBrowser(picker: picker)
        
        return .init(picker: picker, context: context, folderBrowser: folderBrowser)
    }
    
    static func makeGroupHandler() throws -> GroupHandler {
        let picker = makePicker()
        let context = try makeContext()
        let categorySelector = makeGroupCategorySelector(picker: picker, context: context)
        let folderBrowser = makeFolderBrowser(picker: picker)
        
        return .init(picker: picker, context: context, categorySelector: categorySelector, folderBrowser: folderBrowser)
    }
    
    static func makeProjectHandler() throws -> ProjectHandler {
        let shell = Nnapp.makeShell()
        let picker = Nnapp.makePicker()
        let context = try Nnapp.makeContext()
        let groupSelector = makeProjectGroupSelector(picker: picker, context: context)
        let folderBrowser = makeFolderBrowser(picker: picker)

        return .init(shell: shell, picker: picker, context: context, groupSelector: groupSelector, folderBrowser: folderBrowser)
    }

    static func makeListHandler() throws -> ListHandler {
        fatalError() // TODO: - 
//        let picker = makePicker()
//        let context = try makeContext()
//        let console = contextFactory.makeConsoleOutput()
//
//        return .init(picker: picker, context: context, console: console)
    }

    static func makeFinderHandler() throws -> FinderHandler {
        let shell = makeShell()
        let picker = makePicker()
        let context = try makeContext()
        let console = contextFactory.makeConsoleOutput()

        return .init(shell: shell, picker: picker, context: context, console: console)
    }

    static func makeOpenManager() throws -> OpenProjectHandler {
        let shell = makeShell()
        let picker = makePicker()
        let context = try makeContext()
        let ideLauncher = makeIDELauncher(shell: shell, picker: picker)
        let terminalManager = makeTerminalManager(shell: shell, context: context)
        let urlLauncher = makeURLLauncher(shell: shell, picker: picker)
        let branchSyncChecker = makeBranchSyncChecker(shell: shell)
        let branchStatusNotifier = makeBranchStatusNotifier(shell: shell)

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

    static func makeBranchSyncChecker(shell: any Shell) -> any BranchSyncChecker {
        return contextFactory.makeBranchSyncChecker(shell: shell)
    }

    static func makeBranchStatusNotifier(shell: any Shell) -> any BranchStatusNotifier {
        return contextFactory.makeBranchStatusNotifier(shell: shell)
    }
}


// MARK: - Dependencies
protocol ContextFactory {
    func makeShell() -> any Shell
    func makePicker() -> any CommandLinePicker
    func makeContext() throws -> CodeLaunchContext
    func makeConsoleOutput() -> any ConsoleOutput
    func makeFolderBrowser(picker: any CommandLinePicker) -> any FolderBrowser
    func makeGroupCategorySelector(picker: CommandLinePicker, context: CodeLaunchContext) -> any GroupCategorySelector
    func makeProjectGroupSelector(picker: CommandLinePicker, context: CodeLaunchContext) -> any ProjectGroupSelector
    func makeBranchSyncChecker(shell: any Shell) -> any BranchSyncChecker
    func makeBranchStatusNotifier(shell: any Shell) -> any BranchStatusNotifier
}
