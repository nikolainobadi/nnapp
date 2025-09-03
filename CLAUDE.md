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
# Use xcodebuild for tests (SwiftData requires macOS runtime)
xcodebuild test -scheme nnapp -destination 'platform=macOS'

# swift test does NOT work with SwiftData persistence layer
```

### Running
```bash
swift run nnapp --help
```

## Architecture

### Core Components

- **`CodeLaunchContext`**: Primary persistence layer managing SwiftData models and UserDefaults storage
- **Command Pattern**: Each CLI command (`Add`, `Create`, `Remove`, `List`, `Open`, `Finder`, `Script`) implements `ParsableCommand`
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

## Configuration

- **App Group ID**: `R8SJ24LQF3.com.nobadi.codelaunch`
- **SwiftData**: Automatic container setup with UserDefaults integration
- **Platform**: macOS 14+ only
- **Shell Integration**: Designed for iTerm with Terminal support planned