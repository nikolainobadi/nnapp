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
    
    static func makeGroupHandler() throws -> LaunchGroupHandler {
        let picker = makePicker()
        let repository = try makeRepository()
        let categorySelector = try makeCategoryHandler(picker: picker)
        let folderBrowser = makeFolderBrowser(picker: picker)
        
        return .init(store: repository, picker: picker, folderBrowser: folderBrowser, categorySelector: categorySelector)
    }
    
    static func makeProjectHandler() throws -> LaunchProjectHandler {
        let shell = makeShell()
        let picker = makePicker()
        let repository = try makeRepository()
        let groupSelector = try makeGroupHandler()
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
        fatalError() // TODO: - 
//        let shell = makeShell()
//        let picker = makePicker()
//        let context = try makeContext()
//        let ideLauncher = makeIDELauncher(shell: shell, picker: picker)
//        let terminalManager = makeTerminalManager(shell: shell, context: context)
//        let urlLauncher = makeURLLauncher(shell: shell, picker: picker)
//        let branchSyncChecker = makeBranchSyncChecker(shell: shell)
//        let branchStatusNotifier = makeBranchStatusNotifier(shell: shell)
//
//        return .init(picker: picker, context: context, ideLauncher: ideLauncher, terminalManager: terminalManager, urlLauncher: urlLauncher, branchSyncChecker: branchSyncChecker, branchStatusNotifier: branchStatusNotifier)
    }
    
    static func makeIDELauncher(shell: Shell, picker: CommandLinePicker) -> IDELauncher {
        return .init(shell: shell, picker: picker)
    }
    
    static func makeTerminalManager(shell: Shell, loader: any ScriptLoader) -> TerminalManager {
        return .init(shell: shell, loader: loader)
    }
    
    static func makeURLLauncher(shell: Shell, picker: CommandLinePicker) -> URLLauncher {
        return .init(shell: shell, picker: picker)
    }

    static func makeBranchSyncChecker(shell: any Shell) -> any BranchSyncChecker {
        return contextFactory.makeBranchSyncChecker(shell: shell)
    }

    static func makeBranchStatusNotifier(shell: any Shell) -> any BranchStatusNotifier {
        return contextFactory.makeBranchStatusNotifier(shell: shell)
    }
}

import CodeLaunchKit
