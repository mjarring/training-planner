#!/usr/bin/env bash
set -euo pipefail
cd /home/runner

# A restarted container keeps its filesystem, so wipe state from the previous job
rm -rf _work .runner .credentials .credentials_rsaparams .env .path

# Exchange the PAT for a short-lived registration token
REG_TOKEN=$(curl -fsS -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${REPO}/actions/runners/registration-token" | jq -r .token)

# Remove the PAT from the environment so workflow steps can never see it
unset ACCESS_TOKEN

./config.sh --unattended --ephemeral --replace --disableupdate \
  --url "https://github.com/${REPO}" \
  --token "${REG_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "${RUNNER_LABELS}"

unset REG_TOKEN
exec ./run.sh
