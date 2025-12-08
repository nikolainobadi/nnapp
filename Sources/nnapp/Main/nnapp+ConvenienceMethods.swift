//
//  nnapp+ConvenienceMethods.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import CodeLaunchKit

extension Nnapp {
    static func makeListHandler() throws -> ListHandler {
        let picker = makePicker()
        let repository = try makeRepository()
        let console = contextFactory.makeConsoleOutput()

        return .init(picker: picker, loader: repository, console: console)
    }

    static func makeFinderHandler() throws -> FinderHandler {
        let shell = makeShell()
        let picker = makePicker()
        let repository = try makeRepository()
        let console = contextFactory.makeConsoleOutput()

        return .init(shell: shell, picker: picker, loader: repository, console: console)
    }

    static func makeOpenManager() throws -> OpenProjectHandler {
        let shell = makeShell()
        let picker = makePicker()
        let repository = try makeRepository()
        let fileSystem = contextFactory.makeFileSystem()
        let delegate = DefaultOpenProjectDelegate(shell: shell, picker: picker, loader: repository, fileSystem: fileSystem)
        
        return .init(picker: picker, loader: repository, delegate: delegate)
    }
    
    static func makeCategoryController(picker: (any LaunchPicker)? = nil) throws -> CategoryController {
        let picker = picker ?? makePicker()
        let repository = try makeRepository()
        let folderBrowser = makeFolderBrowser(picker: picker)
        let manager = CategoryManager(store: repository)
        
        return .init(manager: manager, picker: picker, folderBrowser: folderBrowser)
    }
    
    static func makeGroupController(picker: (any LaunchPicker)? = nil) throws -> GroupController {
        let picker = picker ?? makePicker()
        let repository = try makeRepository()
        let fileSystem = contextFactory.makeFileSystem()
        let folderBrowser = makeFolderBrowser(picker: picker)
        let categorySelector = try makeCategoryController(picker: picker)
        let groupService = GroupManager(store: repository, fileSystem: fileSystem)
        
        return .init(
            picker: picker,
            fileSystem: fileSystem,
            groupService: groupService,
            folderBrowser: folderBrowser,
            categorySelector: categorySelector
        )
    }
    
    static func makeProjectHandler() throws -> ProjectHandler {
        let shell = makeShell()
        let picker = makePicker()
        let repository = try makeRepository()
        let groupSelector = try makeGroupController(picker: picker)
        let folderBrowser = makeFolderBrowser(picker: picker)
        let fileSystem = contextFactory.makeFileSystem()
        let projectService = ProjectManager(store: repository, fileSystem: fileSystem)

        return .init(
            shell: shell,
            infoLoader: repository,
            projectService: projectService,
            picker: picker,
            fileSystem: fileSystem,
            folderBrowser: folderBrowser,
            groupSelector: groupSelector
        )
    }
}
