# Self Hosted GitHub Actions Runner

This directory contains everything needed to set up and run a self-hosted
GitHub Actions runner in a Docker container.

## Files

| File | Purpose |
| --- | --- |
| `Dockerfile` | Builds on `ghcr.io/actions/actions-runner` (GitHub's official image) and adds `git`, and `pre-commit` |
| `entrypoint.sh` | Exchanges the PAT for a short-lived registration token, registers an ephemeral runner, then starts it |
| `docker-compose.yml` | Defines the runner service (restart policy, dropped capabilities, no-new-privileges) |
| `start.sh` | Helper script to start, stop and inspect the runner from your PC |
| `.env.example` | Placeholder showing the format of the token file. **Never put a real token here.** |

## One-time setup

### 1. Create the PAT

GitHub → **Settings → Credentials → Fine-grained personal access tokens**:

- Repository access: **only this repository**
- Permission: **Administration: Read and write** (required to create runner
  registration tokens)
- Set an expiry and note it somewhere, because the runner stops working when
  the token expires.

### 2. Store the PAT outside the repo

```bash
mkdir -p ~/.config/github-runner
cp ci/github-runner/.env.example ~/.config/github-runner/env
$EDITOR ~/.config/github-runner/env      # set GH_PAT_TRAINING_PLANNER=github_pat_...
chmod 600 ~/.config/github-runner/env
```

The token file must stay **outside** the repository. `.gitignore` excludes
`.env` and `*.env` as a safety net, but do not rely on it. If a token is ever
committed, revoke it on GitHub immediately. Rewriting history is not enough.

## Usage

Run from anywhere (the script locates its own files):

```bash
ci/github-runner/start.sh            # build and start the runner (default)
ci/github-runner/start.sh status     # show container state
ci/github-runner/start.sh logs       # follow logs
ci/github-runner/start.sh restart    # rebuild and restart
ci/github-runner/start.sh stop       # stop and remove the container
```
