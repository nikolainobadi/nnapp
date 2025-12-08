//
//  URLHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import CodeLaunchKit

struct URLHandler {
    private let shell: any LaunchShell
    private let picker: any LaunchPicker
    
    init(shell: any LaunchShell, picker: any LaunchPicker) {
        self.shell = shell
        self.picker = picker
    }
}


// MARK: - URL Operations
extension URLHandler {
    func openRemoteURL(remote: ProjectLink?) throws {
        guard let remote else {
            throw CodeLaunchError.missingGitRepository
        }
        
        print("opening \(remote.name), url: \(remote.urlString)")
        try shell.runAndPrint(bash: "open \(remote.urlString)")
    }
    
    func openProjectLink(links: [ProjectLink]) throws {
        var selection: ProjectLink?
        
        switch links.count {
        case 0:
            break
        case 1:
            selection = links.first
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
