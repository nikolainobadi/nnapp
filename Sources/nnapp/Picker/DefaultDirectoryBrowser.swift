//
//  DefaultDirectoryBrowser.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/3/25.
//

import Foundation
import CodeLaunchKit
import SwiftPickerKit

/// Provides a reusable directory browsing experience backed by `SwiftPickerKit` tree navigation.
struct DefaultDirectoryBrowser {
    private let picker: any LaunchPicker
    private let fileSystem: any FileSystem
    private let homeDirectoryURL: URL
    
    /// Initializes a new directory browser.
    /// - Parameters:
    ///   - picker: Picker used to drive the interactive tree navigation.
    ///   - fileSystem: File system used to resolve selected directories.
    ///   - homeDirectoryURL: Default root directory for browsing.
    init(picker: any LaunchPicker, fileSystem: any FileSystem, homeDirectoryURL: URL) {
        self.picker = picker
        self.fileSystem = fileSystem
        self.homeDirectoryURL = homeDirectoryURL
    }
}


// MARK: - DirectoryBrowser
extension DefaultDirectoryBrowser: DirectoryBrowser {
    /// Presents an interactive browser for selecting a directory.
    /// - Parameters:
    ///   - prompt: Prompt shown at the top of the tree navigation.
    ///   - startPath: Optional path to use as the root of the browser. Defaults to the user's home directory.
    /// - Returns: The selected `Directory`.
    func browseForDirectory(prompt: String, startPath: String? = nil) throws -> Directory {
        let rootURL = try resolveRootURL(startPath: startPath)
        let rootNode = FileSystemNode(url: rootURL)
        let root = TreeNavigationRoot(displayName: rootURL.lastPathComponent, children: [rootNode])
        
        guard let selection = picker.treeNavigation(prompt, root: root, newScreen: true, showPromptText: false) else {
            throw CodeLaunchError.invalidInput
        }
        
        return try fileSystem.directory(at: selection.url.path)
    }
}


// MARK: - Convenience
public extension DirectoryBrowser {
    func browseForFolder(prompt: String, startPath: String? = nil) throws -> Directory {
        return try browseForDirectory(prompt: prompt, startPath: startPath)
    }
}


// MARK: - Private Methods
private extension DefaultDirectoryBrowser {
    func resolveRootURL(startPath: String?) throws -> URL {
        if let startPath {
            return .init(fileURLWithPath: startPath).standardizedFileURL
        }
        
        return homeDirectoryURL
    }
}
