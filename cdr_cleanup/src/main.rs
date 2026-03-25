use clap::Parser;
use regex::Regex;
use std::fs;
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "cdr_cleanup")]
#[command(about = "Clean up ~/.chpwd-recent-dirs by removing unwanted directory entries")]
struct Cli {
    /// Show entries that would be removed without modifying the file
    #[arg(long)]
    dry_run: bool,

    /// Print updated file contents to stdout without modifying the file
    #[arg(long)]
    stdin: bool,

    /// Additional regex patterns to filter out
    patterns: Vec<String>,
}

const DEFAULT_PATTERNS: &[&str] = &[
    r"node_modules/",
    r"vendor",
    r"tmp",
    r"temp",
];

fn is_hidden_dir(path: &str) -> bool {
    path.split('/')
        .filter(|s| !s.is_empty())
        .any(|component| component.starts_with('.'))
}

fn should_remove(path: &str, default_regexes: &[Regex], extra_regexes: &[Regex]) -> bool {
    if !PathBuf::from(path).exists() {
        return true;
    }
    if is_hidden_dir(path) {
        return true;
    }
    for re in default_regexes.iter().chain(extra_regexes.iter()) {
        if re.is_match(path) {
            return true;
        }
    }
    false
}

/// Parse a path from a chpwd-recent-dirs line.
/// Lines are typically in the format: $'path'
fn parse_path(line: &str) -> Option<&str> {
    let trimmed = line.trim();
    if trimmed.is_empty() {
        return None;
    }
    if let Some(inner) = trimmed.strip_prefix("$'").and_then(|s| s.strip_suffix('\'')) {
        Some(inner)
    } else {
        Some(trimmed)
    }
}

fn main() {
    let cli = Cli::parse();

    let home = std::env::var("HOME").expect("HOME environment variable not set");
    let file_path = PathBuf::from(&home).join(".chpwd-recent-dirs");

    if !file_path.exists() {
        eprintln!("File not found: {}", file_path.display());
        std::process::exit(1);
    }

    let contents = fs::read_to_string(&file_path).expect("Failed to read ~/.chpwd-recent-dirs");

    let default_regexes: Vec<Regex> = DEFAULT_PATTERNS
        .iter()
        .map(|p| Regex::new(p).expect("Invalid default regex pattern"))
        .collect();

    let extra_regexes: Vec<Regex> = cli
        .patterns
        .iter()
        .map(|p| Regex::new(p).unwrap_or_else(|e| panic!("Invalid regex pattern '{}': {}", p, e)))
        .collect();

    let lines: Vec<&str> = contents.lines().collect();
    let mut kept = Vec::new();
    let mut removed = Vec::new();

    for line in &lines {
        if let Some(path) = parse_path(line) {
            if should_remove(path, &default_regexes, &extra_regexes) {
                removed.push(*line);
            } else {
                kept.push(*line);
            }
        }
    }

    if cli.dry_run {
        for line in &removed {
            println!("{}", line);
        }
    } else if cli.stdin {
        for line in &kept {
            println!("{}", line);
        }
    } else {
        let mut output = kept.join("\n");
        if !output.is_empty() {
            output.push('\n');
        }
        fs::write(&file_path, output).expect("Failed to write ~/.chpwd-recent-dirs");
    }

    println!("Removed {} entries", removed.len());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_path() {
        assert_eq!(parse_path("$'/home/user/project'"), Some("/home/user/project"));
        assert_eq!(parse_path("/home/user/project"), Some("/home/user/project"));
        assert_eq!(parse_path(""), None);
        assert_eq!(parse_path("  "), None);
    }

    #[test]
    fn test_is_hidden_dir() {
        assert!(is_hidden_dir("/home/user/.config"));
        assert!(is_hidden_dir("/home/user/.local/share"));
        assert!(!is_hidden_dir("/home/user/project"));
        assert!(!is_hidden_dir("/home/user/project/src"));
    }

    #[test]
    fn test_default_patterns_match() {
        let regexes: Vec<Regex> = DEFAULT_PATTERNS
            .iter()
            .map(|p| Regex::new(p).unwrap())
            .collect();

        let matches = |path: &str| regexes.iter().any(|re| re.is_match(path));

        assert!(matches("/home/user/project/node_modules/foo"));
        assert!(matches("/home/user/project/vendor/bundle"));
        assert!(matches("/home/user/tmp/scratch"));
        assert!(matches("/home/user/temp/data"));
        assert!(!matches("/home/user/project/src"));
    }
}
