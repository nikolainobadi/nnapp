# Repository Guidelines

## Project Structure & Module Organization
- SwiftPM layout: code lives in `Sources/nnapp` with domains grouped by folder (`Commands`, `Handlers`, `Kit`, `Picker`, `Shell`, `Main`). Keep new types close to their domain to preserve discoverability.
- Folder browsing lives in `Sources/nnapp/Picker` (`FolderBrowser`, `DefaultFolderBrowser`) and is injected into handlers via factories.
- Tests sit in `Tests/nnappTests/UnitTests`, organized by command or handler. Shared test helpers (mock pickers, context factories, temp folder helpers) are under `Tests/nnappTests/Shared`.
- Resources (e.g., `Resources/Info.plist`) stay minimal; prefer code-first configuration where possible.

## Build, Test, and Development Commands
- `swift build` — compile the package; use to verify new code paths. Avoid running automatically in CI unless requested.
- `swift run nnapp --help` — smoke-checks the CLI wiring and shows available commands.
- `swift test` — executes XCTest suites under `Tests/nnappTests`. Add focused tests when changing command or handler behavior.

## Coding Style & Naming Conventions
- Swift 6, 4-space indentation, and one-line parameter lists (e.g., `init(picker:context:)`) to keep signatures compact.
- Favor protocol-driven designs and factory methods (see `Sources/nnapp/Main/nnapp.swift`) to keep dependencies swappable.
- Use `// MARK:` to separate concerns within files; prefer extensions for domain-specific helpers.
- Types and protocols use `UpperCamelCase`; functions and properties use `lowerCamelCase`. Keep enums and models lightweight and composable.
- New Swift files should retain the existing header format and author name (Nikolai Nobadi).

## Testing Guidelines
- Use XCTest with the existing naming pattern (`*Tests.swift`). Mirror production folders when adding new suites (e.g., `CommandTests/CreateTests`).
- Prefer deterministic tests with the shared mocks (`MockConsoleOutput`, `MockPicker`, `MainActorTempFolderDatasource`) to avoid filesystem drift.
- Use `MockFolderBrowser` when asserting folder selection flows; inject through handler initializers/factories.
- When adding behaviors that touch Git or the shell, isolate side effects behind protocols and mock them in tests.

## Commit & Pull Request Guidelines
- Commit messages follow short, imperative summaries (e.g., “refactor Finder command and unit tests”). Keep each commit focused on a single concern.
- PRs should describe intent, scope, and user-facing impact. Link related issues when applicable and include screenshots or sample CLI invocations when UX changes.
- Note any migrations or data shape changes in PR descriptions so reviewers can validate upgrade paths.

## Security & Configuration Tips
- Avoid hard-coding tokens or SSH details; rely on user-level Git configuration and environment variables.
- Validate paths before executing shell commands; keep operations scoped to the working directory or explicit user-selected folders.
- Prefer idempotent scripts with `set -e` and colored status output for clarity when adding tooling.

## Resource Requests
- Ask before loading `~/.codex/guidelines/shared/shared-formatting-codex.md` when working on Swift code.
- Ask before loading `~/.codex/guidelines/testing/base_unit_testing_guidelines.md` when discussing or editing tests.
- Ask before loading `~/.codex/guidelines/testing/CLI_TESTING_GUIDE_CODEX.md` when discussing or editing CLI tests.
- Ask before loading `~/.codex/guidelines/cli/NnShellKit-Usage.md` when the CLI depends on NnShellKit or shell execution helpers.
- Ask before loading `~/.codex/guidelines/cli/NnShellTesting-Usage.md` when writing or adjusting tests that touch shell execution.
- Ask before loading `~/.codex/guidelines/cli/SwiftPickerKit-usage.md` when the CLI uses SwiftPickerKit.
- Ask before loading `~/.codex/guidelines/cli/SwiftPickerTesting-usage.md` when testing SwiftPickerKit flows.

## CLI Design
- Single-responsibility commands
- Clear, predictable argument handling
- Minimal logging to stdout/stderr
- Use `NnShellKit` for shell execution; prefer absolute program paths
- Favor interactive folder browsing (via `FolderBrowser` and SwiftPickerKit tree navigation) over manual path entry for categories, groups, and projects; keep optional path args working.

## CLI Testing
- Behavior-driven tests for command logic
- Use `makeSUT` pattern where applicable
- Test both success and error paths
- Verify output formatting
- Use `MockShell` from NnShellTesting for shell interactions
