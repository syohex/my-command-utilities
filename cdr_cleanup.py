#!/usr/bin/env python3
import argparse
import re
from pathlib import Path
from typing import List, Set, Tuple

ignore_dir_re = re.compile(r'/(?:\.|node_modules|_?vendor|tmp)')


def cdr_file() -> Path:
    return Path(Path.home(), '.chpwd-recent-dirs')


def is_deleted_directory(directory: Path) -> bool:
    global ignore_dir_re

    if not directory.exists():
        return True

    if ignore_dir_re.search(str(directory)):
        return True

    return False


def collect_live_directories() -> Tuple[List[str], int]:
    lines: List[str] = []
    keep_dirs: Set[Path] = set()
    deleted = 0

    with open(str(cdr_file()), 'r', encoding='utf-8') as f:
        line_re = re.compile(r"^\$'(.*)'$")
        for line in [x.strip() for x in f.readlines()]:
            match = line_re.search(line)
            if match is None:
                continue

            directory = Path(match.group(1))
            if is_deleted_directory(directory):
                deleted += 1
                continue

            if directory in keep_dirs:
                deleted += 1
                continue

            keep_dirs.add(directory)
            lines.append(line)

    return lines, deleted


def filter_lines(lines: List[str], regexps: List[str]) -> Tuple[List[str], int]:
    ret: List[str] = []
    filtered = 0
    for regexp in regexps:
        r = re.compile(fr'{regexp}')
        for line in lines:
            if r.search(line):
                filtered += 1
                continue

            ret.append(line)

    return ret, filtered


def main():
    parser = argparse.ArgumentParser(description='cleanup zsh cdr non existed directories')
    parser.add_argument('--dry-run', action='store_true', default=False, dest='dry_run')
    parser.add_argument('filters', nargs='*')
    args = parser.parse_args()

    keep_lines, deleted = collect_live_directories()

    filtered = 0
    if len(args.filters) > 0:
        keep_lines, filtered = filter_lines(keep_lines, args.filters)

    if args.dry_run:
        for line in keep_lines:
            print(line)
    else:
        with open(str(cdr_file()), 'w', encoding='utf-8') as f:
            for line in keep_lines:
                f.write(line + '\n')

    print(f'Delete {deleted} directories, Filter {filtered} directories')


if __name__ == '__main__':
    main()
