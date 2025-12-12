# nnapp

![Build Status](https://github.com/nikolainobadi/nnapp/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platform](https://img.shields.io/badge/platform-macOS%2014-blue)
![License](https://img.shields.io/badge/license-MIT-lightgray)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Category Commands](#category-commands)
  - [Group Commands](#group-commands)
  - [Project Commands](#project-commands)
  - [Link Commands](#link-commands)
  - [Opening Projects](#opening-projects)
  - [Finder Commands](#finder-commands)
  - [Listing Resources](#listing-resources)
- [Architecture Notes](#architecture-notes)
- [Documentation](#documentation)
- [Acknowledgments](#acknowledgments)
- [About This Project](#about-this-project)
- [Contributing](#contributing)
- [License](#license)

## Overview

**nnapp** is a command-line utility designed to manage and launch Xcode projects and Swift packages with ease. It organizes your local development environment into **Categories**, **Groups**, and **Projects**, supporting both local file system operations and Git integrations.

Think of it as a personalized project launcher with just enough metadata to keep your Swift workspace tidy and quickly accessible.

**Stability Notice (v0.7.1)**
`nnapp` is functional and ready to use, but its features and API may evolve as it becomes more flexible and robust.
Currently, `nnapp` is designed to work specifically with **iTerm**, but I'll add support for vanilla **Terminal** (and possible others) for the official release.
Breaking changes are possible before reaching v1.0.0.
Your feedback and suggestions are welcome as the project continues to improve!


## Features

- Create, import, or remove **Categories**, **Groups**, and **Projects**
- Browse for folders interactively (tree navigation) instead of typing paths for categories, groups, and projects
- Launch Xcode or VSCode with optional terminal workflows
- Open remote repositories or linked documentation instantly
- Automatically clone projects from Git remotes if missing locally
- **Branch status monitoring** - automatically checks if local projects are behind or diverged from remote, with desktop notifications
- Manage custom quick-launch shortcuts and set main projects for groups
- **Project links** - store and open named URLs (docs, analytics, repos, etc.) associated with projects
- **Finder integration** - quickly open any category, group, or project folder in Finder
- Stores metadata using `SwiftData` and `UserDefaults`
- Shell integration via `NnShellKit`
- Fully interactive CLI built on `ArgumentParser` and `SwiftPickerKit`

---

## Installation

You can install `nnapp` via [Homebrew](https://brew.sh) using the **nntools** tap:

```sh
brew tap nikolainobadi/nntools
brew install nnapp
```

---

## Usage

After installation, run:

```sh
nnapp --help
```

### Category Commands

- **Create a new category:**
  ```sh
  nnapp create category "Platform"
  ```

- **Import an existing folder as a category:**
  ```sh
  nnapp add category --path ~/dev/MyCategory
  ```
  Omit `--path` to browse interactively.

- **Remove a category** (unregisters but doesn't delete the folder):
  ```sh
  nnapp remove category "Platform"
  ```

### Group Commands

- **Create a new group:**
  ```sh
  nnapp create group "Mobile" --category "Platform"
  ```

- **Import an existing folder as a group:**
  ```sh
  nnapp add group --path ~/dev/MyGroup --category "Platform"
  ```

- **Remove a group:**
  ```sh
  nnapp remove group "Mobile"
  ```

- **Set a main project for a group:**
  ```sh
  nnapp set-main-project "Mobile"
  ```
  This synchronizes the project and group shortcuts for quick terminal access.

### Project Commands

- **Add a project:**
  ```sh
  nnapp add project --path ~/dev/MyApp --group Mobile
  ```

- **Add a project from Desktop:**
  ```sh
  nnapp add project --from-desktop --group Mobile
  ```
  Automatically filters to valid Xcode projects and Swift packages.

- **Add a project with a shortcut:**
  ```sh
  nnapp add project --path ~/dev/MyApp --group Mobile --shortcut abc
  ```

- **Add a project as the main project:**
  ```sh
  nnapp add project --path ~/dev/MyApp --group Mobile --main-project
  ```

- **Remove a project:**
  ```sh
  nnapp remove project "MyApp"
  ```

- **Browse for a project folder** (interactive mode):
  ```sh
  nnapp add project --group Mobile
  ```
  If the project is not under the group folder, an interactive browser opens to pick any folder.

### Link Commands

- **Add a named link to a project:**
  ```sh
  nnapp add link "Firebase"
  ```
  Store reusable link names like "Docs", "Analytics", "Repo" for consistent metadata.

- **Remove a link name:**
  ```sh
  nnapp remove link "Firebase"
  ```

- **List all saved link names:**
  ```sh
  nnapp list link
  ```

### Opening Projects

- **Open project in Xcode with terminal** (default):
  ```sh
  nnapp open abc
  ```

- **Open in VSCode:**
  ```sh
  nnapp open abc -v
  ```

- **Open IDE only** (no terminal):
  ```sh
  nnapp open abc --no-terminal
  ```

- **Open terminal only:**
  ```sh
  nnapp open abc --terminal
  ```

- **Open remote repository:**
  ```sh
  nnapp open abc -r
  ```

- **Open project link:**
  ```sh
  nnapp open abc -l
  ```
  Select from saved links associated with the project.

- **Open using group shortcut:**
  ```sh
  nnapp open xyz -g
  ```
  Opens the main project for the group with shortcut "xyz".

### Finder Commands

- **Open category folder in Finder:**
  ```sh
  nnapp finder category "Platform"
  ```

- **Open group folder in Finder:**
  ```sh
  nnapp finder group "Mobile"
  ```

- **Open project folder in Finder:**
  ```sh
  nnapp finder project "MyApp"
  ```

- **Browse and open any folder:**
  ```sh
  nnapp finder
  ```

### Listing Resources

- **List all registered entities** (interactive browser):
  ```sh
  nnapp list
  ```

- **List specific category details:**
  ```sh
  nnapp list category "Platform"
  ```

- **List specific group details:**
  ```sh
  nnapp list group "Mobile"
  ```

- **List specific project details:**
  ```sh
  nnapp list project "MyApp"
  ```

---

## Architecture Notes

- Shared logic lives in `CodeLaunchKit` (models, protocols, managers/services like `CategoryManager`, `GroupManager`, `ProjectManager`, `LaunchManager`, branch helpers), while CLI wiring and picker UX live in `nnapp` controllers.
- Branch tooling (`BranchSyncChecker`, `BranchStatusNotifier`) is shared for reuse across platforms.
- Interactive flows use `SwiftPickerKit`; shell/Git interactions are abstracted via `NnShellKit` and `NnGitKit`.
- Persistence uses `SwiftData` for categories, groups, and projects; tree navigation via a shared folder browser.

---

## Documentation

For a complete command reference with all flags, options, and detailed explanations, see [Documentation.md](./docs/Documentation.md).

The formal documentation includes:
- Comprehensive command reference with all flags and options
- Detailed explanation of key concepts (main projects, links, branch monitoring)
- Configuration and exit codes
- Advanced usage patterns

**Developer Documentation:**
- Inline documentation is provided via comments and docstrings
- Source code is organized for discoverability
- See each command's `run()` method and its related `Handler` for usage flow

---

## Acknowledgments

### Third-Party Libraries
- [`ArgumentParser`](https://github.com/apple/swift-argument-parser) — CLI parsing
- [`Files`](https://github.com/JohnSundell/Files) — filesystem handling

### My Swift Packages
- [`SwiftPickerKit`](https://github.com/nikolainobadi/SwiftPickerKit) — interactive prompts and tree navigation
- [`NnShellKit`](https://github.com/nikolainobadi/NnShellKit) — shell abstraction
- [`NnGitKit`](https://github.com/nikolainobadi/NnGitKit) — Git operations abstraction
- [`NnSwiftDataKit`](https://github.com/nikolainobadi/NnSwiftDataKit) — shared SwiftData setup

---

## About This Project

`nnapp` is what I built after getting annoyed one too many times with a messy desktop and forgotten rebases. I prefer the command line for version control and general navigation, so I wanted a way to launch Xcode or VS Code alongside a terminal without hunting through folders. Since I bounce between devices, the branch status monitoring keeps me from running into merge conflicts by alerting me when a project is behind its remote. I can link project-related websites and open them instantly with a simple command. It is a small tool that lets me be lazy in all the right ways so I can stay focused on building things.

### Future Features

- **Script command** — Define custom launch scripts for terminal workflows. (Temporarily disabled in v0.7.0, will be re-enabled soon)
- **Evict command** — Delete project folders locally while maintaining metadata, allowing easy recloning on next launch. (Implemented but disabled in v0.7.0)
- **Terminal app support** — Expand beyond iTerm to support vanilla Terminal and potentially other terminal emulators

---

## Contributing

Contributions are welcome! If you'd like to improve a command, add new integrations, or fix bugs:

1. Fork the repo
2. Create a new branch
3. Submit a PR with a clear description

Issues and suggestions are also welcome via [GitHub Issues](https://github.com/nikolainobadi/nnapp/issues).

---

## License

MIT License — see [LICENSE](LICENSE) for details.
