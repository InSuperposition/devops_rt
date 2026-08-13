# Git and GitHub Actions exercise

This directory contains the files for the Git and GitHub Actions exercise. The
repository is [InSuperposition/devops_rt](https://github.com/InSuperposition/devops_rt).

## Files

| File | Purpose |
| --- | --- |
| `1.txt` | First text file used by the exercise |
| `2.txt` | Second text file used by the exercise |
| `test.sh` | Prints `1.txt` and `2.txt` |
| `../.github/workflows/action.yml` | Runs the three GitHub Actions jobs |

## Part 1: Git exercise

Part 1 is performed manually with the GitHub UI and Git. It is not automated
by a script. The required end state includes `1.txt`, `2.txt`, `3.txt`, and
`4.txt`, plus tags `v0.0.0` and `v0.0.1` on GitHub.

When both local Git and the GitHub UI add a line to `2.txt`, pull the remote
commit before pushing the local commit. If Git reports a conflict, edit the
file so it keeps both lines, remove the conflict markers, and commit the
resolution before pushing.

To confirm that every local tag exists on the remote:

```sh
git fetch --tags origin
git tag --list
git ls-remote --tags origin
```

## Part 2: GitHub Actions

The workflow starts only when manually selected from the repository's
**Actions** page and **Run workflow** is clicked. It runs three independent
jobs:

1. Prints `Hello`, the Ubuntu version, and the triggering commit SHA.
2. Lists the files in `git/`, prints every `.txt` file there, and runs
   `git/test.sh`.
3. Prints the first name from an environment variable, the last name from a
   shell-local variable, and the phone number from a GitHub Actions secret.

Run the test script locally from any directory with:

```sh
bash git/test.sh
```

### Add the phone secret

The phone number must not be committed. Add it to the repository on GitHub:

1. Open **Settings**.
2. Select **Secrets and variables** and then **Actions**.
3. Select **New repository secret**.
4. Enter `PHONE_NUMBER` as the name.
5. Enter the phone number as the secret and select **Add secret**.

GitHub masks the secret in workflow logs. If `PHONE_NUMBER` has not been
created, the workflow receives an empty value and Job 3 fails with a useful
error rather than printing a blank phone number.

### Test the workflow with GitHub CLI

GitHub CLI runs the workflow on GitHub, so the workflow and exercise files
must be committed and pushed first:

```sh
git add git/ .github/workflows/action.yml
git commit -m "Add GitHub Actions exercise"
git push origin main
```

Add the phone number as a secret. This command prompts for the value without
putting it in the repository or the command history:

```sh
gh secret set PHONE_NUMBER
```

Start the manually triggered workflow from the `main` branch:

```sh
gh workflow run action.yml --ref main
```

Watch the newest run until it finishes. `--exit-status` makes the command exit
with a failure status when any workflow job fails:

```sh
gh run watch --exit-status
```

Useful commands for checking runs and reading their logs:

```sh
gh workflow list
gh run list --workflow action.yml
gh run view --log
gh run view --log-failed
gh run view --web
```

### Add an automatic trigger later

To run the workflow when files in this exercise change, add this alongside
`workflow_dispatch` under `on`:

```yaml
push:
  paths:
    - "git/**"
    - ".github/workflows/action.yml"
```
