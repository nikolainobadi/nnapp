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


// MARK: - Convenience Method
extension FolderBrowser {
    func browseForFolder(prompt: String, startPath: String? = nil) throws -> Folder {
        return try browseForFolder(prompt: prompt, startPath: startPath)
    }
}
