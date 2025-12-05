//
//  nnapp+ConvenienceMethods.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

import NnShellKit
import SwiftPickerKit

extension Nnapp {
    static func makeCategoryHandler() throws -> CategoryHandler {
        let picker = makePicker()
        let context = try makeContext()
        let folderBrowser = makeFolderBrowser(picker: picker)
        
        return .init(picker: picker, context: context, folderBrowser: folderBrowser)
    }
    
    static func makeGroupHandler() throws -> GroupHandler {
        let picker = makePicker()
        let context = try makeContext()
        let categorySelector = makeGroupCategorySelector(picker: picker, context: context)
        let folderBrowser = makeFolderBrowser(picker: picker)
        
        return .init(picker: picker, context: context, categorySelector: categorySelector, folderBrowser: folderBrowser)
    }
    
    static func makeProjectHandler() throws -> ProjectHandler {
        let shell = Nnapp.makeShell()
        let picker = Nnapp.makePicker()
        let context = try Nnapp.makeContext()
        let groupSelector = makeProjectGroupSelector(picker: picker, context: context)
        let folderBrowser = makeFolderBrowser(picker: picker)

        return .init(shell: shell, picker: picker, context: context, groupSelector: groupSelector, folderBrowser: folderBrowser)
    }

    static func makeListHandler() throws -> ListHandler {
        let picker = makePicker()
        let context = try makeContextAdapter()
        let console = contextFactory.makeConsoleOutput()

        return .init(picker: picker, loader: context, console: console)
    }

    static func makeFinderHandler() throws -> FinderHandler {
        let shell = makeShell()
        let picker = makePicker()
        let context = try makeContextAdapter()
        let console = contextFactory.makeConsoleOutput()

        return .init(shell: shell, picker: picker, loader: context, console: console)
    }

    static func makeOpenManager() throws -> OpenProjectHandler {
        let shell = makeShell()
        let picker = makePicker()
        let context = try makeContext()
        let ideLauncher = makeIDELauncher(shell: shell, picker: picker)
        let terminalManager = makeTerminalManager(shell: shell, context: context)
        let urlLauncher = makeURLLauncher(shell: shell, picker: picker)
        let branchSyncChecker = makeBranchSyncChecker(shell: shell)
        let branchStatusNotifier = makeBranchStatusNotifier(shell: shell)

        return .init(picker: picker, context: context, ideLauncher: ideLauncher, terminalManager: terminalManager, urlLauncher: urlLauncher, branchSyncChecker: branchSyncChecker, branchStatusNotifier: branchStatusNotifier)
    }
    
    static func makeIDELauncher(shell: Shell, picker: CommandLinePicker) -> IDELauncher {
        return .init(shell: shell, picker: picker)
    }
    
    static func makeTerminalManager(shell: Shell, context: CodeLaunchContext) -> TerminalManager {
        return .init(shell: shell, context: context)
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
