//
//  NnappError.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

enum ShellError: Error {
    case commandFailed(command: String, error: String)
}
