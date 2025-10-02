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

# Extract version from command output using common patterns
extract_version() {
  local output="$1"
  local version

  # Try: "version X.Y.Z" or "Version X.Y.Z"
  version=$(echo "${output}" | grep -iEo 'version[: ]+v?[0-9]+(\.[0-9]+)*' | head -1 | sed -E 's/version[: ]+v?//i' | tr -d ' ')
  [ -n "${version}" ] && echo "${version}" && return

  # Try: "vX.Y.Z" at start of line
  version=$(echo "${output}" | grep -Eo '^v[0-9]+(\.[0-9]+)*' | head -1 | sed 's/^v//')
  [ -n "${version}" ] && echo "${version}" && return

  # Try: any version number (X.Y.Z, X.Y, or X)
  echo "${output}" | grep -Eo '[0-9]+(\.[0-9]+)*' | head -1
}

for command in "${commands[@]}"; do
  tool_name="${command%% *}"

  # shellcheck disable=SC2086
  output=$(docker run --rm "${DOCKER_IMAGE}" ${command} 2>&1)
  version=$(extract_version "${output}")

  # Special naming for docker subcommands
  if [[ "${command}" == "docker buildx"* ]]; then
    echo "docker_buildx=${version:-unknown}"
  elif [[ "${command}" == "docker compose"* ]]; then
    echo "docker_compose=${version:-unknown}"
  else
    echo "${tool_name}=${version:-unknown}"
  fi
done
