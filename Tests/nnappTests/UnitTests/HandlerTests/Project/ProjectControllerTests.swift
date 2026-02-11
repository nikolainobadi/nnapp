//
//  ProjectControllerTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/5/25.
//

import Testing
import Foundation
import CodeLaunchKit
import NnShellTesting
import SwiftPickerKit
import SwiftPickerTesting
@testable import nnapp

struct ProjectControllerTests {
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
extension ProjectControllerTests {
    @Test("Saves project and moves folder into selected group when added")
    func savesProjectAndMovesFolderIntoSelectedGroupWhenAdded() throws {
        let shortcut = "np"
        let newProjectName = "NewProject"
        let projectFolderPath = "/tmp/elsewhere/\(newProjectName)"
        let moveTrackingDirectory = makeMoveTrackingDirectory(path: projectFolderPath, containedFiles: ["Package.swift"])
        let group = makeGroup(name: "Group", category: makeGroupCategory(path: "/tmp/groups"))
        let (sut, delegate, fileSystem) = makeSUT(
            groupToSelect: group,
            groupsToLoad: [group],
            permissionResults: [false, false],
            inputResults: [shortcut],
            shellResults: ["https://github.com/example/repo"],
            moveTrackingDirectory: moveTrackingDirectory
        )

        try sut.addProject(path: projectFolderPath, shortcut: shortcut, groupName: group.name, isMainProject: true, fromDesktop: false)
        
        #expect(delegate.projectToSave?.name == "NewProject")
        #expect(delegate.projectToSave?.shortcut == shortcut)
        #expect(delegate.projectToSave?.type == .package)
        #expect(delegate.savedGroup?.shortcut == shortcut)
        #expect(moveTrackingDirectory.movedToParents.contains(where: { $0 == group.path }))
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

    @Test("Skips move when folder already in correct location")
    func skipsMoveWhenFolderAlreadyInCorrectLocation() throws {
        let shortcut = "test"
        let projectName = "ExistingProject"
        let group = makeGroup(name: "Group", category: makeGroupCategory(path: "/tmp/groups"))
        let groupPath = group.path ?? "/tmp/groups/Group"
        let projectPath = "\(groupPath)/\(projectName)"
        let projectFolder = makeMoveTrackingDirectory(path: projectPath, containedFiles: ["Package.swift"])
        let parentDirectory = makeMoveTrackingDirectory(path: groupPath, subdirectories: [projectFolder])
        let directoryMap: [String: any Directory] = [groupPath: parentDirectory, projectPath: projectFolder]
        let (sut, delegate, _) = makeSUT(
            groupToSelect: group,
            permissionResults: [false, false],
            inputResults: [shortcut],
            projectFolderPath: projectPath,
            shellResults: ["https://github.com/example/repo"],
            moveTrackingDirectory: projectFolder,
            customDirectoryMap: directoryMap
        )

        try sut.addProject(path: projectPath, shortcut: shortcut, groupName: group.name, isMainProject: true, fromDesktop: false)

        #expect(projectFolder.movedToParents.isEmpty)
        #expect(delegate.projectToSave?.name == projectName)
    }

    @Test("Adds non-main project without updating group shortcut")
    func addsNonMainProjectWithoutUpdatingGroupShortcut() throws {
        let groupShortcut = "grp"
        let projectShortcut = "proj"
        let group = makeGroup(name: "Group", shortcut: groupShortcut, category: makeGroupCategory(path: "/tmp/groups"))
        let projectPath = "/tmp/elsewhere/NonMainProject"
        let projectFolder = makeMoveTrackingDirectory(path: projectPath, containedFiles: ["Package.swift"])
        let (sut, delegate, _) = makeSUT(
            groupToSelect: group,
            permissionResults: [false, false],
            inputResults: [projectShortcut],
            shellResults: ["https://github.com/example/repo"],
            moveTrackingDirectory: projectFolder
        )

        try sut.addProject(path: projectPath, shortcut: projectShortcut, groupName: group.name, isMainProject: false, fromDesktop: false)

        #expect(delegate.projectToSave?.shortcut == projectShortcut)
        #expect(delegate.savedGroup?.shortcut == groupShortcut)
    }

    @Test("Throws folder name taken when different folder exists with same name")
    func throwsFolderNameTakenWhenDifferentFolderExistsWithSameName() {
        let projectName = "Conflict"
        let group = makeGroup(name: "Group", category: makeGroupCategory(path: "/tmp/groups"))
        let groupPath = group.path ?? "/tmp/groups/Group"
        let existingPath = "\(groupPath)/\(projectName)"
        let newPath = "/tmp/elsewhere/\(projectName)"
        let existingFolder = makeMoveTrackingDirectory(path: existingPath)
        let newFolder = makeMoveTrackingDirectory(path: newPath, containedFiles: ["Package.swift"])
        let parentDirectory = makeMoveTrackingDirectory(path: groupPath, subdirectories: [existingFolder])
        let directoryMap: [String: any Directory] = [groupPath: parentDirectory, newPath: newFolder]
        let sut = makeSUT(
            groupToSelect: group,
            permissionResults: [false, false],
            inputResults: ["conflict"],
            projectFolderPath: newPath,
            shellResults: [""],
            moveTrackingDirectory: newFolder,
            customDirectoryMap: directoryMap
        ).sut

        #expect(throws: CodeLaunchError.folderNameTaken) {
            try sut.addProject(path: newPath, shortcut: nil, groupName: group.name, isMainProject: false, fromDesktop: false)
        }
    }

