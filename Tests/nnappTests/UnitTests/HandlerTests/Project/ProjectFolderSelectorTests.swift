//
//  ProjectFolderSelectorTests.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/05/25.
//

import Testing
import CodeLaunchKit
import SwiftPickerTesting
@testable import nnapp

struct ProjectFolderSelectorTests { 
    @Test("Returns project folder when valid path provided for package")
    func returnsProjectFolderWhenValidPathProvidedForPackage() throws {
        let projectDir = MockDirectory(path: "/tmp/MyPackage", containedFiles: ["Package.swift"])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(directoryToLoad: projectDir).sut

        let result = try sut.selectProjectFolder(path: projectDir.path, group: group)

        #expect(result.folder.path == projectDir.path)
        #expect(result.type == .package)
    }

    @Test("Returns project folder when valid path provided for xcodeproj")
    func returnsProjectFolderWhenValidPathProvidedForXcodeproj() throws {
        let xcodeprojDir = MockDirectory(path: "/tmp/MyProject/MyProject", ext: "xcodeproj")
        let projectDir = MockDirectory(path: "/tmp/MyProject", subdirectories: [xcodeprojDir])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(directoryToLoad: projectDir).sut

        let result = try sut.selectProjectFolder(path: projectDir.path, group: group)

        #expect(result.folder.path == projectDir.path)
        #expect(result.type == .project)
    }

    @Test("Throws when path provided but no project type found")
    func throwsWhenPathProvidedButNoProjectTypeFound() {
        let emptyDir = MockDirectory(path: "/tmp/empty")
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(directoryToLoad: emptyDir).sut

        #expect(throws: CodeLaunchError.noProjectInFolder) {
            try sut.selectProjectFolder(path: emptyDir.path, group: group)
        }
    }
}


// MARK: - Desktop Selection
extension ProjectFolderSelectorTests {
    @Test("Selects project from desktop when fromDesktop is true")
    func selectsProjectFromDesktopWhenFromDesktopIsTrue() throws {
        let desktopProject = MockDirectory(path: "/Users/test/Desktop/MyProject", containedFiles: ["Package.swift"])
        let desktop = MockDirectory(path: "/Users/test/Desktop", subdirectories: [desktopProject])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(desktop: desktop, selectionIndex: 0).sut

        let result = try sut.selectProjectFolder(path: nil, group: group, fromDesktop: true)

        #expect(result.folder.path == desktopProject.path)
        #expect(result.type == .package)
    }

    @Test("Throws when desktop has no valid projects")
    func throwsWhenDesktopHasNoValidProjects() {
        let emptyDesktop = MockDirectory(path: "/Users/test/Desktop", subdirectories: [])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(desktop: emptyDesktop).sut

        #expect(throws: CodeLaunchError.noProjectInFolder) {
            try sut.selectProjectFolder(path: nil, group: group, fromDesktop: true)
        }
    }

    @Test("Filters out non-project folders from desktop")
    func filtersOutNonProjectFoldersFromDesktop() throws {
        let validProject = MockDirectory(path: "/Users/test/Desktop/ValidProject", containedFiles: ["Package.swift"])
        let invalidFolder = MockDirectory(path: "/Users/test/Desktop/RandomFolder")
        let desktop = MockDirectory(path: "/Users/test/Desktop", subdirectories: [validProject, invalidFolder])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(desktop: desktop, selectionIndex: 0).sut

        let result = try sut.selectProjectFolder(path: nil, group: group, fromDesktop: true)

        #expect(result.folder.name == "ValidProject")
    }
}


