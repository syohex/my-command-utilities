use std::process::{Command, ExitCode};

const PROTECTED_BRANCHES: &[&str] = &["main", "master", "develop"];

fn git_output(args: &[&str]) -> Result<String, String> {
    let output = Command::new("git")
        .args(args)
        .output()
        .map_err(|e| format!("Failed to execute git {}: {}", args[0], e))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(format!("Failed 'git {}':\n{}", args.join(" "), stderr));
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

fn git_run(args: &[&str]) -> Result<(), String> {
    let status = Command::new("git")
        .args(args)
        .status()
        .map_err(|e| format!("Failed to execute git {}: {}", args[0], e))?;

    if !status.success() {
        return Err(format!("Failed 'git {}'", args.join(" ")));
    }

    Ok(())
}

fn is_repository_clean() -> Result<bool, String> {
    let status = Command::new("git")
        .args(["diff", "--quiet"])
        .status()
        .map_err(|e| format!("Failed to execute git diff: {e}"))?;

    Ok(status.success())
}

fn current_branch() -> Result<String, String> {
    git_output(&["branch", "--show-current"])
}

fn git_root() -> Result<String, String> {
    git_output(&["rev-parse", "--show-toplevel"])
}

fn has_conflicts(branch: &str) -> Result<bool, String> {
    let remote_ref = format!("origin/{branch}");
    // Check if remote branch exists
    if git_output(&["rev-parse", "--verify", &remote_ref]).is_err() {
        return Ok(false);
    }

    let merge_base = git_output(&["merge-base", "HEAD", &remote_ref])?;
    let local_tree = git_output(&["rev-parse", "HEAD^{tree}"])?;
    let remote_tree = git_output(&["rev-parse", &format!("{remote_ref}^{{tree}}")])?;

    if local_tree == remote_tree || merge_base == git_output(&["rev-parse", "HEAD"])? {
        return Ok(false);
    }

    // Try merge-tree to detect conflicts
    let output = Command::new("git")
        .args(["merge-tree", &merge_base, "HEAD", &remote_ref])
        .output()
        .map_err(|e| format!("Failed to execute git merge-tree: {e}"))?;

    let result = String::from_utf8_lossy(&output.stdout);
    Ok(result.contains("<<<<<<<"))
}

fn merged_branches() -> Result<Vec<String>, String> {
    let output = git_output(&["branch", "--merged"])?;

    let branches: Vec<String> = output
        .lines()
        .filter(|line| !line.starts_with('*') && !line.starts_with('+'))
        .map(|line| line.trim().to_string())
        .filter(|branch| !branch.is_empty() && !PROTECTED_BRANCHES.contains(&branch.as_str()))
        .collect();

    Ok(branches)
}

fn run(dry_run: bool) -> Result<(), String> {
    if !is_repository_clean()? {
        eprintln!("This repository has some changes. Please check them before updating");
        return Ok(());
    }

    let branch = current_branch()?;
    let root = git_root()?;

    git_run(&["-C", &root, "fetch", "--prune"])?;

    if has_conflicts(&branch)? {
        eprintln!(
            "Conflicts detected between local and remote branch. Please rebase or resolve conflicts first"
        );
        return Ok(());
    }

    let status = Command::new("git")
        .args(["pull", "--rebase", "origin", &branch])
        .current_dir(&root)
        .status()
        .map_err(|e| format!("Failed to execute git pull: {e}"))?;

    if !status.success() {
        return Err(format!("Failed 'git pull --rebase origin {branch}'"));
    }

    if !PROTECTED_BRANCHES.contains(&branch.as_str()) {
        println!("Skip deleting merged branches");
        return Ok(());
    }

    let branches = merged_branches()?;
    if branches.is_empty() {
        println!("There is no merged branch");
        return Ok(());
    }

    if dry_run {
        println!("Dry run");
    }

    for b in &branches {
        println!("Delete {b}");

        if dry_run {
            continue;
        }

        git_run(&["branch", "-d", b])?;
    }

    println!("Delete {} branches", branches.len());

    Ok(())
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();

    let dry_run = args.iter().any(|a| a == "--dry-run" || a == "-d");

    if args.iter().any(|a| a == "--help" || a == "-h") {
        println!("Usage: git-pullclean [OPTIONS]");
        println!();
        println!("Options:");
        println!("  -d, --dry-run  Preview branch deletions without executing");
        println!("  -h, --help     Show this help message");
        return ExitCode::SUCCESS;
    }

    match run(dry_run) {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("{e}");
            ExitCode::FAILURE
        }
    }
}
