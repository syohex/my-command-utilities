# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

run-test はプロジェクトの言語関係なくテストコマンドを実行するコマンド。Rust で実装する (sibling の `git-pullclean` と同じパターン)。

## 目的

- 現在のディレクトリがどの言語(ツール)を使っているプロジェクトかを特定し, それに応じたテストコマンドを実行する
- デフォルトの挙動は最も浅いレベルのプロジェクトに対してテストコマンドを実行する
  - ネストされているプロジェクトではルートディレクトリではテストコマンドをデフォルトでは実行しない
  - コマンドラインフラグでルートディレクトリでテストを実行する機能を提供する

## サポート言語, 環境

- Rust (`cargo test`)
- Go (`go test ./...`)
- Makefileがあり, かつ `make test` が実行できるプロジェクト

## Build & Run

```bash
cargo build
cargo run
cargo test
```
