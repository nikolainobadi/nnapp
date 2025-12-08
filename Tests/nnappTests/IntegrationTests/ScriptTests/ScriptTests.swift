////
////  ScriptTests.swift
////  nnapp
////
////  Created by Nikolai Nobadi on 3/29/25.
////
//
//import Testing
//import SwiftPickerTesting
//@testable import nnapp
//
//private let testScript = "echo hi"
//private let argScript = "echo hey"
//private let inputScript = "echo there"
//private let removeScript = "echo remove"
//
//@MainActor
//final class ScriptTests {
//    @Test("Shows message when no launch script is configured")
//    func showReportsNoScript() throws {
//        let factory = MockContextFactory()
//        let output = try runCommand(factory, subcommand: .show)
//        #expect(output.contains("No launch script configured"))
//    }
//
//    @Test("Displays saved launch script")
//    func showDisplaysScript() throws {
//        let factory = MockContextFactory()
//        let context = try factory.makeContext()
//        context.saveLaunchScript(testScript)
//
//        let output = try runCommand(factory, subcommand: .show)
//        #expect(output == testScript)
//    }
//
//    @Test("Saves launch script from argument")
//    func setScriptWithArg() throws {
//        let factory = MockContextFactory()
//        let context = try factory.makeContext()
//        try runCommand(factory, subcommand: .set(argScript))
//        #expect(context.loadLaunchScript() == argScript)
//    }
//
//    @Test("Saves launch script from user input")
//    func setScriptFromInput() throws {
//        let picker = MockSwiftPicker(inputResult: .init(type: .ordered([inputScript])))
//        let factory = MockContextFactory(picker: picker)
//        let context = try factory.makeContext()
//        try runCommand(factory, subcommand: .set(nil))
//        #expect(context.loadLaunchScript() == inputScript)
//    }
//
//    @Test("Shows message when deleting nonexistent script")
//    func deleteNoScript() throws {
//        let factory = MockContextFactory()
//        let output = try runCommand(factory, subcommand: .delete)
//        #expect(output.contains("No launch script configured"))
//    }
//
//    @Test("Deletes existing launch script after confirmation")
//    func deleteScript() throws {
//        let picker = MockSwiftPicker(permissionResult: .init(defaultValue: true))
//        let factory = MockContextFactory(picker: picker)
//        let context = try factory.makeContext()
//        context.saveLaunchScript(removeScript)
//
//        let output = try runCommand(factory, subcommand: .delete)
//        #expect(context.loadLaunchScript() == nil)
//        #expect(output.contains("Launch script deleted"))
//        #expect(picker.capturedPermissionPrompts.contains(where: { $0.contains("Delete the existing launch script?") }))
//    }
//}
//
//
//// MARK: - Helpers
//private enum Subcommand {
//    case show
//    case set(String?)
//    case delete
//}
//
//@MainActor
//@discardableResult
//private func runCommand(_ factory: MockContextFactory, subcommand: Subcommand) throws -> String {
//    var args = ["script"]
//    switch subcommand {
//    case .show:
//        args.append("show")
//    case .set(let script):
//        args.append("set")
//        if let script { args.append(script) }
//    case .delete:
//        args.append("delete")
//    }
//    return try Nnapp.testRun(contextFactory: factory, args: args)
//}
