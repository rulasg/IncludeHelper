---
agent: agent
---

# Save Branch to PR Workflow

This prompt guides through the complete workflow of saving a feature branch by creating a PR, waiting for checks, merging, and cleaning up.

## Prerequisites
- Git repository with GitHub remote
- GitHub CLI (`gh`) installed and authenticated
- Current branch should be a feature branch (not `main`)

## Workflow Steps

### Step 1: Verify Current Branch
Check that we are NOT on the `main` branch. If on `main`, stop and inform the user.

```powershell
$currentBranch = git branch --show-current
if ($currentBranch -eq "main") {
    Write-Error "Cannot run this workflow from the main branch. Please checkout a feature branch first."
    return
}
Write-Host "Current branch: $currentBranch"
```

### Step 2: Push Branch and Create PR
Push the current branch to remote and create a Pull Request.

```powershell
# Push branch to remote
git push -u origin $currentBranch

# Create PR with auto-fill from commit messages
gh pr create --fill
```

If a PR already exists for this branch, continue with the existing PR.

### Step 3: Wait for Workflow Checks
Wait for all GitHub Actions workflow checks to complete and verify they pass.

```powershell
# Wait for checks to complete (will block until done)
gh pr checks --watch --required --interval 1 --fail-fast

# Verify all checks passed
$checksResult = gh pr checks
if ($LASTEXITCODE -ne 0) {
    Write-Error "Some checks failed. Please review and fix before merging."
    return
}
Write-Host "All checks passed!"
```

### Step 4: Merge the PR
Merge the PR using a regular merge to preserve the branch history, and delete the remote branch.

```powershell
# Merge PR and delete remote branch (regular merge to keep history)
gh pr merge --merge --delete-branch
```

### Step 5: Clean Up Local Branch
Switch to main and delete the local feature branch.

```powershell
# Switch to main branch
git checkout main

# Pull latest changes
git pull

# Delete local feature branch
git branch -d $currentBranch
```

### Step 6: Check and Remove Codespaces
Check if there are any codespaces associated with this branch and remove them.

```powershell
# List codespaces for this repository
$codespaces = gh codespace list --json name,gitStatus,repository --jq ".[] | select(.gitStatus.ref == `"$currentBranch`")"

if ($codespaces) {
    Write-Host "Found codespaces on branch $currentBranch. Removing..."
    # Delete codespaces on this branch
    gh codespace list --json name,gitStatus --jq ".[] | select(.gitStatus.ref == `"$currentBranch`") | .name" | ForEach-Object {
        gh codespace delete --codespace $_ --force
        Write-Host "Deleted codespace: $_"
    }
} else {
    Write-Host "No codespaces found on branch $currentBranch"
}
```

## Success Criteria
- [ ] Verified not on main branch
- [ ] PR created and pushed to remote
- [ ] All workflow checks passed
- [ ] PR merged successfully
- [ ] Local and remote feature branches deleted
- [ ] Any codespaces on the branch removed

## Error Handling
- If on `main` branch: Stop immediately with clear message
- If checks fail: Stop and inform user to fix issues
- If merge conflicts: Stop and inform user to resolve conflicts
- If codespace deletion fails: Log warning but continue