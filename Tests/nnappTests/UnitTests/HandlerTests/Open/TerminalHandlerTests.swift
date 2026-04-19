//
//  TerminalHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import Foundation
import CodeLaunchKit
import NnShellTesting
@testable import nnapp

struct TerminalHandlerTests {
    private let folderPath = "fake/path/to/folder"
}


// MARK: - Unit Tests
extension TerminalHandlerTests {
    @Test("Does not open terminal")
    func doesNotOpenTerminal() {
        let (sut, shell, _) = makeSUT()

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: .noTerminal)

        #expect(shell.executedCommands.isEmpty)
    }

    @Test("Opens terminal with launch script when available")
    func opensTerminalWithLaunchScriptWhenAvailable() {
        let launchScript = "source ~/.zshrc && echo hi"
        let envProvider = TestEnvironmentProvider(termProgram: "iTerm.app")
        let (sut, shell, _) = makeSUT(scriptToLoad: launchScript, results: [""], environment: envProvider)

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: .onlyTerminal)

        #expect(shell.executedCommands.count == 2) // query sessions + open new tab
        #expect(shell.executedCommand(containing: "cd \(folderPath) && \(launchScript) && clear"))
    }

    @Test("Skips opening terminal when session already open")
    func skipsOpeningTerminalWhenSessionAlreadyOpen() {
        let (sut, shell, _) = makeSUT(results: [folderPath])

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: nil)

        #expect(!shell.executedCommand(containing: "cd \(folderPath)"))
    }
}


// MARK: - ShellBoss Path
extension TerminalHandlerTests {
    @Test("cd's the current ShellBoss tab in place when session ID is present")
    func cdsCurrentShellBossTabInPlace() {
        let envProvider = TestEnvironmentProvider(termProgram: "ShellBoss", shellBossSessionID: "abc123")
        let (sut, shell, client) = makeSUT(environment: envProvider)

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: nil)

        #expect(shell.executedCommands.isEmpty)  // no AppleScript
        #expect(client.calls.count == 1)
        #expect(client.calls.first?.sessionID == "abc123")
        #expect(client.calls.first?.text == "cd \(folderPath) && clear\n")
    }

    @Test("Includes loader launch script in ShellBoss cd payload")
    func includesLaunchScriptInShellBossPayload() {
        let launchScript = "source ~/.zshrc && echo hi"
        let envProvider = TestEnvironmentProvider(termProgram: "ShellBoss", shellBossSessionID: "abc123")
        let (sut, _, client) = makeSUT(scriptToLoad: launchScript, environment: envProvider)

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: nil)

        #expect(client.calls.first?.text == "cd \(folderPath) && \(launchScript) && clear\n")
    }

    @Test("Forwards companion session key untouched")
    func forwardsCompanionSessionKey() {
        let companionKey = "550e8400-e29b-41d4-a716-446655440000-companion"
        let envProvider = TestEnvironmentProvider(termProgram: "ShellBoss", shellBossSessionID: companionKey)
        let (sut, _, client) = makeSUT(environment: envProvider)

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: nil)

        #expect(client.calls.first?.sessionID == companionKey)
    }

    @Test("Does nothing when TERM_PROGRAM is ShellBoss but session ID is missing")
    func doesNothingWhenShellBossButNoSessionID() {
        let envProvider = TestEnvironmentProvider(termProgram: "ShellBoss", shellBossSessionID: nil)
        let (sut, shell, client) = makeSUT(environment: envProvider)

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: nil)

        #expect(shell.executedCommands.isEmpty)
        #expect(client.calls.isEmpty)
    }

    @Test("Does nothing for unsupported TERM_PROGRAM")
    func doesNothingForUnsupportedTermProgram() {
        let envProvider = TestEnvironmentProvider(termProgram: "Apple_Terminal")
        let (sut, shell, client) = makeSUT(environment: envProvider)

        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: nil)

        #expect(shell.executedCommands.isEmpty)
        #expect(client.calls.isEmpty)
    }

    @Test("Swallows ShellBossClient errors so nnapp does not crash")
    func swallowsShellBossClientErrors() {
        let envProvider = TestEnvironmentProvider(termProgram: "ShellBoss", shellBossSessionID: "abc123")
        let client = SpyShellBossClient(errorToThrow: ShellBossClientError.notRunning)
        let (sut, _, _) = makeSUT(environment: envProvider, shellBossClient: client)

        // Must not throw — failure is logged and swallowed.
        sut.openDirectoryInTerminal(folderPath: folderPath, terminalOption: nil)

        #expect(client.calls.count == 1)
    }
}


// MARK: - SUT
private extension TerminalHandlerTests {
    func makeSUT(
        scriptToLoad: String? = nil,
        results: [String] = [],
        environment: any TerminalEnvironmentProviding = TestEnvironmentProvider(),
        shellBossClient: SpyShellBossClient? = nil
    ) -> (sut: TerminalHandler, shell: MockShell, client: SpyShellBossClient) {
        let shell = MockLaunchShell(results: results)
        let loader = StubLoader(scriptToLoad: scriptToLoad)
        let client = shellBossClient ?? SpyShellBossClient()
        let sut = TerminalHandler(shell: shell, loader: loader, environment: environment, shellBossClient: client)

        return (sut, shell, client)
    }
}


// MARK: - Mocks
private extension TerminalHandlerTests {
    final class StubLoader: ScriptLoader {
        private let scriptToLoad: String?

        init(scriptToLoad: String?) {
            self.scriptToLoad = scriptToLoad
        }

        func loadLaunchScript() -> String? {
            return scriptToLoad
        }
    }

    final class TestEnvironmentProvider: TerminalEnvironmentProviding {
        private let termProgramValue: String?
        private let shellBossSessionIDValue: String?

        init(termProgram: String? = "iTerm.app", shellBossSessionID: String? = nil) {
            self.termProgramValue = termProgram
            self.shellBossSessionIDValue = shellBossSessionID
        }

        func termProgram() -> String? {
            return termProgramValue
        }

        func shellBossSessionID() -> String? {
            return shellBossSessionIDValue
        }
    }

    final class SpyShellBossClient: ShellBossClient {
        struct Call { let sessionID: String; let text: String }

        var calls: [Call] = []
        private let errorToThrow: Error?

        init(errorToThrow: Error? = nil) {
            self.errorToThrow = errorToThrow
        }

        func writeText(sessionID: String, text: String) throws {
            calls.append(Call(sessionID: sessionID, text: text))
            if let errorToThrow { throw errorToThrow }
        }
    }
}
