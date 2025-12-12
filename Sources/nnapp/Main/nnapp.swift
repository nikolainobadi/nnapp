//
//  Nnapp.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import NnShellKit
import CodeLaunchKit
import ArgumentParser

@main
struct Nnapp: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Utility to manage Xcode Projects and Swift Packages for quick launching with command-line.",
        version: "0.7.1",
        subcommands: [
            Add.self,
            Create.self,
            Remove.self,
//            Evict.self, // TODO: - will enable soon
            List.self,
            Open.self,
            Finder.self,
//            Script.self, // TODO: - will enable soon
            SetMainProject.self
        ]
    )
    
    nonisolated(unsafe) static var contextFactory: ContextFactory = DefaultContextFactory()
}


// MARK: - Essential Factory Methods
extension Nnapp {
    static func makeShell() -> any LaunchGitShell {
        return contextFactory.makeShell()
    }
    
    static func makePicker() -> any LaunchPicker {
        return contextFactory.makePicker()
    }

    static func makeRepository() throws -> SwiftDataLaunchRepository {
        return .init(context: try contextFactory.makeContext())
    }

    static func makeFolderBrowser(picker: any LaunchPicker) -> any DirectoryBrowser {
        return contextFactory.makeFolderBrowser(picker: picker)
    }
}


// MARK: - Dependencies
protocol ContextFactory {
    func makeShell() -> any LaunchGitShell
    func makePicker() -> any LaunchPicker
    func makeFileSystem() -> any FileSystem
    func makeConsoleOutput() -> any ConsoleOutput
    func makeContext() throws -> CodeLaunchContext
    func makeFolderBrowser(picker: any LaunchPicker) -> any DirectoryBrowser
}
