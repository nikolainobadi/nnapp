//
//  ProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/27/25.
//

import Files
import SwiftPicker

struct ProjectHandler {
    private let picker: Picker
    private let store: GroupHandler
    private let context: CodeLaunchContext
    
    init(picker: Picker, context: CodeLaunchContext) {
        self.picker = picker
        self.context = context
        self.store = GroupHandler(picker: picker, context: context)
    }
}


// MARK: -
extension ProjectHandler {
    func addProject(path: String?, group: String?, shortcut: String?) throws {
        let path = try path ?? picker.getRequiredInput("Enter the path to your project.")
        let folder = try Folder(path: path)
        // TODO: - need to verify that project name is available
        let group = try store.getGroup(named: group)
        // TODO: - need to verify that project shortcut is available
        let shortcut = try shortcut ?? picker.getRequiredInput("Enter the shortcut to launch this project.")
        let projectType = try getProjectType(folder: folder)
        let remote = getRemote(folder: folder)
        let otherLinks = getOtherLinks()
        let project = LaunchProject(name: folder.name, shortcut: shortcut, type: projectType, remote: remote, links: otherLinks)
        
        try context.saveProject(project, in: group)
    }
}


// MARK: - Private Methods
private extension ProjectHandler {
    func getProjectType(folder: Folder) throws -> ProjectType {
        return .package // TODO: -
    }
    
    func getRemote(folder: Folder) -> ProjectLink? {
        return nil // TODO: -
    }
    
    func getOtherLinks() -> [ProjectLink] {
        return [] // TODO: -
    }
}
