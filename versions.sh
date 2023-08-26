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
  "shfmt --version"
  "docker --version"
  "docker compose version"
  "docker buildx version"
  "php --version"
  "composer --version"
  "npm --version"
  "npx --version"
  "node --version"
  "goss --version"
  "bats --version"
  "kcov --version"
  "ahoy --version"
  "task --version"
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
