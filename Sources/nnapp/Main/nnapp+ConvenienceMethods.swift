//
//  nnapp+ConvenienceMethods.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

extension Nnapp {
    static func makeCategoryHandler(picker: (any LaunchPicker)? = nil) throws -> LaunchCategoryHandler {
        let picker = picker ?? makePicker()
        let repository = try makeRepository()
        let folderBrowser = makeFolderBrowser(picker: picker)
        
        return .init(store: repository, picker: picker, folderBrowser: folderBrowser)
    }
    
    static func makeGroupHandler(picker: (any LaunchPicker)? = nil) throws -> LaunchGroupHandler {
        let picker = picker ?? makePicker()
        let repository = try makeRepository()
        let categorySelector = try makeCategoryHandler(picker: picker)
        let folderBrowser = makeFolderBrowser(picker: picker)
        let fileSystem = contextFactory.makeFileSystem()
        
        return .init(
            store: repository,
            picker: picker,
            folderBrowser: folderBrowser,
            categorySelector: categorySelector,
            fileSystem: fileSystem
        )
    }
    
    static func makeProjectHandler() throws -> LaunchProjectHandler {
        let shell = makeShell()
        let picker = makePicker()
        let repository = try makeRepository()
        let groupSelector = try makeGroupHandler(picker: picker)
        let folderBrowser = makeFolderBrowser(picker: picker)
        let fileSystem = contextFactory.makeFileSystem()

        return .init(
            shell: shell,
            store: repository,
            picker: picker,
            fileSystem: fileSystem,
            folderBrowser: folderBrowser,
            groupSelector: groupSelector
        )
    }

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
        let branchSyncChecker = contextFactory.makeBranchSyncChecker(shell: shell)
        let branchStatusNotifier = contextFactory.makeBranchStatusNotifier(shell: shell)
        let fileSystem = contextFactory.makeFileSystem()

        return .init(
            shell: shell,
            picker: picker,
            loader: repository,
            branchSyncChecker: branchSyncChecker,
            branchStatusNotifier: branchStatusNotifier,
            fileSystem: fileSystem
        )
    }
}