// MARK: - Group Subfolder Selection
extension ProjectFolderSelectorTests {
    @Test("Selects from group subfolders when user accepts")
    func selectsFromGroupSubfoldersWhenUserAccepts() throws {
        let subfolder = MockDirectory(path: "/tmp/group/SubProject", containedFiles: ["Package.swift"])
        let groupFolder = MockDirectory(path: "/tmp/group", subdirectories: [subfolder])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: groupFolder.path))
        let sut = makeSUT(directoryToLoad: groupFolder, permissionResults: [true], selectionIndex: 0).sut

        let result = try sut.selectProjectFolder(path: nil, group: group)

        #expect(result.folder.path == subfolder.path)
        #expect(result.type == .package)
    }

    @Test("Browses for folder when user declines group subfolders")
    func browsesForFolderWhenUserDeclinesGroupSubfolders() throws {
        let subfolder = MockDirectory(path: "/tmp/group/SubProject", containedFiles: ["Package.swift"])
        let groupFolder = MockDirectory(path: "/tmp/group", subdirectories: [subfolder])
        let browsedFolder = MockDirectory(path: "/tmp/elsewhere/Project", containedFiles: ["Package.swift"])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: groupFolder.path))
        let (sut, browser, _) = makeSUT(directoryToLoad: groupFolder, selectedDirectory: browsedFolder, permissionResults: [false])

        let result = try sut.selectProjectFolder(path: nil, group: group)

        #expect(result.folder.path == browsedFolder.path)
        #expect(browser.prompt == "Browse to select a folder to use for your Project")
    }

    @Test("Browses when group has no available subfolders")
    func browsesWhenGroupHasNoAvailableSubfolders() throws {
        let groupFolder = MockDirectory(path: "/tmp/group", subdirectories: [])
        let browsedFolder = MockDirectory(path: "/tmp/elsewhere/Project", containedFiles: ["Package.swift"])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: groupFolder.path))
        let (sut, browser, _) = makeSUT(directoryToLoad: groupFolder, selectedDirectory: browsedFolder)

        let result = try sut.selectProjectFolder(path: nil, group: group)

        #expect(result.folder.path == browsedFolder.path)
        #expect(browser.prompt == "Browse to select a folder to use for your Project")
    }

    @Test("Filters out existing projects from available subfolders")
    func filtersOutExistingProjectsFromAvailableSubfolders() throws {
        let existingProject = makeProject(name: "ExistingProject")
        let existingSubfolder = MockDirectory(path: "/tmp/group/ExistingProject", containedFiles: ["Package.swift"])
        let newSubfolder = MockDirectory(path: "/tmp/group/NewProject", containedFiles: ["Package.swift"])
        let groupFolder = MockDirectory(path: "/tmp/group", subdirectories: [existingSubfolder, newSubfolder])
        let group = makeGroup(name: "TestGroup", projects: [existingProject], category: makeGroupCategory(path: groupFolder.path))
        let sut = makeSUT(directoryToLoad: groupFolder, permissionResults: [true], selectionIndex: 0).sut

        let result = try sut.selectProjectFolder(path: nil, group: group)

        #expect(result.folder.name == "NewProject")
    }

    @Test("Filters out non-project subfolders from available list")
    func filtersOutNonProjectSubfoldersFromAvailableList() throws {
        let validProject = MockDirectory(path: "/tmp/group/ValidProject", containedFiles: ["Package.swift"])
        let invalidFolder = MockDirectory(path: "/tmp/group/RandomFolder")
        let groupFolder = MockDirectory(path: "/tmp/group", subdirectories: [validProject, invalidFolder])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: groupFolder.path))
        let sut = makeSUT(directoryToLoad: groupFolder, permissionResults: [true], selectionIndex: 0).sut

        let result = try sut.selectProjectFolder(path: nil, group: group)

        #expect(result.folder.name == "ValidProject")
    }

    @Test("Throws when group has no path")
    func throwsWhenGroupHasNoPath() {
        let group = LaunchGroup.new(name: "TestGroup")
        let sut = makeSUT().sut

        #expect(throws: CodeLaunchError.missingGroup) {
            try sut.selectProjectFolder(path: nil, group: group)
        }
    }
}


// MARK: - Project Type Detection
extension ProjectFolderSelectorTests {
    @Test("Detects package type when Package.swift exists")
    func detectsPackageTypeWhenPackageSwiftExists() throws {
        let packageDir = MockDirectory(path: "/tmp/MyPackage", containedFiles: ["Package.swift"])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(directoryToLoad: packageDir).sut

        let result = try sut.selectProjectFolder(path: packageDir.path, group: group)

        #expect(result.type == .package)
    }

    @Test("Detects project type when xcodeproj exists")
    func detectsProjectTypeWhenXcodeprojExists() throws {
        let xcodeprojDir = MockDirectory(path: "/tmp/MyProject/MyProject", ext: "xcodeproj")
        let projectDir = MockDirectory(path: "/tmp/MyProject", subdirectories: [xcodeprojDir])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(directoryToLoad: projectDir).sut

        let result = try sut.selectProjectFolder(path: projectDir.path, group: group)

        #expect(result.type == .project)
    }

    @Test("Prefers package type when both Package.swift and xcodeproj exist")
    func prefersPackageTypeWhenBothPackageSwiftAndXcodeprojExist() throws {
        let xcodeprojDir = MockDirectory(path: "/tmp/MyProject/MyProject.xcodeproj")
        let projectDir = MockDirectory(path: "/tmp/MyProject", subdirectories: [xcodeprojDir], containedFiles: ["Package.swift"])
        let group = makeGroup(name: "TestGroup", category: makeGroupCategory(path: "/tmp/group"))
        let sut = makeSUT(directoryToLoad: projectDir).sut

        let result = try sut.selectProjectFolder(path: projectDir.path, group: group)

        #expect(result.type == .package)
    }
}


// MARK: - SUT
private extension ProjectFolderSelectorTests {
    func makeSUT(
        desktop: MockDirectory? = nil,
        directoryToLoad: MockDirectory? = nil,
        selectedDirectory: MockDirectory? = nil,
        permissionResults: [Bool] = [true],
        selectionIndex: Int = 0
    ) -> (sut: ProjectFolderSelector, browser: MockDirectoryBrowser, fileSystem: MockFileSystem) {
        let picker = MockSwiftPicker(
            permissionResult: .init(type: .ordered(permissionResults)),
            selectionResult: .init(defaultSingle: .index(selectionIndex))
        )
        let browser = MockDirectoryBrowser(selectedDirectory: selectedDirectory)
        let fileSystem = MockFileSystem(directoryToLoad: directoryToLoad, desktop: desktop)
        let projectService = ProjectManager(store: MockProjectStore(), fileSystem: fileSystem)
        let sut = ProjectFolderSelector(picker: picker, fileSystem: fileSystem, projectService: projectService, folderBrowser: browser)

        return (sut, browser, fileSystem)
    }
}

private final class MockProjectStore: ProjectStore {
    func loadProjects() throws -> [LaunchProject] { return [] }
    func loadGroups() throws -> [LaunchGroup] { return [] }
    func loadProjectLinkNames() -> [String] { return [] }
    func deleteGroup(_ group: LaunchGroup) throws { }
    func deleteProject(_ project: LaunchProject) throws { }
    func saveProject(_ project: LaunchProject, in group: LaunchGroup) throws { }
    func updateGroup(_ group: LaunchGroup) throws { }
    func updateProject(_ project: LaunchProject) throws { }
}
