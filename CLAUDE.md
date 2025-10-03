# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker image project for a CI runner based on Debian `php:8.4-cli-bookworm`. The image includes a comprehensive suite of development tools for CI/CD pipelines, including PHP, Node.js, Docker, Composer, and various testing utilities.

## Architecture

### Docker Image Structure
- **Multi-stage build**: Uses a `builder` stage to compile kcov from source, then copies binaries to the final image
- **Base image**: `php:8.4-cli-bookworm`
- **Plugin location**: Docker CLI plugins (compose, buildx) are installed in `/usr/local/lib/docker/cli-plugins/`
- **Mock tools**: Some tools like `pygmy` and `sendmail` are symlinked to `/usr/bin/true` for framework compatibility

### Dependency Management
- **Renovate**: Automated dependency updates via renovate.json
- **Version annotations**: Each tool in Dockerfile has renovate comments with datasource and version extraction patterns
- Example: `# renovate: datasource=github-releases depName=SimonKagstrom/kcov extractVersion=^(?<version>.*)$`

### Testing Infrastructure
- **Goss**: Environment testing using goss.yaml (defines expected commands, paths, and behaviors)
- **dgoss**: Wrapper for running goss tests in Docker containers
- **Hadolint**: Dockerfile linting

### Versioning
Uses **Year-Month-Patch** (YY.m.patch) versioning:
- `YY`: Last two digits of the year (e.g., 25 for 2025)
- `m`: Numeric month (e.g., 4 for April)
- `patch`: Patch number for the month, starting at 0

## Common Commands

### Building
```bash
docker build -t drevops/ci-runner:test-ci .
```

### Testing Locally

#### Standard testing:
```bash
# Install goss (if not already installed)
curl -fsSL https://goss.rocks/install | sh

# Build image
docker build -t drevops/ci-runner:test-ci .

# Run tests
dgoss run -i drevops/ci-runner:test-ci
```

#### ARM64/Apple Silicon systems:
```bash
# Create bin directory
mkdir -p ~/bin

# Download macOS ARM64 goss binary
curl -L "https://github.com/aelsabbahy/goss/releases/latest/download/goss-darwin-arm64" -o ~/bin/goss
chmod +x ~/bin/goss

# Download Linux AMD64 goss binary for container testing
curl -L "https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64" -o ~/bin/goss-linux-amd64
chmod +x ~/bin/goss-linux-amd64

# Download dgoss wrapper
curl -L "https://github.com/aelsabbahy/goss/releases/latest/download/dgoss" -o ~/bin/dgoss
chmod +x ~/bin/dgoss

# Run tests
export GOSS_PATH=~/bin/goss-linux-amd64
~/bin/dgoss run -i drevops/ci-runner:test-ci
```

### Linting
```bash
# Lint Dockerfile
docker run --rm -i hadolint/hadolint < Dockerfile
```

### Version Information
```bash
# Extract package versions (outputs markdown format)
./versions.js "drevops/ci-runner:test-ci"

# Update README.md directly
./versions.js "drevops/ci-runner:test-ci" --update-readme README.md

# Update with custom section title
./versions.js "drevops/ci-runner:test-ci" --update-readme README.md --section "## Packages"
```

Tool configurations are defined in `versions-config.json`.

## Updating Dependencies

Dependencies are managed via Renovate bot with custom regex managers for Dockerfile annotations. To add a new tool:

1. Add installation RUN command in Dockerfile
2. Add renovate comment above it with datasource and depName
3. Add version check to goss.yaml
4. Add tool entry to `versions-config.json` with name, URL, version command, and extraction regex

Example Dockerfile entry:
```dockerfile
# Install tool
# @see https://github.com/org/tool/releases
# renovate: datasource=github-releases depName=org/tool extractVersion=^(?<version>.*)$
RUN version=1.2.3 && \
    curl -L -o "/tmp/tool-v${version}" "https://github.com/org/tool/releases/download/v${version}/tool_linux_amd64" && \
    mv "/tmp/tool-v${version}" /usr/local/bin/tool && \
    chmod +x /usr/local/bin/tool && \
    tool --version
```

Example versions-config.json entry:
```json
{
  "name": "Tool Name",
  "url": "https://tool-homepage.com",
  "cmd": "tool --version",
  "regex": "version[:\\s]+v?(\\d+\\.\\d+\\.\\d+)"
}
```

Note: Regex is stored as a string and will be compiled with 'im' flags (case-insensitive, multiline).

## GitHub Actions

### Test Workflow (`.github/workflows/test.yml`)

Runs on pull requests and pushes to main:
1. Dockerfile linting with hadolint
2. Image build
3. Goss tests via dgoss
4. Display package versions via `versions.js`

### Update README Workflow (`.github/workflows/update-readme.yml`)

Runs automatically after merges to main, or can be triggered manually:
1. Builds the Docker image
2. Runs `versions.js` with `--update-readme` flag to update README.md directly
3. Creates a pull request with the changes (labeled "automerge") if README changed
4. PR triggers test workflow, and auto-merges once tests pass

The `versions.js` script:
- Reads tool configurations from `versions-config.json`
- Extracts versions from the Docker image
- Updates the "## Included packages" section in README.md
- Returns exit code 0 if no changes, 1 if changes were made

**Manual trigger**: The workflow can be run manually from the Actions tab in GitHub.

**Note**: Creates a PR instead of pushing directly to main to respect branch protection rules. The "automerge" label ensures the PR merges automatically once tests pass.

**Important**: To trigger the test workflow on the created PR, you need to set up a Personal Access Token (PAT):
1. Create a PAT with `repo` scope at https://github.com/settings/tokens
2. Add it as a repository secret named `PAT`
3. The workflow will use this token to create PRs that trigger other workflows
4. Without the PAT, it falls back to `GITHUB_TOKEN` which won't trigger the test workflow

**Important**: When using this image in GitHub Actions, include the `$HOME` fix:
```yaml
container:
  image: drevops/ci-runner:25.8.0

steps:
  - name: Preserve $HOME set in the container
    run: echo HOME=/root >> "$GITHUB_ENV"  # https://github.com/actions/runner/issues/863
```

## Release Process

1. Releases occur monthly (minimum)
2. Tag format: `YY.m.patch` (e.g., `25.4.0`)
3. DockerHub builds automatically tag:
   - `YY.m.patch` - on release tag
   - `latest` - on release tag
   - `canary` - on every push to `main` branch

## Dockerfile Formatting Rules

Multi-line RUN instructions must follow this format:
- Use `&&` at the end of each line (not at the beginning)
- First command begins on the same line as RUN
- Subsequent commands start on new lines, aligned with first command
- End each line (except last) with backslash `\`

Example:
```dockerfile
RUN apt-get update -qq && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```
