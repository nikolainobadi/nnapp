//
//  String+Extensions.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 9/8/25.
//

extension String {
    /// Returns `true` if the string matches another value, case-insensitively.
    /// - Parameter value: The optional string to compare against.
    /// - Returns: `true` if both strings match when lowercased; otherwise, `false`.
    func matches(_ value: String?) -> Bool {
        guard let value else {
            return false
        }
        
        return self.lowercased() == value.lowercased()
    }
}
