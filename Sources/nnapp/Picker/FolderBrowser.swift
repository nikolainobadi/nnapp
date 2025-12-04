//
//  FolderBrowser.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 2/24/25.
//

import Files
import Foundation
import SwiftPickerKit

/// Defines folder browsing behavior for handlers.
protocol FolderBrowser {
    func browseForFolder(prompt: String, startPath: String?) throws -> Folder
}

/// Provides a reusable folder browsing experience backed by `SwiftPickerKit` tree navigation.
struct DefaultFolderBrowser: FolderBrowser {
    private let picker: any CommandLinePicker
    private let fileManager: FileManager

    /// Initializes a new folder browser.
    /// - Parameters:
    ///   - picker: Picker used to drive the interactive tree navigation.
    ///   - fileManager: File manager used for locating the default root directory.
    init(picker: any CommandLinePicker, fileManager: FileManager = .default) {
        self.picker = picker
        self.fileManager = fileManager
    }

    /// Presents an interactive browser for selecting a folder.
    /// - Parameters:
    ///   - prompt: Prompt shown at the top of the tree navigation.
    ///   - startPath: Optional path to use as the root of the browser. Defaults to the user's home directory.
    /// - Returns: The selected `Folder`.
    func browseForFolder(prompt: String, startPath: String? = nil) throws -> Folder {
        let rootURL = try resolveRootURL(startPath: startPath)
        let rootNode = FileSystemNode(url: rootURL)
        let root = TreeNavigationRoot(displayName: rootURL.lastPathComponent, children: [rootNode])

        guard let selection = picker.treeNavigation(prompt, root: root, newScreen: true, showPromptText: false) else {
            throw CodeLaunchError.invalidInput
        }

        return try Folder(path: selection.url.path)
    }

    private func resolveRootURL(startPath: String?) throws -> URL {
        if let startPath {
            return URL(fileURLWithPath: startPath).standardizedFileURL
        }
        return fileManager.homeDirectoryForCurrentUser
    }
}
