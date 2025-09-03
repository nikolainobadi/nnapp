//
//  Nnapp.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import SwiftPicker
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
    static func makeShell() -> Shell {
        return contextFactory.makeShell()
    }
    
    static func makePicker() -> CommandLinePicker {
        return contextFactory.makePicker()
    }
    
    static func makeContext() throws -> CodeLaunchContext {
        return try contextFactory.makeContext()
    }
    
    static func makeGroupCategorySelector(picker: CommandLinePicker, context: CodeLaunchContext) -> GroupCategorySelector {
        return contextFactory.makeGroupCategorySelector(picker: picker, context: context)
    }
    
    static func makeProjectGroupSelector(picker: CommandLinePicker, context: CodeLaunchContext) -> ProjectGroupSelector {
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
}


// MARK: - Dependencies
protocol ContextFactory {
    func makeShell() -> Shell
    func makePicker() -> CommandLinePicker
    func makeContext() throws -> CodeLaunchContext
    func makeGroupCategorySelector(picker: CommandLinePicker, context: CodeLaunchContext) -> GroupCategorySelector
    func makeProjectGroupSelector(picker: CommandLinePicker, context: CodeLaunchContext) -> ProjectGroupSelector
}
