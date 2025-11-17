# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository for managing shell configurations and development environment setup across machines. It supports both zsh and bash with synchronized aliases and environment configurations.

## Installation & Setup

### Install dotfiles
```bash
./install.sh
```

This script:
- Creates symlinks from this repository to `$HOME` for all dotfiles (`.zshrc`, `.bashrc`, etc.)
- Backs up existing dotfiles to `~/.dotbackup/`
- Symlinks `Taskfile.base.yml` to `$HOME`
- Copies `Taskfile.concrete.yml` to `$HOME/Taskfile.yml` (if it doesn't exist)
- Sources the appropriate rc file to apply changes

### Testing & CI

Run shellcheck on all shell scripts:
```bash
shellcheck $(git ls-files '*.sh')
```

CI automatically runs on PRs via [.github/workflows/ci.yml](.github/workflows/ci.yml):
- Runs shellcheck on all `.sh` files
- Tests the installation script in a clean environment

## Architecture

### Taskfile Pattern

The repository uses a two-tier Taskfile system (requires [go-task](https://taskfile.dev)):

- [Taskfile.base.yml](Taskfile.base.yml): Shared task definitions across all machines
  - Contains reusable tasks like `aws-exec-*-*` for ECS container access
  - Meant to be included by machine-specific Taskfiles

- [Taskfile.concrete.yml](Taskfile.concrete.yml): Template for machine-specific tasks
  - Includes `Taskfile.base.yml` and delegates to it
  - Users should copy this to `$HOME/Taskfile.yml` and customize per-machine

Run tasks with:
```bash
task                    # List all available tasks
task <task-name>        # Run specific task
```

### Dotfile Structure

Both [.zshrc](.zshrc) and [.bashrc](.bashrc) share:
- Common aliases for git (`g`, `gst`, `gc`, etc.), docker (`d`, `dc`, `dcu`, etc.), and kubernetes (`k`)
- Peco integration for interactive command history (Ctrl+R)
- Tool-specific configurations (rbenv, volta, cargo, gcloud, etc.)
- Editor set to `code -w` (VSCode with wait flag)

Zsh-specific features:
- Oh My Zsh with `robbyrussell` theme
- Zinit plugin manager for zsh-syntax-highlighting
- History sharing across sessions
- Typo correction

### Utility Scripts

[review-prs.sh](review-prs.sh): Lists GitHub PRs awaiting review
```bash
./review-prs.sh --repo OWNER/NAME [--repo OWNER/NAME]...
./review-prs.sh --repo msasaki666/hoge --format md
./review-prs.sh --all --repo msasaki666/fuga  # Fetch all pages (requires GH_TOKEN)
```

Options:
- `--reviewer USER`: Specify reviewer (default: msasaki666)
- `--repo OWNER/NAME`: Target repository (can specify multiple)
- `--extra "QUERY"`: Additional filter (e.g., "-is:draft")
- `--format table|tsv|md`: Output format
- `--all`: Fetch all pages beyond 100 limit (requires GH_TOKEN)

## Development Guidelines

### Shell Script Standards

- Use `set -euo pipefail` for strict error handling
- All scripts must pass shellcheck validation
- Use `command` builtin for external commands when appropriate
- Quote variables to handle spaces in paths

### Adding New Dotfiles

When adding a new dotfile:
1. Add the file to this repository root with `.` prefix (e.g., `.gitconfig`)
2. The install script automatically symlinks all `.??*` files
3. Test with `./install.sh` to verify symlinking works
4. Ensure shellcheck passes if it's a shell script

### Modifying Taskfiles

- Add shared/reusable tasks to [Taskfile.base.yml](Taskfile.base.yml)
- Machine-specific tasks should go in `$HOME/Taskfile.yml` (not committed)
- The base taskfile is marked `internal: true` and accessed via `base:` prefix
- Required variables should be declared with `requires.vars`
