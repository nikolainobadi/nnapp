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

## Architecture Evolution (v0.7.0)

Version 0.7.0 introduced a major architectural refactoring:

- **CodeLaunchKit Framework**: Core functionality extracted into a separate framework for better separation of concerns
- **Repository Pattern**: SwiftData access now goes through a repository layer with domain/persistence model separation
- **Service Layer**: Business logic moved to Manager classes (CategoryManager, GroupManager, ProjectManager, LaunchManager)
- **Controller Rename**: Handler classes renamed to Controllers for consistency
- **Modern Dependencies**: Migrated to NnShellKit (v2.2.0+) and SwiftPickerKit (v0.8.0+)
- **Clean Architecture**: Clear boundaries between CLI, business logic, and persistence layers

This refactoring improves testability, maintainability, and enables potential future GUI applications using the same CodeLaunchKit framework.

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

### Project Eviction Safety
The `evict` command deletes a project's folder while preserving metadata for re-cloning. Before deletion, `BranchSyncChecker.verifyCanEvict` enforces safety checks:
- **Requires remote repository** — blocks if project has no remote (can't re-clone without one)
- **Blocks on dirty working tree** — unstaged changes, staged changes, or untracked files detected via `git status --porcelain`
- **Blocks on unpushed commits** — current branch ahead of or diverged from remote
- All checks run before the user confirmation prompt

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

**CodeLaunchKit Framework** (v0.7.0+):
- **Domain Models**: `LaunchCategory`, `LaunchGroup`, `LaunchProject`, `ProjectLink`, `ProjectType`
- **Managers**: Service layer handling business logic
  - `CategoryManager`: Category CRUD operations
  - `GroupManager`: Group management and main project logic
  - `ProjectManager`: Project operations and metadata
  - `LaunchManager`: IDE and terminal launching coordination
- **SwiftData Layer**:
  - `CodeLaunchContext`: Primary persistence layer with UserDefaults storage
  - `SwiftDataLaunchRepository`: Repository pattern for data access
  - Mappers: Convert between domain models and SwiftData models
- **Utilities**:
  - `BranchSyncChecker`: Monitors Git branch status against remotes
  - `BranchStatusNotifier`: Desktop notifications for branch sync alerts
  - `TerminalHandler`: iTerm integration and script execution
- **Protocols**: Service contracts (`CategoryService`, `GroupService`, `ProjectService`, `LaunchService`)

**nnapp CLI**:
- **Command Pattern**: Each CLI command (`Add`, `Create`, `Remove`, `List`, `Open`, `Finder`, `SetMainProject`) implements `ParsableCommand`
- **Controllers**: Command handlers orchestrating manager calls
  - `CategoryController`: Category operations
  - `GroupController`: Group operations and main project management
  - `ProjectController`: Project operations with selectors
  - `LaunchController`: Project launching with IDE/terminal/URL handlers
  - `FinderController`: Finder integration
  - `ListController`: Display and browse entities
- **Interactive Prompts**: `SwiftPickerKit` for CLI user input, selection, and tree navigation
- **Folder Browser**: `DirectoryBrowser` protocol for interactive folder selection

### Data Models

**Domain Models** (in CodeLaunchKit):
- **`LaunchCategory`**: Top-level containers for groups
- **`LaunchGroup`**: Collections of related projects within a category
- **`LaunchProject`**: Individual projects with metadata (type, shortcuts, remote repos, links)
- **`ProjectLink`**: URLs associated with projects (docs, repos, etc.)
- **`ProjectType`**: Enum for `.project`, `.package`, `.workspace`

**SwiftData Models** (internal, prefixed with `SwiftData`):
- **`SwiftDataLaunchCategory`**: Persistence model for categories
- **`SwiftDataLaunchGroup`**: Persistence model for groups
- **`SwiftDataLaunchProject`**: Persistence model for projects
- Mappers translate between domain and persistence models

### Project Structure

```
Sources/
├── CodeLaunchKit/                    # Core framework (v0.7.0+)
│   ├── Errors/
│   │   └── CodeLaunchError.swift
│   ├── Extensions/
│   │   ├── String+AppendingPathComponent.swift
│   │   └── String+Matches.swift
│   ├── FileSystem/                   # File operations abstraction
│   │   ├── DefaultFileSystem.swift
│   │   ├── Directory.swift
│   │   ├── DirectoryBrowser.swift
│   │   ├── FileSystem.swift
│   │   ├── FileSystemError.swift
│   │   ├── FilesDirectoryAdapter.swift
│   │   └── FolderBrowserAlias.swift
│   ├── Managers/                     # Business logic services
│   │   ├── CategoryManager.swift
│   │   ├── GroupManager.swift
│   │   ├── LaunchManager.swift
│   │   └── ProjectManager.swift
│   ├── Models/                       # Domain models
│   │   ├── LaunchBranchStatus.swift
│   │   ├── LaunchCategory.swift
│   │   ├── LaunchGroup.swift
│   │   ├── LaunchProject.swift
│   │   ├── LaunchType.swift
│   │   ├── ProjectLink.swift
│   │   ├── ProjectType.swift
│   │   └── TerminalOption.swift
│   ├── Protocols/                    # Service contracts
│   │   ├── CategoryService.swift
│   │   ├── GroupService.swift
│   │   ├── LaunchDataContracts.swift
│   │   ├── LaunchDelegate.swift
│   │   ├── LaunchService.swift
│   │   └── ProjectService.swift
│   ├── Shell/                        # Shell abstraction
│   │   ├── DefaultShell.swift
│   │   ├── LaunchGitShell.swift
│   │   └── LaunchShell.swift
│   ├── SwiftData/                    # Persistence layer
│   │   ├── Context/
│   │   │   └── CodeLaunchContext.swift
│   │   ├── Mappers/                  # Domain ↔ SwiftData translation
│   │   │   ├── LaunchCategoryMapper.swift
│   │   │   ├── LaunchGroupMapper.swift
│   │   │   └── LaunchProjectMapper.swift
│   │   ├── Models/
│   │   │   ├── SwiftDataLaunchCategory.swift
│   │   │   ├── SwiftDataLaunchGroup.swift
│   │   │   └── SwiftDataLaunchProject.swift
│   │   ├── Repositories/
│   │   │   └── SwiftDataLaunchRepository.swift
│   │   └── Schema/
│   │       └── FirstSchema.swift
│   └── Utilities/
│       ├── BranchStatusNotifier.swift
│       ├── BranchSyncChecker.swift
│       └── TerminalHandler.swift
│
└── nnapp/                            # CLI executable
    ├── Main/
    │   ├── nnapp.swift               # Entry point with @main
    │   ├── DefaultContextFactory.swift
    │   └── nnapp+ConvenienceMethods.swift
    ├── Commands/                     # Flat command structure
    │   ├── Add.swift
    │   ├── Create.swift
    │   ├── Remove.swift
    │   ├── List.swift
    │   ├── Open.swift
    │   ├── Finder.swift
    │   ├── SetMainProject.swift
    │   ├── Script.swift (disabled)
    │   └── Evict.swift
    ├── Controllers/                  # Command handlers
    │   ├── Category/
    │   │   ├── CategoryController.swift
    │   │   └── AssignCategoryType.swift
    │   ├── Group/
    │   │   ├── GroupController.swift
    │   │   ├── AssignGroupType.swift
    │   │   └── DirectoryContainer.swift
    │   ├── Project/
    │   │   ├── Controller/
    │   │   │   └── ProjectController.swift
    │   │   ├── Model/
    │   │   │   ├── BranchInfo.swift
    │   │   │   ├── ProjectFolder.swift
    │   │   │   └── ProjectInfo.swift
    │   │   └── Selectors/
    │   │       ├── ProjectFolderSelector.swift
    │   │       ├── ProjectInfoSelector.swift
    │   │       └── ProjectLinkSelector.swift
    │   ├── Launch/
    │   │   ├── LaunchController.swift
    │   │   ├── DefaultLaunchDelegate.swift
    │   │   ├── IDEHandler.swift
    │   │   └── URLHandler.swift
    │   ├── Finder/
    │   │   └── FinderController.swift
    │   └── List/
    │       └── ListController.swift
    ├── Picker/                       # Interactive browsing
    │   ├── DefaultDirectoryBrowser.swift
    │   ├── LaunchPicker.swift
    │   ├── LaunchTreeNode.swift
    │   ├── DisplayablePickerItemConformance.swift
    │   └── SwiftPicker+LaunchPicker.swift
    ├── Shared/
    │   ├── CodeLaunchError.swift
    │   └── ConsoleOutput.swift
    └── Extensions/
        └── SwiftDataLaunchRepository+Adapters.swift

Tests/nnappTests/
├── IntegrationTests/                 # Integration test suites
│   ├── AddTests/
│   ├── CreateTests/
│   ├── FinderTests/
│   ├── OpenTests/
│   ├── RemoveTests/
│   ├── ScriptTests/
│   └── TestHelpers/
├── UnitTests/
│   └── HandlerTests/                 # Controller unit tests
│       ├── Category/
│       ├── Group/
│       ├── Project/
│       ├── Finder/
│       ├── List/
│       └── Open/
└── Shared/                           # Test utilities
    ├── MockContextFactory.swift
    ├── MockDirectory.swift
    ├── MockDirectoryBrowser.swift
    ├── MockFileSystem.swift
    ├── MockLaunchShell.swift
    ├── MockConsoleOutput.swift
    ├── MockSwiftPicker+LaunchPicker.swift
    └── FactoryMethods.swift
```

### Key Dependencies

- **ArgumentParser** (v1.5.0+): CLI command parsing and help generation
- **SwiftData**: Model persistence with app group containers
- **SwiftPickerKit** (v0.9.0+): Interactive CLI prompts, selections, and tree navigation
- **NnShellKit** (v2.2.0+): Shell command execution and abstraction
- **NnGitKit** (v0.6.0+): Git operations abstraction (GitShellKit, GitCommandGen)
- **NnSwiftDataKit** (v0.9.0+): Shared SwiftData configuration utilities
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

The `setMainProject` functionality in `GroupController` manages which project serves as the "main" or default project for a group. Key behaviors:

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
- **Testing**: Desktop path can be injected for testing purposes via `ProjectController` constructor

## Available Commands

1. **add** - Register existing folders as Categories, Groups, Projects, or Links
2. **create** - Create new Category or Group folders and register them
3. **remove** - Unregister Categories, Groups, Projects, or Links (doesn't delete files)
4. **list** - Display registered entities with interactive browsing
5. **open** - Launch projects in Xcode/VSCode, open remotes, or project links
6. **set-main-project** - Change the main project for a group
7. **finder** - Open folders in Finder
8. **script** - (Temporarily disabled in v0.7.0) Manage terminal launch scripts
9. **evict** - Delete project folder while keeping metadata for re-cloning

For complete command reference, see [Documentation.md](./docs/Documentation.md).

## Version & Status

- **Current Version**: v0.9.0
- **Stability**: Functional and ready to use, but features and API may evolve before v1.0.0
- **Breaking Changes**: Possible before reaching v1.0.0

### Temporary Limitations
- **Script command disabled**: Temporarily disabled in v0.7.0 during refactoring; will be re-enabled soon

### Future Enhancements
- Re-enable `script` command with improved functionality
- Expand terminal support beyond iTerm and ShellBoss to vanilla Terminal and others

## Terminal Launching

`nnapp open` routes the terminal side of the launch by host:
- **ShellBoss** — detected via ShellBoss environment; `cd`s the current tab in place over the ShellBoss IPC socket instead of spawning a new window
- **iTerm** — opens a new deduped tab
- **Other terminals** — no-op

## Configuration

- **App Group ID**: `R8SJ24LQF3.com.nobadi.codelaunch`
- **SwiftData**: Automatic container setup with UserDefaults integration
- **Platform**: macOS 14+ only (Swift 6.0+)
- **Shell Integration**: iTerm (new tab) and ShellBoss (in-place `cd`); vanilla Terminal support planned
- **Storage**: Metadata stored via SwiftData; shortcuts and settings in UserDefaults
