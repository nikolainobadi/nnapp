//
//  String+AppendingPathComponent.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public extension String {
    /// Appends a path component to the string, ensuring there is exactly one separating slash,
    /// and returns a string that always ends with a trailing slash.
    ///
    /// - Parameter path: The path component to append.
    /// - Returns: A combined path string ending with a `/`.
    func appendingPathComponent(_ path: String) -> String {
        let selfHasSlash = self.hasSuffix("/")
        let pathHasSlash = path.hasPrefix("/")
        
        let combinedPath: String
        if selfHasSlash && pathHasSlash {
            combinedPath = self + String(path.dropFirst())
        } else if !selfHasSlash && !pathHasSlash {
            combinedPath = self + "/" + path
        } else {
            combinedPath = self + path
        }
        
        return combinedPath.hasSuffix("/") ? combinedPath : combinedPath + "/"
    }
}
