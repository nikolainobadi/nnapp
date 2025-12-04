//
//  LaunchProjectHandler.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import Files
import CodeLaunchKit
import SwiftPickerKit

struct LaunchProjectHandler {
    private let picker: any CommandLinePicker
}


// MARK: - Add
extension LaunchProjectHandler {
    func addProject(path: String?, shortcut: String?, groupName: String?) throws {
        let group = try selectGroup(named: groupName)
        let projectFolder = try selectProjectFolder(path: path, group: group)
        
        // collect project info
        // create project
        // apply project shortcut to group if necessary
        // move project folder to group folder if necessary
        print("move \(projectFolder.name) to group folder if necessary")
        // save project and group
    }
}


// MARK: - Remove
extension LaunchProjectHandler {
    func removeProject(name: String?, shortcut: String?) throws {
        // TODO: - 
    }
}


// MARK: - Private Methods
private extension LaunchProjectHandler {
    func selectGroup(named name: String?) throws -> LaunchGroup {
        fatalError() // TODO: -
    }
    
    func selectProjectFolder(path: String?, group: LaunchGroup) throws -> Folder {
        fatalError() // TODO: -
    }
}


// MARK: - Dependencies
protocol LaunchProjectGroupSelector {
    func selectGroup(name: String?) throws -> LaunchGroup
}
