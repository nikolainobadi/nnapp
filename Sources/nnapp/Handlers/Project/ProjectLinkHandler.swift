//
//  ProjectLinkHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import SwiftPicker

struct ProjectLinkHandler {
    private let picker: Picker
    private let linkOptions: [String]
    
    init(picker: Picker, linkOptions: [String]) {
        self.picker = picker
        self.linkOptions = linkOptions
    }
}


// MARK: - Action
extension ProjectLinkHandler {
    func getOtherLinks() -> [ProjectLink] {
        guard picker.getPermission("Would you like to add a custom link?"), let name = getName() else {
            return []
        }
        
        let url = picker.getInput("Enter the url for your \(name) link.")
        
        guard !name.isEmpty, !url.isEmpty else {
            return []
        }
        
        return [.init(name: name, urlString: url)] + getOtherLinks()
    }
}


// MARK: - Private Methods
private extension ProjectLinkHandler {
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
