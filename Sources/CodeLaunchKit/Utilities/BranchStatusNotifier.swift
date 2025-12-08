//
//  BranchStatusNotifier.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/26/25.
//

public struct BranchStatusNotifier {
    private let shell: any LaunchShell

    public init(shell: any LaunchShell) {
        self.shell = shell
    }
}


// MARK: - BranchStatusNotifier
public extension BranchStatusNotifier {
    func notify(status: LaunchBranchStatus, for project: LaunchProject) {
        let title = "Branch Status Alert"
        let message: String

        switch status {
        case .behind:
            message = "\(project.name) is BEHIND the remote branch"
        case .diverged:
            message = "\(project.name) has DIVERGED from the remote branch"
        }

        let script = """
        display notification "\(message)" with title "\(title)" sound name "default"
        """

        print("preparing to notify with message:", message)
        do {
            let _ = try shell.runAppleScript(script: script)
        } catch {
            print("unable to send notification", error.localizedDescription)
        }
    }
}
