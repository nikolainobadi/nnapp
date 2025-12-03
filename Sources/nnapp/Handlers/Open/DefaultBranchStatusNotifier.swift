//
//  DefaultBranchStatusNotifier.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

struct DefaultBranchStatusNotifier {
    init() {}
}


// MARK: - BranchStatusNotifier
extension DefaultBranchStatusNotifier: BranchStatusNotifier {
    func notify(status: LaunchBranchStatus, for project: LaunchProject) {
        // TODO: Implement notification logic
    }
}
