//
//  File.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/29/25.
//

import Testing
@testable import nnapp
@preconcurrency import Files

@MainActor
final class AddTests {
    private let categoryListFolder: Folder
    private let categoryName = "categoryName"
    
    init() throws {
        self.categoryListFolder = try Folder.temporary.createSubfolder(named: "categoryListFolder")
    }
    
    deinit {
        deleteFolderContents(categoryListFolder)
    }
}


// MARK: - Category Tests
extension AddTests {
    @Test("Throws an error when the name of imported folder already exists in a Category")
    func throwsErrorWhenFolderNameIsTaken() {
        // TODO: -
    }
}


// MARK: - Group Tests
extension AddTests {
    @Test("Throws an error when Group name already exists in Category")
    func throwsErrorWhenGroupNameIsTaken() {
        // TODO: -
    }
    
    @Test("Throws an error when Group folder name already exists in Category Folder")
    func throwsErrorWhenGroupFolderNameIsTaken() {
        // TODO: -
    }
    
    @Test("Moves imported Group folder to Category Folder")
    func movesGroupFolderToCategoryFolder() throws {
        // TODO: -
    }
    
    @Test("Does not move imported Group folder to Category Folder when it is already there")
    func doesNotMoveGroupFolderToCategoryFolderWhenAlreadyThere() throws {
        // TODO: -
    }
    
    @Test("Saves new Group to Category")
    func savesNewGroupToCategory() throws {
        // TODO: -
    }
}


// MARK: - Project Tests
extension AddTests {
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


// MARK: - RunCommand
private extension AddTests {
    func runCommand(_ factory: MockContextFactory, argType: ArgType) throws {
        var args = ["add"]
        
        switch argType {
        case .category(let path):
            if let path {
                args.append(path)
            }
        }
        
        try Nnapp.testRun(contextFactory: factory, args: args)
    }
}


// MARK: - Dependencies
extension AddTests {
    enum ArgType {
        case category(path: String?)
    }
}
