# nnapp

## Introduction

**nnapp** is a command-line utility designed to manage and launch Xcode projects, Swift packages, and workspaces with ease. It structures your development environment into **Categories**, **Groups**, and **Projects**, each with associated metadata. Whether you’re launching via Xcode, VSCode, or terminal, `nnapp` lets you organize, search, and open your projects faster than ever.

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

Open a project in Xcode and terminal:

```bash
nnapp open abc
```

---

## Table of Contents

- [Command Overview](#command-overview)
- [add](#add)
- [create](#create)
- [remove](#remove)
- [list](#list)
- [open](#open)
- [finder](#finder)
<!-- - [evict](#evict) -->
- [Configuration](#configuration)
- [Exit Codes](#exit-codes)
- [About This Tool](#about-this-tool)
- [Contributing](#contributing)
- [License](#license)

---

## Command Overview

| Command     | Description |
|-------------|-------------|
| `add`       | Register a Category, Group, Project, or Link from an existing folder |
| `create`    | Create a new Category or Group folder and register it in the database |
| `remove`    | Unregister a Category, Group, Project, or Link from the database |
| `list`      | Display all registered Categories, Groups, Projects, or Links |
| `open`      | Open a Project or Group in Xcode/VSCode, or open associated URLs |
| `finder`    | Open a Category, Group, or Project in Finder |
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
| `-l`        | Open a custom project link                   |
| `-g`        | List projects in group associated with shortcut to select a project to open|
| `-n`        | Only launches project, don't launch terminal |
| `-t`        | Only launch terminal, don't launch project   |

---

### finder

```bash
nnapp finder <name> [-c|-g|-p]
```

Opens a Category, Group, or Project folder in Finder.

#### Flags

| Flag        | Description         |
|-------------|---------------------|
| `-c`        | Open a Category     |
| `-g`        | Open a Group        |
| `-p`        | Open a Project (default) |

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
