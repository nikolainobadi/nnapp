//
//  DefaultBranchStatusNotifier.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

import NnShellKit

struct DefaultBranchStatusNotifier {
    private let shell: any Shell

    init(shell: any Shell) {
        self.shell = shell
    }
}


// MARK: - BranchStatusNotifier
extension DefaultBranchStatusNotifier: BranchStatusNotifier {
    func notify(status: LaunchBranchStatus, for project: LaunchProject) {
        let title = "Branch Status Alert"
        let message: String

        switch status {
        case .behind:
            message = "\(project.name) is behind the remote branch"
        case .diverged:
            message = "\(project.name) has diverged from the remote branch"
        }

        let script = """
        display notification "\(message)" with title "\(title)" sound name "default"
        """

        _ = try? shell.runAppleScript(script: script)
    }
}
