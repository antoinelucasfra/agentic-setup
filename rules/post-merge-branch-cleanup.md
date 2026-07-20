# Post-merge branch cleanup

Once a PR is merged to main, delete the branch:
- Remote: `git push origin --delete <branch>`
- Local: `git checkout main && git branch -d <branch>`
