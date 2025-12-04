# nnapp

## Introduction

**nnapp** is a command-line utility designed to manage and launch Xcode projects and Swift packages with ease. It structures your development environment into **Categories**, **Groups**, and **Projects**, each with associated metadata. Whether you’re launching via Xcode, VSCode, or terminal, `nnapp` lets you organize, search, and open your projects faster than ever. Folder selection uses interactive browsing (tree navigation) so you rarely need to type paths; direct path flags still work when provided.

---

## Installation

Install via Homebrew using the official **nntools** tap:

```bash
brew tap nikolainobadi/nntools
brew install nnapp
```

---

## Quick Start

Create a new category:

```bash
nnapp create category "Platform"
```

Add a new project to a group:

```bash
nnapp add project --path ~/dev/MyApp --group Mobile
```

Add a project from the Desktop:

```bash
nnapp add project --from-desktop --group Mobile
```

Add a project by browsing for a folder (no path provided):

```bash
nnapp add project --group Mobile
```

Open a project in Xcode and terminal:

```bash
nnapp open abc
```

---

## Table of Contents

- [Features](#features)
- [Key Concepts](#key-concepts)
- [Command Overview](#command-overview)
- [add](#add)
- [create](#create)
- [remove](#remove)
- [list](#list)
- [open](#open)
- [set-main-project](#set-main-project)
- [finder](#finder)
- [script](#script)
<!-- - [evict](#evict) -->
- [Configuration](#configuration)
- [Exit Codes](#exit-codes)
- [About This Tool](#about-this-tool)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Hierarchical Organization** - Structure projects into Categories → Groups → Projects
- **Interactive Browsing** - Tree-based navigation for folder selection (no need to type paths)
- **Quick-Launch Shortcuts** - Access projects instantly via custom shortcuts
- **Multi-IDE Support** - Launch in Xcode or VSCode with optional terminal integration
- **Branch Status Monitoring** - Automatic checks if local projects are behind or diverged from remote, with desktop notifications
- **Git Integration** - Auto-clone missing projects from remote repositories
- **Project Links** - Store and open named URLs (docs, analytics, repos) associated with projects
- **Custom Scripts** - Define terminal launch scripts that run when opening projects
- **Finder Integration** - Quickly open any folder in Finder
- **Main Project Concept** - Set a primary project per group with synchronized shortcuts
- **SwiftData Persistence** - Automatic metadata storage with UserDefaults integration

---

## Key Concepts

### Categories, Groups, and Projects

- **Category**: Top-level container folder (e.g., "Platform", "Mobile", "Backend")
- **Group**: Collection of related projects within a category (e.g., "iOS Apps", "Frameworks")
- **Project**: Individual Xcode project or Swift package

### Main Project

Each group can have one **main project** — a project that shares the same shortcut as its parent group. This allows you to quickly launch the primary project for a group using a single shortcut.

When you set a main project:
- The project and group shortcuts are synchronized
- Using `nnapp open <shortcut> -g` launches the main project
- Previous main project shortcuts are cleared

### Project Links

Projects can have multiple named URLs associated with them (e.g., "Docs", "Firebase", "Analytics"). These links can be:
- Added via `nnapp add link`
- Opened via `nnapp open <shortcut> -l`
- Stored for quick access to project-related resources

### Branch Status Monitoring

When opening projects with Git remotes, `nnapp` automatically:
- Checks if the local branch is behind the remote
- Detects diverged branches
- Sends desktop notifications (via AppleScript) when action is needed
- Helps prevent merge conflicts when working across multiple devices

---

## Command Overview

| Command     | Description |
|-------------|-------------|
| `add`       | Register a Category, Group, Project, or Link from an existing folder |
| `create`    | Create a new Category or Group folder and register it in the database |
| `remove`    | Unregister a Category, Group, Project, or Link from the database |
| `list`      | Display all registered Categories, Groups, Projects, or Links |
| `open`      | Open a Project or Group in Xcode/VSCode, or open associated URLs |
| `set-main-project` | Change the main project for a group (synchronizes shortcuts) |
| `finder`    | Open a Category, Group, or Project in Finder |
| `script`    | Manage the launch script executed with `open` |
<!-- | `evict`     | Delete a Project folder while keeping quick-launch metadata | -->

---

## Detailed Command Reference

### add

```bash
nnapp add <subcommand>
```

Register an existing folder as a new Category, Group, Project, or Link.

#### Subcommands

| Subcommand | Description |
|-----------|-------------|
| `category` | Register an existing folder as a new Category |
| `group`    | Register a new Group under a Category |
| `project`  | Register a new Project folder under a Group |
| `link`     | Add a reusable Project Link name (e.g., Docs, Firebase) |

All arguments are optional — if omitted, `nnapp` will prompt you interactively.
Folder selection for categories, groups, and projects uses interactive browsing when paths are not provided.

#### About Project Links

Project Links are named URLs that you can associate with projects. Common use cases:
- **Documentation sites** (e.g., "Docs" → https://docs.example.com)
- **Analytics dashboards** (e.g., "Analytics" → Firebase/Mixpanel URLs)
- **Repository pages** (e.g., "GitHub" → project repo URL)
- **Admin panels** (e.g., "Admin" → backend admin URL)

When you add a link name via `nnapp add link`, it's stored globally and can be reused across projects. When opening a project with `nnapp open <shortcut> -l`, you'll select from links you've associated with that specific project.

#### Project flags

| Flag | Description |
|------|-------------|
| `--path` | Absolute path to the project folder (bypasses browsing) |
| `--group` / `-g` | Name of the group to register the project under |
| `--shortcut` / `-s` | Quick-launch shortcut for the project |
| `--main-project` | Set this project as the group's main project (synchronizes shortcuts) |
| `--from-desktop` | Browse only projects detected on the Desktop |

If no path is provided, `nnapp` opens an interactive folder browser (tree navigation), starting from the group folder when available.

#### Example

```bash
nnapp add project --path ~/dev/MyApp --group Mobile
```

---

### create

```bash
nnapp create <subcommand>
```

Create new folders and register them as Categories or Groups.

#### Subcommands

| Subcommand | Description |
|------------|-------------|
| `category` | Creates a new Category folder |
| `group`    | Creates a new Group folder under an existing Category |

Arguments can be omitted — `nnapp` will request input interactively.
Folder selection uses the interactive browser when a path is not supplied.

#### Example

```bash
nnapp create category "Platform"
```

---

### remove

```bash
nnapp remove <subcommand>
```

Unregister items from the internal database without deleting files from disk.

#### Subcommands

| Subcommand | Description |
|------------|-------------|
| `category` | Unregister a Category and all of its Groups/Projects |
| `group`    | Unregister a Group and its Projects |
| `project`  | Unregister a Project |
| `link`     | Remove a saved Project Link name |

If the name is omitted, `nnapp` will present a selection list.

#### Example

```bash
nnapp remove group "Mobile"
```

---

### list

```bash
nnapp list [subcommand]
```

Display registered Categories, Groups, Projects, or Links.

#### Subcommands

| Subcommand | Description |
|------------|-------------|
| `category` | Show details of a specific Category |
| `group`    | Show details of a specific Group |
| `project`  | Show details of a specific Project |
| `link`     | Show all saved Project Link names |

---

### open

```bash
nnapp open <shortcut> [-x|-v|-r|-l] [-g] [-n|-t]
```

Opens a project in an IDE, terminal, or web browser.

#### Flags

| Flag        | Description                                  |
|-------------|----------------------------------------------|
| `-x`        | Open in Xcode (default)                      |
| `-v`        | Open in VSCode                               |
| `-r`        | Open remote Git repository                   |
| `-l`        | Open a custom project link (select from saved links) |
| `-g`        | Use group shortcut to open the group's main project |
| `-n` / `--no-terminal` | Only launch IDE, don't launch terminal |
| `-t` / `--terminal` | Only launch terminal, don't launch IDE |

**Notes:**
- When a project is missing locally but has a remote Git repository, it will be automatically cloned
- Branch status is checked automatically, with desktop notifications if the local branch is behind or diverged
- Custom launch scripts (via `nnapp script set`) run in the terminal when opening projects

---

### set-main-project

```bash
nnapp set-main-project [group name or shortcut]
```

Changes which project serves as the **main project** for a group. The main project is the default project that opens when using a group shortcut.

#### How It Works

When you set a main project:
1. The project's shortcut is synchronized with the group's shortcut
2. The previous main project (if any) has its shortcut cleared
3. You can then use `nnapp open <shortcut> -g` to launch the main project using the group shortcut

#### Shortcut Synchronization

The command handles shortcuts intelligently:
- **If the group has a shortcut**: The new main project gets the group's shortcut
- **If the group has no shortcut but the project does**: Both the project and group get the project's shortcut
- **If neither has shortcuts**: You'll be prompted to enter a new shortcut for both

#### Example

```bash
# Set the main project for the "Mobile" group
nnapp set-main-project "Mobile"

# Or use a group shortcut
nnapp set-main-project mob
```

**Notes:**
- Only one project per group can be the main project
- If a main project already exists, you'll be asked to confirm before switching
- Projects are presented in alphabetical order for selection

---

### finder

```bash
nnapp finder
nnapp finder category [name]
nnapp finder group [name or shortcut]
nnapp finder project [name or shortcut]
```

Opens a Category, Group, or Project folder in Finder.

- `nnapp finder` launches an interactive tree browser (Categories → Groups → Projects) to pick any folder.
- Subcommands jump directly to a specific type; when no name is provided, you select from a list.

---

### script

```bash
nnapp script <subcommand>
```

Manage the terminal launch script that runs with `nnapp open`.

#### Subcommands

| Subcommand | Description |
|------------|-------------|
| `show`     | Display the saved launch script |
| `set`      | Save or update the launch script |
| `delete`   | Remove the saved launch script |

---

<!-- ### evict

```bash
nnapp evict <project name or shortcut>
```

Deletes the local folder of a project while keeping its quick-launch metadata. Useful when a project is backed by Git and can be restored via `open`.

> **Note**: This feature is still experimental and may require Git sync checks.

--- -->

## Configuration

- Project shortcuts, links, and settings are stored in `UserDefaults`
- Persistence is handled via `SwiftData` and stored under an app group container

---

## Exit Codes

- `0` — Success
- `1` — General failure or user input error
- Custom internal errors include:
  - `missingProject`, `missingGroup`, `missingCategory`
  - `shortcutTaken`, `nameTaken`, `folderExists`, etc.

---

## About This Tool

`nnapp` was built to reduce friction in managing multiple Swift/Xcode projects, especially across local and Git-based setups. Whether for open-source work, client apps, or your indie stack, it gives you a consistent and scriptable way to stay organized.

---

## Contributing

Pull requests are welcome! Open an issue or submit a PR on GitHub:

[https://github.com/nikolainobadi/nnapp](https://github.com/nikolainobadi/nnapp)

---

## License

MIT License — see [LICENSE](LICENSE) for details.
