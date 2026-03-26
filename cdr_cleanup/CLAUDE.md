# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

Cleans up `~/.chpwd-recent-dirs` (zsh recent directory history) by removing entries matching unwanted patterns.

## Build & Test

```bash
cargo build
cargo run
cargo run -- --dry-run
cargo run -- --stdin
cargo run -- regexp1 regexp2
cargo test
```

## Behavior

Removes entries from `~/.chpwd-recent-dirs` matching these default patterns:
- `node_modules/` in path
- `vendor` in path
- `tmp` in path
- `temp` in path
- Directories starting with `.`

Additional patterns can be passed as positional arguments (regexps).

## CLI Options

- `--dry-run` — show which entries would be removed; do not modify the file
- `--stdin` — print the updated file contents to stdout; do not modify the file
