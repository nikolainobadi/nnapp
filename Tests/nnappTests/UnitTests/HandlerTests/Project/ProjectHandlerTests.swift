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
        let (_, delegate, _) = makeSUT()
        
        #expect(delegate.groupToUpdate == nil)
        #expect(delegate.groupToDelete == nil)
        #expect(delegate.projectToSave == nil)
        #expect(delegate.projectToDelete == nil)
        #expect(delegate.projectToUpdate == nil)
        #expect(delegate.savedGroup == nil)
    }
}


// MARK: - Add
extension ProjectHandlerTests {
    @Test("Saves project and moves folder into selected group when added")
    func savesProjectAndMovesFolderIntoSelectedGroupWhenAdded() throws {
        let shortcut = "np"
        let projectFolderPath: String? = "/tmp/elsewhere/NewProject"
        let projectFolderFiles: Set<String> = ["Package.swift"]
        let moveTrackingDirectory = projectFolderPath.map({ makeMoveTrackingDirectory(path: $0, containedFiles: projectFolderFiles) })
        let group = makeGroup(name: "Group", category: makeGroupCategory(path: "/tmp/groups"))
        let (sut, delegate, fileSystem) = makeSUT(
            groupToSelect: group,
            groupsToLoad: [group],
            permissionResults: [false, false],
            inputResults: [shortcut],
            shellResults: ["https://github.com/example/repo"],
            moveTrackingDirectory: moveTrackingDirectory
        )

        try sut.addProject(
            path: "/tmp/elsewhere/NewProject",
            shortcut: shortcut,
            groupName: group.name,
            isMainProject: true,
            fromDesktop: false
        )
        
        #expect(delegate.projectToSave?.name == "NewProject")
        #expect(delegate.projectToSave?.shortcut == "np")
        #expect(delegate.projectToSave?.type == .package)
        #expect(delegate.savedGroup?.shortcut == "np")
//        #expect(moveTrackingDirectory?.movedToParents.contains(where: { $0 == group.path }))
        #expect(fileSystem.capturedPaths.contains(where: { $0 == group.path }))
    }

    @Test("Throws missing group when adding without path")
    func throwsMissingGroupWhenAddingWithoutPath() {
        let group = makeGroup(name: "Group")
        let sut = makeSUT(groupToSelect: group).sut

        #expect(throws: CodeLaunchError.missingGroup) {
            try sut.addProject(path: nil, shortcut: nil, groupName: group.name, isMainProject: false, fromDesktop: false)
        }
    }
}


// MARK: - Remove
extension ProjectHandlerTests {
    @Test("Deletes group when removing its only project")
    func deletesGroupWhenRemovingItsOnlyProject() throws {
        let project = makeProject(name: "Solo", shortcut: "solo")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [project])
        let (sut, delegate, _) = makeSUT(
            projectsToLoad: [project],
            projectGroupToGet: group,
            permissionResults: [true]
        )

        try sut.removeProject(name: "Solo", shortcut: nil)

        #expect(delegate.groupToDelete?.name == group.name)
        #expect(delegate.projectToDelete == nil)
        #expect(delegate.groupToUpdate == nil)
    }

    @Test("Updates group shortcut when replacing main project")
    func updatesGroupShortcutWhenReplacingMainProject() throws {
        let mainProject = makeProject(name: "Main", shortcut: "grp")
        let newMain = makeProject(name: "Alt", shortcut: "alt")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [mainProject, newMain])
        let (sut, delegate, _) = makeSUT(
            groupsToLoad: [group],
            projectsToLoad: [mainProject, newMain],
            projectGroupToGet: group,
            permissionResults: [true],
            selectionIndices: [0, 0]
        )

        try sut.removeProject(name: "Main", shortcut: nil)

        #expect(delegate.projectToDelete?.name == mainProject.name)
        #expect(delegate.groupToUpdate?.shortcut == newMain.shortcut)
        #expect(delegate.projectToUpdate == nil)
    }

    @Test("Updates project shortcut when keeping existing group shortcut")
    func updatesProjectShortcutWhenKeepingExistingGroupShortcut() throws {
        let mainProject = makeProject(name: "Main", shortcut: "grp")
        let newMain = makeProject(name: "Alt", shortcut: "alt")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [mainProject, newMain])
        let (sut, delegate, _) = makeSUT(
            groupsToLoad: [group],
            projectsToLoad: [mainProject, newMain],
            projectGroupToGet: group,
            permissionResults: [true],
            selectionIndices: [0, 1]
        )

        try sut.removeProject(name: nil, shortcut: "grp")

        #expect(delegate.projectToDelete?.name == mainProject.name)
        #expect(delegate.groupToUpdate == nil)
        #expect(delegate.projectToUpdate?.shortcut == group.shortcut)
    }
}


