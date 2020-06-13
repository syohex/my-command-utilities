# My Command Utilities

## Examples

```bash
# clean up zsh cdr directories which no longer exists or hidden directory
cdr_cleanup

# Print only remaining directories
cdr_cleanup --dry-run

# cleanup directories which no longer exists and are matched filter
cdr_cleanup filter_regexp

# Generate Emacs Cask file
gencask some-elisp-file.el

# Output specified language .gitignore
git-ignore python

# Delete merged branches
git delete-merged-branch

# Git blame with pull request number
# - Original code: https://gist.github.com/kazuho/eab551e5527cb465847d6b0796d64a39
git blame-pr

# Launch Emacs with my minimum configuration for testing package
test-emacs
```
