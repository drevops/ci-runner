#!/usr/bin/env bash
# Print version information for installed binaries.

set -e

DOCKER_IMAGE="${1}"

commands=(
  "aspell --version"
  "bats --version"
  "composer --version"
  "codecov --version"
  "curl --version"
  "docker --version"
  "docker buildx version"
  "docker compose version"
  "git --version"
  "gpg --version"
  "jq --version"
  "kcov --version"
  "lsof -v"
  "lynx --version"
  "node --version"
  "npm --version"
  "npx --version"
  "php --version"
  "rsync --version"
  "shellcheck --version"
  "shfmt --version"
  "ssh -V"
  "tree --version"
  "unzip -v"
  "vim --version"
  "yarn --version"
  "zip --version"
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
