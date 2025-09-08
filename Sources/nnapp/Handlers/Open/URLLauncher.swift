//
//  URLLauncher.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import SwiftPicker

/// Handles opening URLs including remote repositories and project links.
struct URLLauncher {
    private let shell: Shell
    private let picker: CommandLinePicker
    
    /// Initializes a new URL launcher.
    /// - Parameters:
    ///   - shell: Shell protocol for executing system commands.
    ///   - picker: Utility for prompting user selections.
    init(shell: Shell, picker: CommandLinePicker) {
        self.shell = shell
        self.picker = picker
    }
}


// MARK: - URL Operations
extension URLLauncher {
    /// Opens the remote repository URL in the browser.
    /// - Parameter project: The project whose remote URL to open.
    func openRemoteURL(for project: LaunchProject) throws {
        guard let remote = project.remote else {
            print("\(project.name) doesn't have a remote repository registered")
            throw CodeLaunchError.missingGitRepository
        }
        
        print("opening \(remote.name), url: \(remote.urlString)")
        try shell.runAndPrint("open \(remote.urlString)")
    }
    
    /// Opens one of the project's custom links, prompting if multiple exist.
    /// - Parameter project: The project whose link to open.
    func openProjectLink(for project: LaunchProject) throws {
        let links = project.links
        var selection: ProjectLink?
        
        switch links.count {
        case 0:
            break
        case 1:
            selection = links.first
            try shell.runAndPrint("open \(links.first!.urlString)")
        default:
            selection = try picker.requiredSingleSelection("Select a link to open", items: links)
        }
        
        if let selection {
            try shell.runAndPrint("open \(selection.urlString)")
        } else {
            print("\(project.name) doesn't have any links")
            throw CodeLaunchError.missingProjectLink
        }
    }
}