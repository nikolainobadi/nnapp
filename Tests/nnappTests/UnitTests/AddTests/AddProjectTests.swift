//
//  AddProjectTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
@testable import nnapp

@MainActor
final class AddProjectTests {
    @Test("Throws an error if no group is selected")
    func throwsErrorWhenNoGroupSelected() throws {
        // TODO: -
    }
    
    @Test("Throws error if path from arg finds folder without a project type.")
    func throwsErrorWhenNoProjecTypeExists() {
        // TODO: -
    }
    
    @Test("Throws error if no project path is input")
    func throwsErrorWhenNoPathInputIsProvided() {
        // TODO: -
    }
    
    @Test("Throws error if Project name is taken")
    func throwsErrorWhenProjectNameTaken() {
        // TODO: -
    }
    
    @Test("Throws error if Project shortcut is taken")
    func throwsErrorWhenProjectShortcutTaken() {
        // TODO: -
    }
    
    @Test("Moves Project folder to Group folder when necessary")
    func movesProjectFolderWhenNecessary() {
        // TODO: -
    }
    
    @Test("Does not move Project folder to Group folder if it is already there")
    func doesNotMoveProjectFolderWhenAlreadyInGroupFolder() {
        // TODO: -
    }
    
    @Test("Saves new Project to selected Group")
    func savesNewProjectToGroup() {
        // TODO: -
    }
}
