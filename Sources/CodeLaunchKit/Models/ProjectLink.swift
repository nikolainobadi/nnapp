//
//  ProjectLink.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public struct ProjectLink: Equatable {
    public let name: String
    public let urlString: String
    
    public init(name: String, urlString: String) {
        self.name = name
        self.urlString = urlString
    }
}