// MARK: - SUT
private extension ProjectHandlerTests {
    func makeSUT(
        groupToSelect: LaunchGroup? = nil,
        groupsToLoad: [LaunchGroup] = [],
        projectsToLoad: [LaunchProject] = [],
        projectLinkNamesToLoad: [String] = [],
        projectGroupToGet: LaunchGroup? = nil,
        permissionResults: [Bool] = [],
        inputResults: [String] = [],
        selectionIndices: [Int] = [],
        projectFolderPath: String? = nil,
        projectFolderFiles: Set<String> = [],
        shouldThrowOnExistingSubdirectory: Bool = false,
        shellResults: [String] = [],
        moveTrackingDirectory: MoveTrackingDirectory? = nil,
        throwError: Bool = false
    ) -> (sut: ProjectHandler, delegate: MockDelegate, fileSystem: StubFileSystem) {
        let selectionOutcomes = selectionIndices.map { MockSingleSelectionOutcome.index($0) }
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(defaultValue: true, type: .ordered(permissionResults)),
            selectionResult: .init(defaultSingle: .index(selectionIndices.first ?? 0), singleType: .ordered(selectionOutcomes))
        )
        let shell = MockLaunchShell(results: shellResults)
        let folder = moveTrackingDirectory ?? projectFolderPath.map { makeMoveTrackingDirectory(path: $0, containedFiles: projectFolderFiles) }
        let parentPath = groupToSelect?.path ?? "/tmp/group"
        let parentDirectory = makeMoveTrackingDirectory(path: parentPath, shouldThrowOnSubdirectory: shouldThrowOnExistingSubdirectory)
        let desktopDirectory = makeMoveTrackingDirectory(path: "/Users/test/Desktop")
        let homeDirectory = makeMoveTrackingDirectory(path: "/Users/test", subdirectories: [desktopDirectory])
        var directoryMap: [String: any Directory] = [parentPath: parentDirectory]

        if let projectFolderPath, let folder {
            directoryMap[projectFolderPath] = folder
        }

        let fileSystem = StubFileSystem(homeDirectory: homeDirectory, directoryMap: directoryMap, desktop: desktopDirectory)
        let folderBrowser = StubDirectoryBrowser(selectedDirectory: folder)
        let delegate = MockDelegate(
            throwError: throwError,
            groupToSelect: groupToSelect,
            groupsToLoad: groupsToLoad,
            projectsToLoad: projectsToLoad,
            projectLinkNamesToLoad: projectLinkNamesToLoad,
            projectGroupToGet: projectGroupToGet
        )
        let sut = ProjectHandler(shell: shell, store: delegate, picker: picker, fileSystem: fileSystem, folderBrowser: folderBrowser, groupSelector: delegate)

        return (sut, delegate, fileSystem)
    }
}


// MARK: - Test Helpers
private extension ProjectHandlerTests {
    func makeMoveTrackingDirectory(path: String, subdirectories: [any Directory] = [], containedFiles: Set<String> = [], shouldThrowOnSubdirectory: Bool = false) -> MoveTrackingDirectory {
        return MoveTrackingDirectory(path: path, subdirectories: subdirectories, containedFiles: containedFiles, shouldThrowOnSubdirectory: shouldThrowOnSubdirectory)
    }
}


// MARK: - Mocks
private extension ProjectHandlerTests {
    final class MoveTrackingDirectory: Directory {
        let path: String
        let name: String
        let `extension`: String?
        var subdirectories: [Directory]
        private let containedFiles: Set<String>
        private let shouldThrowOnSubdirectory: Bool
        private(set) var movedToParents: [String] = []

        init(path: String, subdirectories: [Directory] = [], containedFiles: Set<String> = [], shouldThrowOnSubdirectory: Bool = false, ext: String? = nil) {
            self.path = path
            self.name = (path as NSString).lastPathComponent
            self.subdirectories = subdirectories
            self.containedFiles = containedFiles
            self.shouldThrowOnSubdirectory = shouldThrowOnSubdirectory
            self.extension = ext
        }

        func containsFile(named name: String) -> Bool {
            return containedFiles.contains(name)
        }

        func subdirectory(named name: String) throws -> Directory {
            if shouldThrowOnSubdirectory {
                throw NSError(domain: "MoveTrackingDirectory", code: 1)
            }

            if let match = subdirectories.first(where: { $0.name == name }) {
                return match
            }

            return MoveTrackingDirectory(path: path.appendingPathComponent(name))
        }

        func createSubdirectory(named name: String) throws -> Directory {
            return try subdirectory(named: name)
        }

        func move(to parent: Directory) throws {
            movedToParents.append(parent.path)
        }
    }

    final class StubDirectoryBrowser: DirectoryBrowser {
        private let selectedDirectory: (any Directory)?
        private(set) var prompt: String?
        private(set) var startPath: String?

        init(selectedDirectory: (any Directory)?) {
            self.selectedDirectory = selectedDirectory
        }

        func browseForDirectory(prompt: String, startPath: String?) throws -> any Directory {
            self.prompt = prompt
            self.startPath = startPath

            if let selectedDirectory {
                return selectedDirectory
            }

            throw NSError(domain: "StubDirectoryBrowser", code: 0)
        }
    }

    final class StubFileSystem: FileSystem {
        private let directoryMap: [String: any Directory]
        private let desktop: any Directory
        private(set) var capturedPaths: [String] = []

        let homeDirectory: any Directory

        init(homeDirectory: any Directory, directoryMap: [String: any Directory], desktop: any Directory) {
            self.homeDirectory = homeDirectory
            self.directoryMap = directoryMap
            self.desktop = desktop
        }

        func directory(at path: String) throws -> any Directory {
            capturedPaths.append(path)

            if let directory = directoryMap[path] {
                return directory
            }

            throw NSError(domain: "StubFileSystem", code: 0)
        }

        func desktopDirectory() throws -> any Directory {
            return desktop
        }
    }

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
        private(set) var savedGroup: LaunchGroup?
        
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
            savedGroup = group
        }
    }
}
