# nnapp

![Build Status](https://github.com/nikolainobadi/nnapp/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platform](https://img.shields.io/badge/platform-macOS%2014-blue)
![License](https://img.shields.io/badge/license-MIT-lightgray)

## Overview

**nnapp** is a command-line utility designed to manage and launch Xcode projects and Swift packages with ease. It organizes your local development environment into **Categories**, **Groups**, and **Projects**, supporting both local file system operations and Git integrations.

Think of it as a personalized project launcher with just enough metadata to keep your Swift workspace tidy and quickly accessible.

**Stability Notice (v0.5.0)**  
`nnapp` is functional and ready to use, but its features and API may evolve as it becomes more flexible and robust.  
Breaking changes are possible before reaching v1.0.0.  
Your feedback and suggestions are welcome as the project continues to improve!


## Features

- Create, import, or remove **Categories**, **Groups**, and **Projects**
- Launch Xcode or VSCode with optional terminal workflows
- Open remote repositories or linked documentation instantly
- Automatically clone projects from Git remotes if missing locally
- Manage custom quick-launch shortcuts
- Stores metadata using `SwiftData` and `UserDefaults`
- Shell integration via `SwiftShell`
- Fully interactive CLI built on `ArgumentParser`

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

### Example Commands

- Create a new category:
  ```sh
  nnapp create category "Platform"
  ```

- Add a new project:
  ```sh
  nnapp add project --path ~/dev/MyApp --group Mobile
  ```

- Open project in Xcode with terminal:
  ```sh
  nnapp open abc
  ```

- Remove a group:
  ```sh
  nnapp remove group "Mobile"
  ```

- List all registered entities:
  ```sh
  nnapp list
  ```

---

## Architecture Notes

The project follows a clean, protocol-driven structure:

- `CodeLaunchContext`: Core model and persistence handler
- `Handlers`: Orchestrate logic per domain (category, group, project)
- `Shell`: Abstracted shell interaction
- `SwiftPicker`: Handles interactive prompts and selections
- `SwiftData`: For structured, lightweight local storage
- `NnGitKit`: For convenient Git interactions

Each entity (`Category`, `Group`, `Project`) is managed via a declarative `@Model` and persists automatically using SwiftData.

---

## Documentation

- Inline documentation is provided via comments and docstrings
- Source code is organized for discoverability
- See each command's `run()` method and its related `Handler` for usage flow

For more details and advanced usage, refer to the [Documentation](./docs/Documentation.md)

---

## Acknowledgments

### Third-Party Libraries
- [`SwiftShell`](https://github.com/kareman/SwiftShell) — for shell execution
- [`ArgumentParser`](https://github.com/apple/swift-argument-parser) — for CLI parsing
- [`Files`](https://github.com/JohnSundell/Files) — for filesystem handling

### My Swift Packages
- [`NnGitKit`](https://github.com/nikolainobadi/NnGitKit) — Git commands abstraction
- [`SwiftPicker`](https://github.com/nikolainobadi/SwiftPicker) — interactive CLI prompts
- [`NnSwiftDataKit](https://github.com/nikolainobadi/NnSwiftDataKit) - shared SwiftData setup

---

## About This Project

`nnapp` was created to simplify the chaos of managing local and remote Swift/Xcode projects. Whether you're working on open-source libraries, client apps, or personal projects, this tool gives you a structured and scriptable way to organize and launch them — without the hassle of opening Finder or remembering folder paths.

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
