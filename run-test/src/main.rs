use std::env;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

#[derive(Debug)]
enum ProjectType {
    Rust,
    Go,
    Makefile,
}

impl ProjectType {
    fn test_command(&self) -> (&str, &[&str]) {
        match self {
            ProjectType::Rust => ("cargo", &["test"]),
            ProjectType::Go => ("go", &["test", "./..."]),
            ProjectType::Makefile => ("make", &["test"]),
        }
    }

    fn label(&self) -> &str {
        match self {
            ProjectType::Rust => "Rust (cargo test)",
            ProjectType::Go => "Go (go test ./...)",
            ProjectType::Makefile => "Makefile (make test)",
        }
    }
}

fn detect_project_type(dir: &Path) -> Option<ProjectType> {
    if dir.join("Cargo.toml").exists() {
        return Some(ProjectType::Rust);
    }
    if dir.join("go.mod").exists() {
        return Some(ProjectType::Go);
    }
    if dir.join("Makefile").exists() && makefile_has_test_target(dir) {
        return Some(ProjectType::Makefile);
    }
    None
}

fn makefile_has_test_target(dir: &Path) -> bool {
    let output = Command::new("make")
        .args(["-n", "test"])
        .current_dir(dir)
        .output();

    match output {
        Ok(o) => o.status.success(),
        Err(_) => false,
    }
}

/// Walk from `start` upward to find all project roots, returning them
/// from shallowest (closest to filesystem root) to deepest (closest to `start`).
fn find_project_roots(start: &Path) -> Vec<PathBuf> {
    let mut roots = Vec::new();
    let mut dir = start.to_path_buf();

    loop {
        if detect_project_type(&dir).is_some() {
            roots.push(dir.clone());
        }

        if !dir.pop() {
            break;
        }
    }

    roots.reverse();
    roots
}

fn run_test(dir: &Path) -> Result<(), String> {
    let project_type =
        detect_project_type(dir).ok_or_else(|| format!("No supported project found in {}", dir.display()))?;

    println!("Running tests in {} [{}]", dir.display(), project_type.label());

    let (cmd, args) = project_type.test_command();
    let status = Command::new(cmd)
        .args(args)
        .current_dir(dir)
        .status()
        .map_err(|e| format!("Failed to execute {} {}: {}", cmd, args.join(" "), e))?;

    if !status.success() {
        return Err(format!(
            "Test failed in {} with exit code {}",
            dir.display(),
            status.code().unwrap_or(-1)
        ));
    }

    Ok(())
}

fn run(root: bool) -> Result<(), String> {
    let cwd = env::current_dir().map_err(|e| format!("Failed to get current directory: {e}"))?;

    let roots = find_project_roots(&cwd);
    if roots.is_empty() {
        return Err("No supported project found in current or parent directories".to_string());
    }

    if root {
        // --root: run tests at the shallowest (root) project
        run_test(&roots[0])
    } else {
        // Default: run tests at the deepest (most nested) project
        run_test(roots.last().unwrap())
    }
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.iter().any(|a| a == "--help" || a == "-h") {
        println!("Usage: run-test [OPTIONS]");
        println!();
        println!("Run test commands based on the project type detected in the current directory.");
        println!();
        println!("Options:");
        println!("  -r, --root  Run tests at the root project level (shallowest)");
        println!("  -h, --help  Show this help message");
        return ExitCode::SUCCESS;
    }

    let root = args.iter().any(|a| a == "--root" || a == "-r");

    match run(root) {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("{e}");
            ExitCode::FAILURE
        }
    }
}
