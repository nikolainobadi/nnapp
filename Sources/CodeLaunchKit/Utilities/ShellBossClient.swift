//
//  ShellBossClient.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 4/19/26.
//

import Foundation
import Network

/// Client for ShellBoss's local IPC socket. Used by `TerminalHandler` to
/// cd the current ShellBoss tab in place (instead of opening a new one)
/// by feeding `cd …\n` into the session's pty.
///
/// Protocol is broken out so unit tests can swap in a spy.
public protocol ShellBossClient {
    /// Writes `text` into the pty of the ShellBoss session identified
    /// by `sessionID`. A trailing newline in `text` is what makes the
    /// shell execute the line — the caller is responsible for including
    /// it when sending commands.
    func writeText(sessionID: String, text: String) throws
}


// MARK: - Errors
public enum ShellBossClientError: Error, CustomStringConvertible, Sendable {
    /// `~/.shellboss/mcp-socket` is missing or empty — ShellBoss isn't running.
    case notRunning
    /// The connection or response exceeded the wait budget.
    case timeout
    /// The server returned an error response body.
    case serverError(code: String, message: String)
    /// The response wasn't valid JSON or didn't contain the expected fields.
    case malformedResponse
    /// A lower-level `Network.NWError` or I/O failure.
    case underlying(Error)

    public var description: String {
        switch self {
        case .notRunning: return "ShellBoss is not running (pointer file missing or empty)."
        case .timeout: return "ShellBoss IPC timed out."
        case .serverError(let code, let message): return "ShellBoss IPC error [\(code)]: \(message)"
        case .malformedResponse: return "ShellBoss IPC returned a malformed response."
        case .underlying(let error): return "ShellBoss IPC I/O error: \(error)"
        }
    }
}


// MARK: - Default Implementation

/// Production `ShellBossClient`. Discovers the socket via the pointer
/// file at `~/.shellboss/mcp-socket` (written by ShellBoss's
/// `SocketFileManager.writePointer`) and speaks the framed-JSON
/// protocol — one JSON object per request/response, terminated by `\n`.
///
/// The call is synchronous and blocking: it issues the request and
/// waits (up to `timeout`) for the response. Runs its `NWConnection`
/// on a global dispatch queue; a `DispatchSemaphore` gates completion.
public struct DefaultShellBossClient: ShellBossClient, Sendable {
    private let pointerPath: String
    private let timeout: TimeInterval

    public init(pointerPath: String? = nil, timeout: TimeInterval = 2.0) {
        self.pointerPath = pointerPath ?? (NSHomeDirectory() as NSString).appendingPathComponent(".shellboss/mcp-socket")
        self.timeout = timeout
    }

    public func writeText(sessionID: String, text: String) throws {
        let socketPath = try resolveSocketPath()
        let payload = try encodeRequest(sessionID: sessionID, text: text)
        try sendAndReceive(socketPath: socketPath, payload: payload)
    }
}


// MARK: - Private
private extension DefaultShellBossClient {
    func resolveSocketPath() throws -> String {
        guard FileManager.default.fileExists(atPath: pointerPath),
              let raw = try? String(contentsOfFile: pointerPath, encoding: .utf8)
        else { throw ShellBossClientError.notRunning }

        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ShellBossClientError.notRunning }
        return trimmed
    }

    func encodeRequest(sessionID: String, text: String) throws -> Data {
        let dict: [String: Any] = [
            "action": "write_text",
            "sessionID": sessionID,
            "params": ["text": text]
        ]
        var data = try JSONSerialization.data(withJSONObject: dict)
        data.append(UInt8(ascii: "\n"))
        return data
    }

    func sendAndReceive(socketPath: String, payload: Data) throws {
        let connection = NWConnection(to: .unix(path: socketPath), using: .tcp)
        let outcome = ShellBossClientOutcomeBox()

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                connection.send(content: payload, completion: .contentProcessed { sendError in
                    if let sendError {
                        outcome.settle(.failure(ShellBossClientError.underlying(sendError)))
                        connection.cancel()
                        return
                    }
                    connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, recvError in
                        defer { connection.cancel() }
                        if let recvError {
                            outcome.settle(.failure(ShellBossClientError.underlying(recvError)))
                            return
                        }
                        guard let data, !data.isEmpty else {
                            outcome.settle(.failure(ShellBossClientError.malformedResponse))
                            return
                        }
                        outcome.settle(DefaultShellBossClient.parseResponse(data))
                    }
                })
            case .failed(let err):
                outcome.settle(.failure(ShellBossClientError.underlying(err)))
                connection.cancel()
            default:
                break
            }
        }

        connection.start(queue: .global())

        guard outcome.wait(timeout: timeout) else {
            connection.cancel()
            throw ShellBossClientError.timeout
        }

        try outcome.result.get()
    }

    static func parseResponse(_ data: Data) -> Result<Void, Error> {
        let trimmed = data.last == UInt8(ascii: "\n") ? data.dropLast() : data
        guard let json = try? JSONSerialization.jsonObject(with: trimmed) as? [String: Any],
              let success = json["success"] as? Bool
        else {
            return .failure(ShellBossClientError.malformedResponse)
        }

        if success { return .success(()) }

        let errBody = json["error"] as? [String: Any]
        let code = errBody?["code"] as? String ?? "unknown"
        let message = errBody?["message"] as? String ?? ""
        return .failure(ShellBossClientError.serverError(code: code, message: message))
    }
}


// MARK: - Thread-safe outcome box

/// Lock-guarded container that bridges `NWConnection`'s `@Sendable`
/// completion closures to the calling thread's synchronous wait. Kept
/// as a reference type so the closures can mutate shared state without
/// capturing `self` of the `DefaultShellBossClient` struct.
private final class ShellBossClientOutcomeBox: @unchecked Sendable {
    private let lock = NSLock()
    private let semaphore = DispatchSemaphore(value: 0)
    private var didResume = false
    private(set) var result: Result<Void, Error> = .failure(ShellBossClientError.timeout)

    func settle(_ value: Result<Void, Error>) {
        lock.lock()
        defer { lock.unlock() }
        guard !didResume else { return }
        didResume = true
        result = value
        semaphore.signal()
    }

    /// Returns `true` if settled in time, `false` on timeout.
    func wait(timeout: TimeInterval) -> Bool {
        semaphore.wait(timeout: .now() + timeout) != .timedOut
    }
}
