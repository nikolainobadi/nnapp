//
//  TerminalHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Foundation

/// Manages terminal operations including iTerm integration and session management.
public struct TerminalHandler {
    private let shell: any LaunchShell
    private let loader: any ScriptLoader
    private let environment: any TerminalEnvironmentProviding
    private let shellBossClient: any ShellBossClient

    /// Initializes a new terminal manager.
    /// - Parameters:
    ///   - shell: Shell protocol for executing system commands.
    ///   - loader: Script loader for an optional post-`cd` command.
    ///   - environment: Reports the current `$TERM_PROGRAM` and related env.
    ///   - shellBossClient: IPC client for cd-in-place inside a ShellBoss tab.
    ///     Defaults to `DefaultShellBossClient()`.
    public init(
        shell: any LaunchShell,
        loader: any ScriptLoader,
        environment: any TerminalEnvironmentProviding,
        shellBossClient: any ShellBossClient = DefaultShellBossClient()
    ) {
        self.shell = shell
        self.loader = loader
        self.environment = environment
        self.shellBossClient = shellBossClient
    }
}


// MARK: - Actions
public extension TerminalHandler {
    /// Opens the project folder in a terminal, using the most capable
    /// integration for the host terminal program:
    ///
    /// - **Inside a ShellBoss tab** (`TERM_PROGRAM=ShellBoss` with a
    ///   `SHELLBOSS_SESSION_ID`): `cd`s the current tab in place via
    ///   the ShellBoss IPC socket.
    /// - **Inside iTerm** (`TERM_PROGRAM=iTerm.app`): opens a new tab,
    ///   deduping against already-open session paths.
    /// - **Any other host**: no-op.
    ///
    /// - Parameters:
    ///   - folderPath: The project folder path to open.
    ///   - terminalOption: Controls whether to skip or only open terminal.
    func openDirectoryInTerminal(folderPath: String, terminalOption: TerminalOption?) {
        if let terminalOption, terminalOption == .noTerminal {
            return
        }

        switch environment.termProgram() {
        case "ShellBoss":
            if let sessionID = environment.shellBossSessionID() {
                cdInShellBossSession(folderPath: folderPath, sessionID: sessionID)
            }
            // No session ID → we're not in a real ShellBoss pty; bail.
        case "iTerm.app":
            openInITerm(folderPath: folderPath)
        default:
            return
        }
    }
}


// MARK: - iTerm
private extension TerminalHandler {
    func openInITerm(folderPath: String) {
        guard let openPaths = try? getITermSessionPaths(),
              !openPaths.contains(folderPath)
        else {
            return
        }

        print("preparing to open project in new terminal window")
        let script = buildCdScript(folderPath: folderPath)
        runScriptInNewITermTab(script: script)
    }

    /// Runs the given shell script in a new iTerm tab.
    func runScriptInNewITermTab(script: String) {
        let appleScript = """
            tell application "iTerm"
                activate
                tell current window
                    create tab with default profile
                    tell current session of current tab to write text "\(script)"
                end tell
            end tell
            """

        let _ = try? shell.runAppleScript(script: appleScript)
    }

    /// Retrieves all session working directory paths currently open in iTerm.
    func getITermSessionPaths() throws -> [String] {
        let script = """
        tell application "iTerm"
            set sessionPaths to {}
            repeat with aWindow in windows
                repeat with aTab in tabs of aWindow
                    repeat with aSession in sessions of aTab
                        set sessionPath to (variable aSession named "path")
                        if sessionPath is not missing value then
                            set end of sessionPaths to sessionPath
                        end if
                    end repeat
                end repeat
            end repeat
            return sessionPaths
        end tell
        """

        return try shell.runAppleScript(script: script).components(separatedBy: ", ")
    }
}


// MARK: - ShellBoss
private extension TerminalHandler {
    /// Feeds a `cd …` (plus optional launch script) into the current
    /// ShellBoss tab's pty via the IPC socket. The trailing newline is
    /// what the shell interprets as Return.
    func cdInShellBossSession(folderPath: String, sessionID: String) {
        let script = buildCdScript(folderPath: folderPath) + "\n"
        do {
            try shellBossClient.writeText(sessionID: sessionID, text: script)
        } catch {
            // Non-fatal: log and continue. The user can still cd manually.
            FileHandle.standardError.write(Data("nnapp: ShellBoss IPC failed — \(error)\n".utf8))
        }
    }
}


// MARK: - Script Building
private extension TerminalHandler {
    func buildCdScript(folderPath: String) -> String {
        var script = "cd \(folderPath)"
        if let extraCommand = loader.loadLaunchScript() {
            script.append(" && \(extraCommand)")
        }
        script.append(" && clear")
        return script
    }
}


// MARK: - Dependencies
public protocol ScriptLoader {
    func loadLaunchScript() -> String?
}

public protocol TerminalEnvironmentProviding {
    func termProgram() -> String?
    /// Value of `SHELLBOSS_SESSION_ID` in the current process env, or
    /// nil when we're not running inside a ShellBoss pty.
    func shellBossSessionID() -> String?
}

public extension TerminalEnvironmentProviding {
    /// Default no-op so existing conformers keep compiling. Production
    /// conformers (and any tests that exercise the ShellBoss path)
    /// should override this.
    func shellBossSessionID() -> String? { nil }
}
