#!/usr/bin/env bash
# Print version information for installed binaries.

set -e

DOCKER_IMAGE="${1}"

commands=(
  "git --version"
  "ssh -V"
  "lsof -v"
  "zip --version"
  "unzip -v"
  "vim --version"
  "lynx --version"
  "curl --version"
  "aspell --version"
  "jq --version"
  "tree --version"
  "rsync --version"
  "shellcheck --version"
  "docker --version"
  "docker compose version"
  "docker buildx version"
  "docker-compose version"
  "php --version"
  "composer --version"
  "npm --version"
  "npx --version"
  "node --version"
  "goss --version"
  "bats --version"
  "ahoy --version"
  "tree --version"
  "rsync --version"
)

for command in "${commands[@]}"; do
  echo "----------------------------------------"
  echo "${command%% *}"
  echo "----------------------------------------"
  # shellcheck disable=SC2086
  docker run "${DOCKER_IMAGE}" ${command}
  echo "----------------------------------------"
  echo
done;
