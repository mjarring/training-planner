#!/usr/bin/env bash
# Start/stop the self-hosted GitHub Actions runner container on this machine.
#
# Usage: ci/github-runner/start.sh [start|stop|restart|logs|status]
#   start    (default) build the image and start the runner in the background
#   stop     stop and remove the runner container
#   restart  stop, then start
#   logs     follow the runner logs
#   status   show container state
#
# The PAT lives OUTSIDE the repo. Default: ~/.config/github-runner/env
# Override with: CI_RUNNER_ENV_FILE=/path/to/env ci/github-runner/start.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"
ENV_FILE="${CI_RUNNER_ENV_FILE:-${HOME}/.config/github-runner/env}"
PROJECT_NAME="training-planner"

die() {
  echo "error: $*" >&2
  exit 1
}

# Use sudo for docker unless already root (we deliberately avoid the docker group).
if [[ ${EUID} -eq 0 ]]; then
  SUDO=()
else
  command -v sudo >/dev/null || die "sudo is required (or run as root)"
  SUDO=(sudo)
fi

compose() {
  "${SUDO[@]}" docker compose \
    --project-name "${PROJECT_NAME}" \
    --env-file "${ENV_FILE}" \
    -f "${COMPOSE_FILE}" \
    "$@"
}

check_prereqs() {
  command -v docker >/dev/null || die "docker not found. Install it: sudo pacman -S docker docker-compose"
  [[ -f "${COMPOSE_FILE}" ]] || die "compose file not found: ${COMPOSE_FILE}"
  [[ -f "${ENV_FILE}" ]] || die "env file not found: ${ENV_FILE}
Create it with a line like:  GH_PAT_TRAINING_PLANNER=github_pat_xxxxxxxx   (then chmod 600 it)"

  # The token file must not be readable by other users.
  local perms
  perms="$(stat -c '%a' "${ENV_FILE}")"
  if [[ "${perms}" != "600" && "${perms}" != "400" ]]; then
    die "${ENV_FILE} has permissions ${perms}; run: chmod 600 ${ENV_FILE}"
  fi

  grep -Eq '^GH_PAT_TRAINING_PLANNER=.+' "${ENV_FILE}" || die "GH_PAT_TRAINING_PLANNER is not set in ${ENV_FILE}"
  if grep -q 'replace_me' "${ENV_FILE}"; then
    die "GH_PAT_TRAINING_PLANNER in ${ENV_FILE} is still the placeholder value"
  fi

  # Make sure the Docker daemon is running.
  if ! "${SUDO[@]}" docker info >/dev/null 2>&1; then
    echo "Docker daemon not running; starting it..."
    "${SUDO[@]}" systemctl start docker.service
  fi
}

# entrypoint.sh and the Dockerfile run with your PAT, so be careful about
# building from code you haven't reviewed.
check_ci_changes() {
  command -v git >/dev/null || return 0
  git -C "${SCRIPT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  echo "Building from commit: $(git -C "${SCRIPT_DIR}" log -1 --format='%h %s')"

  if [[ -n "$(git -C "${SCRIPT_DIR}" status --porcelain -- "${SCRIPT_DIR}")" ]]; then
    echo
    echo "WARNING: uncommitted changes in ci/github-runner/:"
    git -C "${SCRIPT_DIR}" status --short -- "${SCRIPT_DIR}"
    echo
    read -r -p "These files will run with access to your PAT. Continue? [y/N] " answer
    [[ "${answer}" =~ ^[Yy]$ ]] || die "aborted"
  fi
}

cmd="${1:-start}"

case "${cmd}" in
start)
  check_prereqs
  check_ci_changes
  compose up -d --build
  echo
  echo "Runner started. Follow logs with: ${0} logs"
  echo "It should appear as Idle under Settings -> Actions -> Runners."
  ;;
stop)
  check_prereqs
  compose down
  ;;
restart)
  check_prereqs
  check_ci_changes
  compose down
  compose up -d --build
  ;;
logs)
  check_prereqs
  compose logs -f --tail=100
  ;;
status)
  check_prereqs
  compose ps
  ;;
-h | --help | help)
  sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  ;;
*)
  die "unknown command '${cmd}' (use: start | stop | restart | logs | status)"
  ;;
esac
