//
//  TerminalManager.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import Foundation
import NnShellKit

/// Manages terminal operations including iTerm integration and session management.
struct TerminalManager {
    private let shell: any Shell
    private let context: CodeLaunchContext
    
    /// Initializes a new terminal manager.
    /// - Parameters:
    ///   - shell: Shell protocol for executing system commands.
    ///   - context: Data context for loading launch scripts.
    init(shell: any Shell, context: CodeLaunchContext) {
        self.shell = shell
        self.context = context
    }
}


// MARK: - Terminal Operations
extension TerminalManager {
    /// Opens the project folder in a new terminal window, if not already open.
    /// - Parameters:
    ///   - folderPath: The project folder path to open.
    ///   - terminalOption: Controls whether to skip or only open terminal.
    func openDirectoryInTerminal(folderPath: String, terminalOption: TerminalOption?) {
        if let terminalOption, terminalOption == .noTerminal {
            return
        }
        
        guard let openPaths = try? getITermSessionPaths(),
              !openPaths.contains(folderPath) else {
            return
        }
        
        print("preparing to open project in new terminal window")
        var script = "cd \(folderPath)"
        
        if let extraCommand = context.loadLaunchScript() {
            script.append(" && \(extraCommand)")
        }
        
        script.append(" && clear")
        runScriptInNewTerminalWindow(script: script)
    }
    
    /// Runs the given shell script in a new iTerm tab, if iTerm is available.
    /// - Parameter script: A shell command string to execute.
    private func runScriptInNewTerminalWindow(script: String) {
        if let termProgram = ProcessInfo.processInfo.environment["TERM_PROGRAM"], termProgram == "iTerm.app" {
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
    }
    
    /// Retrieves all session working directory paths currently open in iTerm.
    /// - Returns: An array of folder paths for open terminal sessions.
    private func getITermSessionPaths() throws -> [String] {
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
