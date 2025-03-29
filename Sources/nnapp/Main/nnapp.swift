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
        subcommands: [Add.self, Create.self, List.self, Open.self, Remove.self, Evict.self, Finder.self]
    )
    
    nonisolated(unsafe) static var contextFactory: ContextFactory = DefaultContextFactory()
}

extension Nnapp {
    static func makeShell() -> Shell {
        return contextFactory.makeShell()
    }
    
    static func makePicker() -> Picker {
        return contextFactory.makePicker()
    }
    
    static func makeContext() throws -> CodeLaunchContext {
        return try contextFactory.makeContext()
    }
    
    static func makeGroupCategorySelector(picker: Picker, context: CodeLaunchContext) -> GroupCategorySelector {
        return contextFactory.makeGroupCategorySelector(picker: picker, context: context)
    }
    
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
}


// MARK: - Dependencies
protocol ContextFactory {
    func makeShell() -> Shell
    func makePicker() -> Picker
    func makeContext() throws -> CodeLaunchContext
    func makeGroupCategorySelector(picker: Picker, context: CodeLaunchContext) -> GroupCategorySelector
}

final class DefaultContextFactory: ContextFactory {
    func makeShell() -> Shell {
        return DefaultShell()
    }
    
    func makePicker() -> Picker {
        return SwiftPicker()
    }
    
    func makeContext() throws -> CodeLaunchContext {
        return try CodeLaunchContext()
    }
    
    func makeGroupCategorySelector(picker: Picker, context: CodeLaunchContext) -> GroupCategorySelector {
        return CategoryHandler(picker: picker, context: context)
    }
}
