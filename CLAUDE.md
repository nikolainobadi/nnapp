# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Documentation Structure

This repository has multiple documentation files for different purposes:

- **[README.md](./README.md)** - User-facing documentation with features, installation, and usage examples
- **[docs/Documentation.md](./docs/Documentation.md)** - Complete command reference with all flags and options
- **[AGENTS.md](./AGENTS.md)** - Repository guidelines for AI agents (structure, testing, coding style)
- **CLAUDE.md** (this file) - Technical overview, architecture, and development patterns

## Overview

**nnapp** is a Swift command-line utility for managing and launching Xcode projects and Swift packages. It organizes development environments into hierarchical **Categories**, **Groups**, and **Projects** with SwiftData persistence and Git integration.

## Key Features & Concepts

### Hierarchical Organization
- **Category**: Top-level container folder (e.g., "Platform", "Mobile")
- **Group**: Collection of related projects within a category (e.g., "iOS Apps")
- **Project**: Individual Xcode project or Swift package

### Main Project Concept
Each group can have one **main project** — a project that shares the same shortcut as its parent group. This allows quick launching of the primary project for a group using a single shortcut.

**Shortcut Synchronization**:
- When setting a main project, shortcuts are synchronized between project and group
- If group has a shortcut → new main project gets it
- If group has no shortcut but project does → both get the project's shortcut
- If neither has shortcuts → user is prompted for a new shortcut

### Interactive Folder Browsing
Most commands support interactive tree-based folder browsing via `FolderBrowser` and `SwiftPickerKit`:
- No need to type paths manually
- Browse Categories → Groups → Projects hierarchically
- Optional path flags still work for automation
- Recent enhancement: Two-column detail view for improved UX

### Branch Status Monitoring
When opening projects with Git remotes, `nnapp`:
- Automatically checks if local branch is behind remote
- Detects diverged branches
- Sends desktop notifications via AppleScript when action needed
- Helps prevent merge conflicts across devices

### Project Links
Projects can have multiple named URLs (e.g., "Docs", "Firebase", "Analytics"):
- Add global link names via `nnapp add link`
- Associate specific URLs with projects
- Open quickly via `nnapp open <shortcut> -l`
- Useful for documentation, analytics dashboards, admin panels

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
- **Handler Classes**: Domain-specific logic orchestrators:
- `CategoryController`: Create, import, remove categories
  - `GroupHandler`: Create, import, remove groups; set main projects
  - `ProjectHandler`: Add, remove, evict projects
  - `OpenProjectHandler`: Manage IDE/terminal/URL launches
  - `FinderHandler`: Open folders in Finder
  - `ListHandler`: Display and browse entities
  - `ProjectLinkHandler`: Manage link metadata
- **Shell Abstraction**: `Shell` protocol with `DefaultShell` implementation using `NnShellKit`
- **Interactive Prompts**: `SwiftPickerKit` for CLI user input, selection, and tree navigation
- **Folder Browser**: `FolderBrowser` protocol with `DefaultFolderBrowser` implementation for interactive folder selection
- **IDE Launchers**: `IDELauncher` manages Xcode/VSCode launching with automatic Git cloning
- **Terminal Management**: `TerminalManager` handles iTerm integration and custom script execution
- **Git Integration**:
  - `DefaultBranchSyncChecker`: Monitors Git branch status against remotes
  - `DefaultBranchStatusNotifier`: Desktop notifications for branch sync alerts
- **URL Launcher**: `URLLauncher` opens remote repos and custom project links

### Data Models (SwiftData)

- **`LaunchCategory`**: Top-level containers for groups
- **`LaunchGroup`**: Collections of related projects within a category  
- **`LaunchProject`**: Individual projects with metadata (type, shortcuts, remote repos, links)
- **`ProjectLink`**: URLs associated with projects (docs, repos, etc.)
- **`ProjectType`**: Enum for `.project`, `.package`, `.workspace`

### Project Structure

