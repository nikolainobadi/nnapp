//
//  URLLauncher.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import NnShellKit
import SwiftPickerKit

/// Handles opening URLs including remote repositories and project links.
struct URLLauncher {
    private let shell: any Shell
    private let picker: any CommandLinePicker
    
    /// Initializes a new URL launcher.
    /// - Parameters:
    ///   - shell: Shell protocol for executing system commands.
    ///   - picker: Utility for prompting user selections.
    init(shell: any Shell, picker: any CommandLinePicker) {
        self.shell = shell
        self.picker = picker
    }
}


// MARK: - URL Operations
extension URLLauncher {
    func openRemoteURL(remote: SwiftDataProjectLink?) throws {
        guard let remote else {
            throw CodeLaunchError.missingGitRepository
        }
        
        print("opening \(remote.name), url: \(remote.urlString)")
        try shell.runAndPrint(bash: "open \(remote.urlString)")
    }
    
    func openProjectLink(links: [SwiftDataProjectLink]) throws {
        var selection: SwiftDataProjectLink?
        
        switch links.count {
        case 0:
            break
        case 1:
            selection = links.first
            try shell.runAndPrint(bash: "open \(links.first!.urlString)")
        default:
            selection = try picker.requiredSingleSelection("Select a link to open", items: links)
        }
        
        if let selection {
            try shell.runAndPrint(bash: "open \(selection.urlString)")
        } else {
            throw CodeLaunchError.missingProjectLink
        }
    }
}
