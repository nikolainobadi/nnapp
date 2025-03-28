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
}


// MARK: - Dependencies
protocol ContextFactory {
    func makeShell() -> Shell
    func makePicker() -> Picker
    func makeContext() throws -> CodeLaunchContext
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
}
