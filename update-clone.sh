#!/bin/bash
set -euo pipefail

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# === Environment setup ===
export PATH="/usr/local/bin:/usr/bin:/bin"
GITHUB_URL="https://github.com/Lynch0001/gitlab-test.git"
GITLAB_URL="git@gitlab.com:group-lynch/gitlab-test.git"
WORKDIR="/Users/timothylynch/workspace/migrate/gitlab-test.git"
LOGFILE="/Users/timothylynch/workspace/gitlab-test/git-sync.log"
GIT_BIN="/usr/bin/git"

echo "==== $(date): Starting sync ====" >> "$LOGFILE"
echo "Running as user: $(whoami)" >> "$LOGFILE"
echo "Current PATH: $PATH" >> "$LOGFILE"

cd "$WORKDIR"

# === Verify/Set remotes ===
if ! "$GIT_BIN" remote get-url gitlab &>/dev/null; then
  "$GIT_BIN" remote add gitlab "$GITLAB_URL"
fi
"$GIT_BIN" remote set-url origin "$GITHUB_URL"

# === Pruning ===
echo "Pruning ..." >> "$LOGFILE"
"$GIT_BIN" prune origin
"$GIT_BIN" prune gitlab

# === Fetch from github ===
echo "Fetching from github..." >> "$LOGFILE"
"$GIT_BIN" fetch origin

# === Push to GitLab ===
echo "Force Pushing to GitLab..." >> "$LOGFILE"
"$GIT_BIN" push gitlab --mirror

echo "==== $(date): Sync complete ====" >> "$LOGFILE"