    @Test("Updates group shortcut when group has no shortcut")
    func updatesGroupShortcutWhenGroupHasNoShortcut() throws {
        let projectShortcut = "proj"
        let group = makeGroup(name: "Group", shortcut: nil, category: makeGroupCategory(path: "/tmp/groups"))
        let projectPath = "/tmp/elsewhere/Project"
        let projectFolder = makeMoveTrackingDirectory(path: projectPath, containedFiles: ["Package.swift"])
        let (sut, delegate, _) = makeSUT(
            groupToSelect: group,
            permissionResults: [false, false],
            inputResults: [projectShortcut],
            shellResults: ["https://github.com/example/repo"],
            moveTrackingDirectory: projectFolder
        )

        try sut.addProject(path: projectPath, shortcut: projectShortcut, groupName: group.name, isMainProject: false, fromDesktop: false)

        #expect(delegate.projectToSave?.shortcut == projectShortcut)
        #expect(delegate.savedGroup?.shortcut == projectShortcut)
    }

    @Test("Detects xcode project type")
    func detectsXcodeProjectType() throws {
        let projectPath = "/tmp/elsewhere/XcodeProject"
        let xcodeproj = makeMoveTrackingDirectory(path: "\(projectPath)/XcodeProject.xcodeproj", ext: "xcodeproj")
        let projectFolder = makeMoveTrackingDirectory(path: projectPath, subdirectories: [xcodeproj])
        let group = makeGroup(name: "Group", category: makeGroupCategory(path: "/tmp/groups"))
        let (sut, delegate, _) = makeSUT(
            groupToSelect: group,
            permissionResults: [false, false],
            inputResults: ["xc"],
            shellResults: [""],
            moveTrackingDirectory: projectFolder
        )

        try sut.addProject(path: projectPath, shortcut: "xc", groupName: group.name, isMainProject: false, fromDesktop: false)

        #expect(delegate.projectToSave?.type == .project)
    }
}


// MARK: - Remove
extension ProjectControllerTests {
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
            selectionIndices: [0, 1]
        )

        try sut.removeProject(name: "Main", shortcut: nil)

