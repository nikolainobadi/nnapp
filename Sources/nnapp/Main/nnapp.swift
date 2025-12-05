//
//  Nnapp.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import NnShellKit
import CodeLaunchKit
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

    static func makeRepository() throws -> SwiftDataLaunchRepository {
        return .init(context: try makeContext())
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
