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
        subcommands: [Add.self, Create.self, List.self, Open.self, Remove.self, Evict.self]
    )
    
    nonisolated(unsafe) static var contextFactory: ContextFactory = DefaultContextFactory()
}


// MARK: - Factory Methods
extension ParsableCommand {
    var shell: Shell {
        return Nnapp.contextFactory.makeShell()
    }
    
    var picker: Picker {
        return Nnapp.contextFactory.makePicker()
    }
    
    func makeContext() throws -> CodeLaunchContext {
        return try Nnapp.contextFactory.makeContext()
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