        #expect(delegate.projectToDelete?.name == mainProject.name)
        #expect(delegate.groupToUpdate?.shortcut == newMain.shortcut)
        #expect(delegate.projectToUpdate == nil)
    }

    @Test("Updates project shortcut when keeping existing group shortcut", .disabled()) // TODO: - need to address the 'always update group' code in ProjectManager
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

    @Test("Removes non-main project without affecting shortcuts")
    func removesNonMainProjectWithoutAffectingShortcuts() throws {
        let mainProject = makeProject(name: "Main", shortcut: "grp")
        let otherProject = makeProject(name: "Other", shortcut: "other")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [mainProject, otherProject])
        let (sut, delegate, _) = makeSUT(
            projectsToLoad: [mainProject, otherProject],
            projectGroupToGet: group,
            permissionResults: [true]
        )

        try sut.removeProject(name: "Other", shortcut: nil)

        #expect(delegate.projectToDelete?.name == otherProject.name)
        #expect(delegate.groupToUpdate == nil)
        #expect(delegate.projectToUpdate == nil)
        #expect(delegate.groupToDelete == nil)
    }

    @Test("Finds project by name using case-insensitive matching")
    func findsProjectByNameUsingCaseInsensitiveMatching() throws {
        let project = makeProject(name: "MyProject", shortcut: "mp")
        let other = makeProject(name: "Other", shortcut: "grp")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [project, other])
        let (sut, delegate, _) = makeSUT(
            projectsToLoad: [project, other],
            projectGroupToGet: group,
            permissionResults: [true]
        )

        try sut.removeProject(name: "myproject", shortcut: nil)

        #expect(delegate.projectToDelete?.name == "MyProject")
    }

    @Test("Finds project by shortcut when provided")
    func findsProjectByShortcutWhenProvided() throws {
        let project = makeProject(name: "Project", shortcut: "proj")
        let main = makeProject(name: "Main", shortcut: "grp")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [project, main])
        let (sut, delegate, _) = makeSUT(
            projectsToLoad: [project, main],
            projectGroupToGet: group,
            permissionResults: [true]
        )

        try sut.removeProject(name: nil, shortcut: "proj")

        #expect(delegate.projectToDelete?.name == "Project")
    }

    @Test("Prompts selection when name not found")
    func promptsSelectionWhenNameNotFound() throws {
        let project1 = makeProject(name: "First", shortcut: "f")
        let project2 = makeProject(name: "Second", shortcut: "s")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [project1, project2])
        let (sut, delegate, _) = makeSUT(
            groupsToLoad: [group],
            projectsToLoad: [project1, project2],
            projectGroupToGet: group,
            permissionResults: [true],
            treeNavigationOutcome: .child(parentIndex: 0, childIndex: 1)
        )

        try sut.removeProject(name: "NonExistent", shortcut: nil)

        #expect(delegate.projectToDelete?.name == "Second")
    }

    @Test("Prompts selection when no name or shortcut provided")
    func promptsSelectionWhenNoNameOrShortcutProvided() throws {
        let project1 = makeProject(name: "First", shortcut: "f")
        let project2 = makeProject(name: "Second", shortcut: "s")
        let group = makeGroup(name: "Group", shortcut: "grp", projects: [project1, project2])
        let (sut, delegate, _) = makeSUT(
            groupsToLoad: [group],
            projectsToLoad: [project1, project2],
            projectGroupToGet: group,
            permissionResults: [true],
            treeNavigationOutcome: .child(parentIndex: 0, childIndex: 0)
        )

        try sut.removeProject(name: nil, shortcut: nil)

        #expect(delegate.projectToDelete?.name == "First")
    }

    @Test("Throws when user denies removal permission")
    func throwsWhenUserDeniesRemovalPermission() {
        let project = makeProject(name: "Project", shortcut: "p")
        let sut = makeSUT(
            projectsToLoad: [project],
            permissionResults: [false]
        ).sut

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.removeProject(name: "Project", shortcut: nil)
        }
    }

    @Test("Removes orphaned project without group")
    func removesOrphanedProjectWithoutGroup() throws {
        let project = makeProject(name: "Orphan", shortcut: "o")
        let (sut, delegate, _) = makeSUT(
            projectsToLoad: [project],
            projectGroupToGet: nil,
            permissionResults: [true]
        )

        try sut.removeProject(name: "Orphan", shortcut: nil)

        #expect(delegate.projectToDelete?.name == "Orphan")
        #expect(delegate.groupToDelete == nil)
        #expect(delegate.groupToUpdate == nil)
    }
}


