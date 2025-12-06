//
//  ProjectHandlerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import Foundation
import CodeLaunchKit
import NnShellTesting
import SwiftPickerTesting
@testable import nnapp

struct ProjectHandlerTests {
    @Test("Starting values empty")
    func startingValuesEmpty() {
        let (_, delegate) = makeSUT()
        
        #expect(delegate.groupToUpdate == nil)
        #expect(delegate.groupToDelete == nil)
        #expect(delegate.projectToSave == nil)
        #expect(delegate.projectToDelete == nil)
        #expect(delegate.projectToUpdate == nil)
    }
}


// MARK: - SUT
private extension ProjectHandlerTests {
    func makeSUT(selectedDirectory: MockDirectory? = nil, groupToSelect: LaunchGroup? = nil, groupsToLoad: [LaunchGroup] = [], projectsToLoad: [LaunchProject] = [], projectLinkNamesToLoad: [String] = [], projectGroupToGet: LaunchGroup? = nil, throwError: Bool = false) -> (sut: ProjectHandler, delegate: MockDelegate) {
        let shell = MockLaunchShell()
        let picker = MockSwiftPicker(permissionResult: .init(defaultValue: true))
        let fileSystem = MockFileSystem()
        let folderBrowser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let delegate = MockDelegate(throwError: throwError, groupToSelect: groupToSelect, groupsToLoad: groupsToLoad, projectsToLoad: projectsToLoad, projectLinkNamesToLoad: projectLinkNamesToLoad, projectGroupToGet: projectGroupToGet)
        let sut = ProjectHandler(shell: shell, store: delegate, picker: picker, fileSystem: fileSystem, folderBrowser: folderBrowser, groupSelector: delegate)

        return (sut, delegate)
    }
}


// MARK: - Mocks
private extension ProjectHandlerTests {
    final class MockDelegate: ProjectStore, ProjectGroupSelector {
        private let throwError: Bool
        private let groupToSelect: LaunchGroup?
        private let groupsToLoad: [LaunchGroup]
        private let projectGroupToGet: LaunchGroup?
        private let projectsToLoad: [LaunchProject]
        private let projectLinkNamesToLoad: [String]
        
        private(set) var groupToUpdate: LaunchGroup?
        private(set) var groupToDelete: LaunchGroup?
        private(set) var projectToSave: LaunchProject?
        private(set) var projectToDelete: LaunchProject?
        private(set) var projectToUpdate: LaunchProject?
        
        init(throwError: Bool, groupToSelect: LaunchGroup?, groupsToLoad: [LaunchGroup], projectsToLoad: [LaunchProject], projectLinkNamesToLoad: [String], projectGroupToGet: LaunchGroup?) {
            self.throwError = throwError
            self.groupToSelect = groupToSelect
            self.groupsToLoad = groupsToLoad
            self.projectsToLoad = projectsToLoad
            self.projectGroupToGet = projectGroupToGet
            self.projectLinkNamesToLoad = projectLinkNamesToLoad
        }
        
        func loadGroups() throws -> [LaunchGroup] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return groupsToLoad
        }
        
        func loadProjects() throws -> [LaunchProject] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return projectsToLoad
        }
        
        func loadProjectLinkNames() -> [String] {
            return projectLinkNamesToLoad
        }
        
        func selectGroup(name: String?) throws -> LaunchGroup {
            guard let groupToSelect else {
                throw NSError(domain: "Test", code: 0)
            }
            
            return groupToSelect
        }
        
        func getProjectGroup(project: LaunchProject) throws -> LaunchGroup? {
            guard let projectGroupToGet else {
                throw NSError(domain: "Test", code: 0)
            }
            
            return projectGroupToGet
        }
        
        func updateGroup(_ group: LaunchGroup) throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            groupToUpdate = group
        }
        
        func deleteGroup(_ group: LaunchGroup) throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            groupToDelete = group
        }
        
        func deleteProject(_ project: LaunchProject) throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            projectToDelete = project
        }
        
        func updateProject(_ project: LaunchProject) throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            projectToUpdate = project
        }
        
        func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            projectToSave = project
        }
    }
}
