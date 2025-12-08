//
//  ProjectLinkSelector.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import CodeLaunchKit

struct ProjectLinkSelector {
    private let picker: any LaunchPicker
    private let linkOptions: [String]
    private let projectService: any ProjectService
    
    /// Initializes the handler used to collect additional project links.
    /// - Parameters:
    ///   - picker: Utility used for user prompts and permissions.
    ///   - linkOptions: Pre-existing link names to present as quick selections.
    init(picker: any LaunchPicker, linkOptions: [String], projectService: any ProjectService) {
        self.picker = picker
        self.linkOptions = linkOptions
        self.projectService = projectService
    }
}


// MARK: - Action
extension ProjectLinkSelector {
    /// Recursively prompts the user to add custom links and returns all captured entries.
    /// - Returns: An array of `ProjectLink` objects created from user input.
    func getOtherLinks() -> [ProjectLink] {
        guard picker.getPermission("Would you like to add a custom link?"), let name = getName() else {
            return []
        }
        
        let url = picker.getInput("Enter the url for your \(name) link.")
        
        let link = projectService.makeLink(name: name, urlString: url)
        return projectService.append(link, to: []) + getOtherLinks()
    }
}


// MARK: - Private Methods
private extension ProjectLinkSelector {
    /// Retrieves a link name using either pre-configured options or freeform input.
    /// - Returns: The selected or entered name, or `nil` if the user cancels.
    func getName() -> String? {
        let nameInputPrompt = "Enter the name (NOT url) of your new link. (exmple: website, Firebase Firestore, etc)"
        
        if linkOptions.isEmpty {
            return picker.getInput(nameInputPrompt)
        } else {
            let custom = "CUSTOM LINK"
            
            guard let selection = picker.singleSelection("What name would you like to use for your link?", items: [custom] + linkOptions) else {
                return nil
            }
            
            if selection == custom {
                return picker.getInput(nameInputPrompt)
            } else {
                return selection
            }
        }
    }
}
