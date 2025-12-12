# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.1] - 2025-12-11

### Fixed
- IDE no longer opens when using `--only-terminal` flag with `open` command

## [0.7.0] - 2025-12-08

### Changed
- Major internal refactoring: extracted CodeLaunchKit framework for better separation of concerns
- Migrated from SwiftShell to NnShellKit (v2.2.0+)
- Migrated from SwiftPicker to SwiftPickerKit (v0.8.0+)
- Improved group selection UI when adding new projects
- Improved selection experience when removing groups
- Enhanced folder browsing to always start at home directory
- Added user confirmation prompts before creating or importing categories

### Fixed
- Folder browsing now correctly supports direct folder selection when path is provided during category create/import operations

### Removed
- Temporarily disabled `script` subcommand (will be re-enabled in a future release)

## [0.6.1] - 2025-10-04

### Changed
- Improved error handling patterns in test suites for better reliability and consistency

## [0.6.0] - 2025-09-02

### Added
- New `script` command to handle CRUD operations for extra launch scripts
- New `set-main-project` command to designate the main project for a group
- `--from-desktop` flag in `add project` command to allow project selection from Desktop folder
- Comprehensive test suites for `GroupHandler` and `ProjectHandler`
- Project-level documentation in `CLAUDE.md`

### Changed
- Updated project organization with reorganized test folder structure
- Updated to latest package versions to remove deprecation warnings
- Made `createNewGroupFolder` method in `GroupHandler` more robust with improved validation

### Fixed
- Fatal error handling in `DefaultShell` - removed `fatalError` calls for better error management
- VSCode integration bug where project file was being opened instead of project folder
- Flaky tests in `GroupHandler` and `ProjectHandler` test suites

## [0.5.1] - 2025-04-27

### Fixed
- VSCode integration now correctly opens project folder instead of project file

## [0.5.0] - 2025-03-31

### Added
- Initial release with core functionality
- `add` command with subcommands for categories, groups, projects, and links
- `create` command for creating new categories and groups
- `remove` command for deleting categories, groups, projects, and links
- `list` command to display categories, groups, projects, and links
- `open` command to launch projects in Xcode with optional terminal integration
- `finder` command to open project locations in Finder
- Terminal integration with configurable terminal options (iTerm/Terminal)
- Git integration for branch information and repository management
- SwiftData persistence with app group support
- Interactive CLI prompts using SwiftPicker
- Comprehensive unit test coverage
- CI/CD workflow with GitHub Actions
- Project documentation and README