// MARK: - Evict
extension ProjectControllerTests {
    @Test("Throws noRemoteRepository when evicting project without remote")
    func throwsNoRemoteRepositoryWhenEvictingProjectWithoutRemote() {
        let project = makeProject(name: "NoRemote", shortcut: "nr", group: makeProjectGroup())
        let sut = makeSUT(projectsToLoad: [project]).sut

        #expect(throws: CodeLaunchError.noRemoteRepository) {
            try sut.evictProject(name: "NoRemote", shortcut: nil)
        }
    }

    @Test("Throws missingProject when evicting project without folder path")
    func throwsMissingProjectWhenEvictingProjectWithoutFolderPath() {
        let project = makeProject(name: "NoFolder", shortcut: "nf", remote: makeProjectLink(name: "origin", urlString: "https://github.com/example/repo"))
        let sut = makeSUT(projectsToLoad: [project]).sut

        #expect(throws: CodeLaunchError.missingProject) {
            try sut.evictProject(name: "NoFolder", shortcut: nil)
        }
    }

    @Test("Throws projectAheadOfRemote when evict checker throws")
    func throwsProjectAheadOfRemoteWhenEvictCheckerThrows() {
        let group = makeProjectGroup(name: "Group", path: "/tmp/testgroup")
        let project = makeProject(name: "Ahead", shortcut: "a", remote: makeProjectLink(name: "origin", urlString: "https://github.com/example/repo"), group: group)
        let folderPath = "/tmp/testgroup/Ahead/"
        let folder = MockDirectory(path: folderPath)
        let directoryMap: [String: any Directory] = [folderPath: folder]
        let sut = makeSUT(
            projectsToLoad: [project],
            customDirectoryMap: directoryMap,
            evictChecker: { _ in throw CodeLaunchError.projectAheadOfRemote }
        ).sut

        #expect(throws: CodeLaunchError.projectAheadOfRemote) {
            try sut.evictProject(name: "Ahead", shortcut: nil)
        }
    }

    @Test("Throws selectionCancelled when user denies eviction permission")
    func throwsSelectionCancelledWhenUserDeniesEvictionPermission() {
        let group = makeProjectGroup(name: "Group", path: "/tmp/testgroup")
        let project = makeProject(name: "Denied", shortcut: "d", remote: makeProjectLink(name: "origin", urlString: "https://github.com/example/repo"), group: group)
        let folderPath = "/tmp/testgroup/Denied/"
        let folder = MockDirectory(path: folderPath)
        let directoryMap: [String: any Directory] = [folderPath: folder]
        let sut = makeSUT(
            projectsToLoad: [project],
            permissionResults: [false],
            customDirectoryMap: directoryMap
        ).sut

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.evictProject(name: "Denied", shortcut: nil)
        }
    }

    @Test("Deletes folder and preserves metadata on successful eviction")
    func deletesFolderAndPreservesMetadataOnSuccessfulEviction() throws {
        let group = makeProjectGroup(name: "Group", path: "/tmp/testgroup")
        let project = makeProject(name: "Evictable", shortcut: "ev", remote: makeProjectLink(name: "origin", urlString: "https://github.com/example/repo"), group: group)
        let folderPath = "/tmp/testgroup/Evictable/"
        let folder = MockDirectory(path: folderPath)
        let directoryMap: [String: any Directory] = [folderPath: folder]
        let (sut, delegate, _) = makeSUT(
            projectsToLoad: [project],
            permissionResults: [true],
            customDirectoryMap: directoryMap
        )

        try sut.evictProject(name: "Evictable", shortcut: nil)

        #expect(folder.deleteCallCount == 1)
        #expect(delegate.projectToDelete == nil)
    }

    @Test("Finds project by shortcut for eviction")
    func findsProjectByShortcutForEviction() throws {
        let group = makeProjectGroup(name: "Group", path: "/tmp/testgroup")
        let project = makeProject(name: "ByShortcut", shortcut: "bs", remote: makeProjectLink(name: "origin", urlString: "https://github.com/example/repo"), group: group)
        let folderPath = "/tmp/testgroup/ByShortcut/"
        let folder = MockDirectory(path: folderPath)
        let directoryMap: [String: any Directory] = [folderPath: folder]
        let (sut, delegate, _) = makeSUT(
            projectsToLoad: [project],
            permissionResults: [true],
            customDirectoryMap: directoryMap
        )

        try sut.evictProject(name: nil, shortcut: "bs")

        #expect(folder.deleteCallCount == 1)
        #expect(delegate.projectToDelete == nil)
    }

    @Test("Finds project by name for eviction")
    func findsProjectByNameForEviction() throws {
        let group = makeProjectGroup(name: "Group", path: "/tmp/testgroup")
        let project = makeProject(name: "FindByName", shortcut: "fbn", remote: makeProjectLink(name: "origin", urlString: "https://github.com/example/repo"), group: group)
        let folderPath = "/tmp/testgroup/FindByName/"
        let folder = MockDirectory(path: folderPath)
        let directoryMap: [String: any Directory] = [folderPath: folder]
        let (sut, delegate, _) = makeSUT(
            projectsToLoad: [project],
            permissionResults: [true],
            customDirectoryMap: directoryMap
        )

        try sut.evictProject(name: "findbyname", shortcut: nil)

        #expect(folder.deleteCallCount == 1)
        #expect(delegate.projectToDelete == nil)
    }
}


