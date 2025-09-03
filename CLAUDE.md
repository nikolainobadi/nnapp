# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**nnapp** is a Swift command-line utility for managing and launching Xcode projects and Swift packages. It organizes development environments into hierarchical **Categories**, **Groups**, and **Projects** with SwiftData persistence and Git integration.

## Build & Development Commands

### Building
```bash
swift build
swift build -c release
```

### Testing
```bash
# Run tests
swift test

# Note: SwiftData tests may encounter bundle initialization issues
# If tests fail with "Unable to determine Bundle Name", this is a known SwiftData test infrastructure issue
```

### Running
```bash
swift run nnapp --help
```

## Architecture

### Core Components

- **`CodeLaunchContext`**: Primary persistence layer managing SwiftData models and UserDefaults storage
- **Command Pattern**: Each CLI command (`Add`, `Create`, `Remove`, `List`, `Open`, `Finder`, `Script`, `SetMainProject`) implements `ParsableCommand`
- **Handler Classes**: Domain-specific logic orchestrators (`CategoryHandler`, `GroupHandler`, `ProjectHandler`)
- **Shell Abstraction**: `Shell` protocol with `DefaultShell` implementation using SwiftShell
- **Interactive Prompts**: `SwiftPicker` for CLI user input and selection

### Data Models (SwiftData)

- **`LaunchCategory`**: Top-level containers for groups
- **`LaunchGroup`**: Collections of related projects within a category  
- **`LaunchProject`**: Individual projects with metadata (type, shortcuts, remote repos, links)
- **`ProjectLink`**: URLs associated with projects (docs, repos, etc.)
- **`ProjectType`**: Enum for `.project`, `.package`, `.workspace`

### Dependency Structure

```
Nnapp (main) 
├── ContextFactory (protocol)
│   └── DefaultContextFactory (implementation)
├── Commands/ (ArgumentParser subcommands)
├── Handlers/ (business logic)
├── Kit/ (data models & core types)
└── Shell/ (system interaction)
```

### Key Dependencies

- **ArgumentParser**: CLI command parsing and help generation
- **SwiftData**: Model persistence with app group containers
- **SwiftShell**: Shell command execution
- **SwiftPicker**: Interactive CLI prompts and selections
- **NnGitKit**: Git operations abstraction
- **NnSwiftDataKit**: Shared SwiftData configuration utilities
- **Files**: Filesystem operations

## File Header Convention

When creating new Swift files, use "Nikolai Nobadi" in the "Created by" comment header.

## Testing

Tests are located in `Tests/nnappTests/` with:
- **UnitTests/**: Command-specific test suites
- **Shared/**: Mock implementations and test utilities
- Test targets use dependency injection with mock factories

### Important Testing Patterns

- **Category Relationship**: When creating test groups, ensure the `category` property is set to establish the parent-child relationship required for path resolution
- **Order Independence**: Tests should not rely on SwiftData's non-deterministic ordering of collections
- **Mock Picker**: Use `MockPicker` with appropriate `selectedItemIndex` for predictable test behavior

### Main Project Management

The `setMainProject` functionality in `GroupHandler` manages which project serves as the "main" or default project for a group. Key behaviors:

- **Main Project Definition**: A project with the same shortcut as its parent group
- **Shortcut Synchronization**: When switching main projects, shortcuts are transferred appropriately:
  - If group has a shortcut → new main project gets the group's shortcut
  - If group has no shortcut but new project does → both get the project's shortcut  
  - If neither has shortcuts → user is prompted to enter a new shortcut
- **Cleanup**: Previous main project's shortcut is cleared when switching
- **Confirmation**: User must confirm when changing an existing main project
- **Sorted Selection**: Non-main projects are presented alphabetically sorted for consistent selection

### Project Desktop Selection

The Add Project command supports a `--from-desktop` flag that allows users to select projects directly from their Desktop folder:

- **Usage**: `nnapp add project --from-desktop --group GroupName`
- **Filtering**: Only folders containing valid Xcode projects or Swift packages are shown
- **Detection**: Swift packages are identified by presence of `Package.swift`
- **Testing**: Desktop path can be injected for testing purposes via `ProjectHandler` constructor

## Configuration

- **App Group ID**: `R8SJ24LQF3.com.nobadi.codelaunch`
- **SwiftData**: Automatic container setup with UserDefaults integration
- **Platform**: macOS 14+ only
- **Shell Integration**: Designed for iTerm with Terminal support planned