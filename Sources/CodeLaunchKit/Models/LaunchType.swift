//
//  LaunchType.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

public enum LaunchType: String, CaseIterable, Sendable {
    case xcode
    case vscode
    case remote
    case link

    public var argChar: Character {
        switch self {
        case .xcode: return "x"
        case .vscode: return "v"
        case .remote: return "r"
        case .link: return "l"
        }
    }
}
