//
//  FolderBrowser.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 2/24/25.
//

import Foundation
import CodeLaunchKit
import SwiftPickerKit

/// Defines folder browsing behavior for handlers using the abstract `Directory` type.
protocol FolderBrowser {
    func browseForFolder(prompt: String, startPath: String?) throws -> Directory
}


// MARK: - Convenience Method
extension FolderBrowser {
    func browseForFolder(prompt: String, startPath: String? = nil) throws -> Directory {
        return try browseForFolder(prompt: prompt, startPath: startPath)
    }
}
