# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

The tool pulls the latest changes for the current branch and cleans up merged branches.

### Behavior

1. Check for uncommitted changes; if dirty, prompt user and exit
2. `git fetch --prune` to sync remote state
3. Check for conflicts between local and remote branch; if conflicts exist, prompt user to rebase and exit
4. `git pull --rebase origin <current_branch>` to update
5. Only on protected branches (main, master, develop): delete local branches that are already merged
6. Supports `--dry-run` / `-d` flag to preview deletions without executing

## Build & Run

```bash
cargo build
cargo run
cargo run -- --dry-run
```

## Architecture

Single-binary CLI tool with no external dependencies (uses `std::process::Command` for git operations). All code is in `src/main.rs`. The reference Python implementation is `../git-pullclean.py`.
