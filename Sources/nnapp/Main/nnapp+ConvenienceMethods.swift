//
//  nnapp+ConvenienceMethods.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import NnShellKit
import SwiftPickerKit

extension Nnapp {
    static func makeCategoryHandler(picker: (any CommandLinePicker)? = nil) throws -> LaunchCategoryHandler {
        let picker = picker ?? makePicker()
        let repository = try makeRepository()
        let folderBrowser = makeFolderBrowser(picker: picker)
        
        return .init(store: repository, picker: picker, folderBrowser: folderBrowser)
    }
    
    static func makeGroupHandler(picker: (any CommandLinePicker)? = nil) throws -> LaunchGroupHandler {
        let picker = picker ?? makePicker()
        let repository = try makeRepository()
        let categorySelector = try makeCategoryHandler(picker: picker)
        let folderBrowser = makeFolderBrowser(picker: picker)
        
        return .init(store: repository, picker: picker, folderBrowser: folderBrowser, categorySelector: categorySelector)
    }
    
    static func makeProjectHandler() throws -> LaunchProjectHandler {
        let shell = makeShell()
        let picker = makePicker()
        let repository = try makeRepository()
        let groupSelector = try makeGroupHandler(picker: picker)
        let folderBrowser = makeFolderBrowser(picker: picker)

        return .init(shell: shell, desktopPath: nil, store: repository, picker: picker, folderBrowser: folderBrowser, groupSelector: groupSelector)
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
        let ideLauncher = IDELauncher(shell: shell, picker: picker)
        let terminalManager = TerminalManager(shell: shell, loader: repository)
        let urlLauncher = URLLauncher(shell: shell, picker: picker)
        let branchSyncChecker = contextFactory.makeBranchSyncChecker(shell: shell)
        let branchStatusNotifier = contextFactory.makeBranchStatusNotifier(shell: shell)

        return .init(
            picker: picker,
            loader: repository,
            ideLauncher: ideLauncher,
            terminalManager: terminalManager,
            urlLauncher: urlLauncher,
            branchSyncChecker: branchSyncChecker,
            branchStatusNotifier: branchStatusNotifier
        )
    }
}
