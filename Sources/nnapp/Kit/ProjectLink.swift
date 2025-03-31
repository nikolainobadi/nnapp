//
//  ProjectLink.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/31/25.
//

/// Represents a named hyperlink associated with a project, such as a GitHub repo or documentation site.
struct ProjectLink: Codable, Equatable {
    let name: String
    let urlString: String

    /// Initializes a new `ProjectLink`.
    /// - Parameters:
    ///   - name: A short display name for the link (e.g. "GitHub", "Docs").
    ///   - urlString: The full URL for the link.
    init(name: String, urlString: String) {
        self.name = name
        self.urlString = urlString
    }
}
