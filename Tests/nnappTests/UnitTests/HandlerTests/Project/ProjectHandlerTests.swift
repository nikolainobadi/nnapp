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
        
        #expect(delegate.savedProjectInfo == nil)
        #expect(delegate.deletedProjectInfo == nil)
    }
}


// MARK: - SUT
private extension ProjectHandlerTests {
    func makeSUT(selectedDirectory: MockDirectory? = nil, groupToSelect: LaunchGroup? = nil, groupsToLoad: [LaunchGroup] = [], projectsToLoad: [LaunchProject] = [], projectLinkNamesToLoad: [String] = [], throwError: Bool = false) -> (sut: ProjectHandler, delegate: MockDelegate) {
        let shell = MockLaunchShell()
        let picker = MockSwiftPicker(permissionResult: .init(defaultValue: true))
        let fileSystem = MockFileSystem()
        let folderBrowser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let delegate = MockDelegate(throwError: throwError, groupToSelect: groupToSelect, groupsToLoad: groupsToLoad, projectsToLoad: projectsToLoad, projectLinkNamesToLoad: projectLinkNamesToLoad)
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
        private let projectsToLoad: [LaunchProject]
        private let projectLinkNamesToLoad: [String]
        
        private(set) var savedProjectInfo: (project: LaunchProject, group: LaunchGroup)?
        private(set) var deletedProjectInfo: (project: LaunchProject, group: LaunchGroup?)?
        
        init(throwError: Bool, groupToSelect: LaunchGroup?, groupsToLoad: [LaunchGroup], projectsToLoad: [LaunchProject], projectLinkNamesToLoad: [String]) {
            self.throwError = throwError
            self.groupToSelect = groupToSelect
            self.groupsToLoad = groupsToLoad
            self.projectsToLoad = projectsToLoad
            self.projectLinkNamesToLoad = projectLinkNamesToLoad
        }
        
        func loadGroups() throws -> [LaunchGroup] {
            return groupsToLoad
        }
        
        func loadProjects() throws -> [LaunchProject] {
            return projectsToLoad
        }
        
        func loadProjectLinkNames() -> [String] {
            return projectLinkNamesToLoad
        }
        
        func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            savedProjectInfo = (project, group)
        }
        
        func deleteProject(_ project: LaunchProject, from group: LaunchGroup?) throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            deletedProjectInfo = (project, group)
        }
        
        func selectGroup(name: String?) throws -> LaunchGroup {
            if let groupToSelect {
                return groupToSelect
            }
            
            throw NSError(domain: "Test", code: 0)
        }
    }
}