// MARK: - SUT
private extension ProjectControllerTests {
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
        moveTrackingDirectory: MockDirectory? = nil,
        customDirectoryMap: [String: any Directory]? = nil,
        throwError: Bool = false,
        treeNavigationOutcome: MockTreeSelectionOutcome = .none,
        evictChecker: @escaping (LaunchProject) throws -> Void = { _ in }
    ) -> (sut: ProjectController, delegate: MockDelegate, fileSystem: MockFileSystem) {
        let selectionOutcomes = selectionIndices.map { MockSingleSelectionOutcome.index($0) }
        let picker = MockSwiftPicker(
            inputResult: .init(type: .ordered(inputResults)),
            permissionResult: .init(defaultValue: true, type: .ordered(permissionResults)),
            selectionResult: .init(defaultSingle: .index(selectionIndices.first ?? 0), singleType: .ordered(selectionOutcomes)),
            treeNavigationResult: .init(
                defaultOutcome: treeNavigationOutcome,
                type: .ordered([treeNavigationOutcome])
            )
        )
        let shell = MockLaunchShell(results: shellResults)
        let folder = moveTrackingDirectory ?? projectFolderPath.map { makeMoveTrackingDirectory(path: $0, containedFiles: projectFolderFiles) }
        let parentPath = groupToSelect?.path ?? "/tmp/group"
        let parentDirectory = makeMoveTrackingDirectory(path: parentPath, shouldThrowOnSubdirectory: shouldThrowOnExistingSubdirectory)
        let desktopDirectory = makeMoveTrackingDirectory(path: "/Users/test/Desktop")
        let homeDirectory = makeMoveTrackingDirectory(path: "/Users/test", subdirectories: [desktopDirectory])
        var directoryMap: [String: any Directory] = customDirectoryMap ?? [parentPath: parentDirectory]

        if customDirectoryMap == nil, let projectFolderPath, let folder {
            directoryMap[projectFolderPath] = folder
        }

        let fileSystem = MockFileSystem(homeDirectory: homeDirectory, directoryMap: directoryMap, desktop: desktopDirectory)
        let folderBrowser = MockDirectoryBrowser(selectedDirectory: folder)
        let delegate = MockDelegate(
            throwError: throwError,
            groupToSelect: groupToSelect,
            groupsToLoad: groupsToLoad,
            projectsToLoad: projectsToLoad,
            projectLinkNamesToLoad: projectLinkNamesToLoad,
            projectGroupToGet: projectGroupToGet,
            allowOrphanedProject: projectGroupToGet == nil && !throwError
        )
        let projectService = ProjectManager(store: delegate, fileSystem: fileSystem)
        let sut = ProjectController(
            shell: shell,
            infoLoader: delegate,
            projectService: projectService,
            picker: picker,
            fileSystem: fileSystem,
            folderBrowser: folderBrowser,
            groupSelector: delegate,
            evictChecker: evictChecker
        )

        return (sut, delegate, fileSystem)
    }
}


// MARK: - Test Helpers
private extension ProjectControllerTests {
    func makeMoveTrackingDirectory(path: String, subdirectories: [any Directory] = [], containedFiles: Set<String> = [], shouldThrowOnSubdirectory: Bool = false, autoCreateSubdirectories: Bool = false, ext: String? = nil) -> MockDirectory {
        return MockDirectory(path: path, subdirectories: subdirectories, containedFiles: containedFiles, shouldThrowOnSubdirectory: shouldThrowOnSubdirectory, autoCreateSubdirectories: autoCreateSubdirectories, ext: ext)
    }
}


// MARK: - Mocks
private extension ProjectControllerTests {
    final class MockDelegate: ProjectStore, ProjectGroupSelector {
        private let throwError: Bool
        private let groupToSelect: LaunchGroup?
        private let groupsToLoad: [LaunchGroup]
        private let projectGroupToGet: LaunchGroup?
        private let projectsToLoad: [LaunchProject]
        private let projectLinkNamesToLoad: [String]
        private let allowOrphanedProject: Bool

        private(set) var groupToUpdate: LaunchGroup?
        private(set) var groupToDelete: LaunchGroup?
        private(set) var projectToSave: LaunchProject?
        private(set) var projectToDelete: LaunchProject?
        private(set) var projectToUpdate: LaunchProject?
        private(set) var savedGroup: LaunchGroup?

        init(throwError: Bool, groupToSelect: LaunchGroup?, groupsToLoad: [LaunchGroup], projectsToLoad: [LaunchProject], projectLinkNamesToLoad: [String], projectGroupToGet: LaunchGroup?, allowOrphanedProject: Bool = false) {
            self.throwError = throwError
            self.groupToSelect = groupToSelect
            self.groupsToLoad = groupsToLoad
            self.projectsToLoad = projectsToLoad
            self.projectGroupToGet = projectGroupToGet
            self.projectLinkNamesToLoad = projectLinkNamesToLoad
            self.allowOrphanedProject = allowOrphanedProject
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
            if allowOrphanedProject && projectGroupToGet == nil {
                return nil
            }

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