```
Sources/nnapp/
├── Main/
│   ├── nnapp.swift                    # Entry point with @main
│   └── ContextFactory                 # Protocol + DefaultContextFactory
├── Commands/                          # ArgumentParser subcommands
│   ├── Add/                          # add category|group|project|link
│   ├── Create/                       # create category|group
│   ├── Remove/                       # remove category|group|project|link
│   ├── List/                         # list entities
│   ├── Open/                         # open projects
│   ├── Finder/                       # finder integration
│   ├── Script/                       # script management
│   ├── SetMainProject/               # set main project for group
│   └── Evict/ (disabled)             # evict project folders
├── Handlers/                         # Business logic orchestrators
│   ├── Category/                     # CategoryController
│   ├── Group/                        # GroupHandler, main project logic
│   ├── Project/                      # ProjectHandler, BranchInfo
│   ├── Open/                         # OpenProjectHandler, IDELauncher, TerminalManager
│   │                                 # BranchSyncChecker, BranchStatusNotifier
│   ├── Finder/                       # FinderHandler
│   ├── List/                         # ListHandler
│   └── Link/                         # ProjectLinkHandler
├── Kit/                              # Data models & core types
│   ├── CodeLaunchContext.swift       # SwiftData context & persistence
│   ├── LaunchCategory.swift          # @Model
│   ├── LaunchGroup.swift             # @Model
│   ├── LaunchProject.swift           # @Model
│   ├── ProjectLink.swift             # Struct (not @Model)
│   ├── ProjectType.swift             # Enum (.project, .package, .workspace)
│   └── Error types
├── Picker/                           # Interactive folder browsing
│   ├── FolderBrowser.swift           # Protocol
│   ├── DefaultFolderBrowser.swift    # Implementation
│   └── LaunchTreeNode.swift          # Tree structure for browsing
├── Shell/                            # Shell & URL operations
│   ├── Shell.swift                   # Protocol
│   ├── DefaultShell.swift            # NnShellKit implementation
│   └── URLLauncher.swift             # Open URLs/repos
└── Resources/
    └── Info.plist

Tests/nnappTests/
├── UnitTests/                        # Command-specific test suites
│   ├── AddTests/
│   ├── CreateTests/
│   ├── RemoveTests/
│   ├── ListTests/
│   ├── OpenTests/
│   ├── FinderTests/
│   └── SetMainProjectTests/
└── Shared/                           # Test utilities
    ├── MockPicker.swift
    ├── MockFolderBrowser.swift
    ├── MockContextFactory.swift
    └── Temp folder helpers
```

### Key Dependencies

- **ArgumentParser** (v1.5.0+): CLI command parsing and help generation
- **SwiftData**: Model persistence with app group containers
- **SwiftPickerKit** (branch: refactor-tree-navigation): Interactive CLI prompts, selections, and tree navigation
- **NnShellKit** (v2.0.0+): Shell command execution and abstraction
- **NnGitKit** (v0.6.0+): Git operations abstraction
- **NnSwiftDataKit** (branch: main): Shared SwiftData configuration utilities
- **Files** (v4.0.0+): Filesystem operations

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

## Available Commands

1. **add** - Register existing folders as Categories, Groups, Projects, or Links
2. **create** - Create new Category or Group folders and register them
3. **remove** - Unregister Categories, Groups, Projects, or Links (doesn't delete files)
4. **list** - Display registered entities with interactive browsing
5. **open** - Launch projects in Xcode/VSCode, open remotes, or project links
6. **set-main-project** - Change the main project for a group
7. **finder** - Open folders in Finder
8. **script** - Manage terminal launch scripts
9. **evict** - (Implemented but disabled in v0.6.0) Delete project folder while keeping metadata

For complete command reference, see [Documentation.md](./docs/Documentation.md).

## Version & Status

- **Current Version**: v0.6.0
- **Stability**: Functional and ready to use, but features and API may evolve before v1.0.0
- **Breaking Changes**: Possible before reaching v1.0.0

### Future Enhancements
- Enable `evict` command for managing disk space
- Expand terminal support beyond iTerm to vanilla Terminal and others

## Configuration

- **App Group ID**: `R8SJ24LQF3.com.nobadi.codelaunch`
- **SwiftData**: Automatic container setup with UserDefaults integration
- **Platform**: macOS 14+ only (Swift 6.0+)
- **Shell Integration**: Currently designed for iTerm; vanilla Terminal support planned
- **Storage**: Metadata stored via SwiftData; shortcuts and settings in UserDefaults
