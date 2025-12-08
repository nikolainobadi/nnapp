//
//  TerminalHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

/// Manages terminal operations including iTerm integration and session management.
public struct TerminalHandler {
    private let shell: any LaunchShell
    private let loader: any ScriptLoader
    private let environment: any TerminalEnvironmentProviding
    
    /// Initializes a new terminal manager.
    /// - Parameters:
    ///   - shell: Shell protocol for executing system commands.
    ///   - context: Data context for loading launch scripts.
    public init(shell: any LaunchShell, loader: any ScriptLoader, environment: any TerminalEnvironmentProviding) {
        self.shell = shell
        self.loader = loader
        self.environment = environment
    }
}


// MARK: - Actions
public extension TerminalHandler {
    /// Opens the project folder in a new terminal window, if not already open.
    /// - Parameters:
    ///   - folderPath: The project folder path to open.
    ///   - terminalOption: Controls whether to skip or only open terminal.
    func openDirectoryInTerminal(folderPath: String, terminalOption: TerminalOption?) {
        if let terminalOption, terminalOption == .noTerminal {
            return
        }
        
        guard let openPaths = try? getITermSessionPaths(),
              !openPaths.contains(folderPath)
        else {
            return
        }
        
        print("preparing to open project in new terminal window")
        var script = "cd \(folderPath)"
        
        if let extraCommand = loader.loadLaunchScript() {
            script.append(" && \(extraCommand)")
        }
        
        script.append(" && clear")
        runScriptInNewTerminalWindow(script: script)
    }
}


// MARK: - Private Methods
private extension TerminalHandler {
    /// Runs the given shell script in a new iTerm tab, if iTerm is available.
    /// - Parameter script: A shell command string to execute.
    func runScriptInNewTerminalWindow(script: String) {
        if environment.termProgram() == "iTerm.app" {
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


// MARK: - Dependencies
public protocol ScriptLoader {
    func loadLaunchScript() -> String?
}

public protocol TerminalEnvironmentProviding {
    func termProgram() -> String?
}
