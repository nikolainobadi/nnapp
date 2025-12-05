//
//  LaunchType.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 12/4/25.
//

enum LaunchType: String, CaseIterable {
    case xcode
    case vscode
    case remote
    case link

    var argChar: Character {
        switch self {
        case .xcode: return "x"
        case .vscode: return "v"
        case .remote: return "r"
        case .link: return "l"
        }
    }
}
