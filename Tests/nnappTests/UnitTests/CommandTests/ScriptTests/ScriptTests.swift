import Testing
import SwiftPickerTesting
@testable import nnapp

@MainActor
struct ScriptTests {
    @Test("Shows message when no launch script is configured")
    func showReportsNoScript() throws {
        let factory = MockContextFactory()
        let output = try runCommand(factory, subcommand: .show)
        #expect(output.contains("No launch script configured"))
    }

    @Test("Displays saved launch script")
    func showDisplaysScript() throws {
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        context.saveLaunchScript("echo hi")

        let output = try runCommand(factory, subcommand: .show)
        #expect(output == "echo hi")
    }

    @Test("Saves launch script from argument")
    func setScriptWithArg() throws {
        let factory = MockContextFactory()
        let context = try factory.makeContext()
        try runCommand(factory, subcommand: .set("echo hey"))
        #expect(context.loadLaunchScript() == "echo hey")
    }

    @Test("Saves launch script from user input")
    func setScriptFromInput() throws {
        let picker = MockSwiftPicker(inputResult: .init(type: .ordered(["echo there"])))
        let factory = MockContextFactory(picker: picker)
        let context = try factory.makeContext()
        try runCommand(factory, subcommand: .set(nil))
        #expect(context.loadLaunchScript() == "echo there")
    }

    @Test("Shows message when deleting nonexistent script")
    func deleteNoScript() throws {
        let factory = MockContextFactory()
        let output = try runCommand(factory, subcommand: .delete)
        #expect(output.contains("No launch script configured"))
    }

    @Test("Deletes existing launch script after confirmation")
    func deleteScript() throws {
        let picker = MockSwiftPicker(permissionResult: .init(defaultValue: true))
        let factory = MockContextFactory(picker: picker)
        let context = try factory.makeContext()
        context.saveLaunchScript("echo remove")

        let output = try runCommand(factory, subcommand: .delete)
        #expect(context.loadLaunchScript() == nil)
        #expect(output.contains("Launch script deleted"))
        #expect(picker.capturedPermissionPrompts.contains(where: { $0.contains("Delete the existing launch script?") }))
    }
}

private extension ScriptTests {
    enum Subcommand {
        case show
        case set(String?)
        case delete
    }

    @discardableResult
    func runCommand(_ factory: MockContextFactory, subcommand: Subcommand) throws -> String {
        var args = ["script"]
        switch subcommand {
        case .show:
            args.append("show")
        case .set(let script):
            args.append("set")
            if let script { args.append(script) }
        case .delete:
            args.append("delete")
        }
        return try Nnapp.testRun(contextFactory: factory, args: args)
    }
}
