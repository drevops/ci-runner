<p align="center">
  <a href="" rel="noopener">
  <img width=200px height=200px src="https://placehold.jp/000000/ffffff/200x200.png?text=CI+runner&css=%7B%22border-radius%22%3A%22%20100px%22%7D" alt="CI runner"></a>
</p>

<h1 align="center">Docker image for CI runner</h1>

<div align="center">

[![Test](https://github.com/drevops/ci-runner/actions/workflows/test.yml/badge.svg)](https://github.com/drevops/ci-runner/actions/workflows/test.yml)
[![GitHub Issues](https://img.shields.io/github/issues/DrevOps/ci-runner.svg)](https://github.com/DrevOps/ci-runner/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/DrevOps/ci-runner.svg)](https://github.com/DrevOps/ci-runner/pulls)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/drevops/ci-runner)
![LICENSE](https://img.shields.io/github/license/drevops/ci-runner)
![Renovate](https://img.shields.io/badge/renovate-enabled-green?logo=renovatebot)

[![Docker Pulls](https://img.shields.io/docker/pulls/drevops/ci-runner?logo=docker)](https://hub.docker.com/r/drevops/ci-runner)
![amd64](https://img.shields.io/badge/arch-linux%2Famd64-brightgreen)

</div>

---

Based on Debian `php:8.4-cli-bookworm`.

## Included packages

```
aspell=3.1.20
bats=1.12.0
composer=8.4.13
codecov=0.8.0
curl=7.88.1
docker=28.5.0
docker_buildx=0.29.0
docker_compose=2.39.4
git=2.39.5
gpg=2.2.40
jq=1.6
kcov=43
lsof=11.3.0
lynx=2.9.0
node=23.11.1
npm=10.9.2
npx=10.9.2
php=8.4.13
rsync=3.2.7
shellcheck=0.11.0
shfmt=3.12.0
ssh=9.2
tree=2.1.0
unzip=1.0.8
vim=9.0
yarn=1.22.22
zip=1.0.8
```
## Usage

Make sure to **always** pin the version of this image to the tag:

```
drevops/ci-runner:25.1.0
```

For testing purposes, you can use the `canary` tag:

```
drevops/ci-runner:canary
```

When using in GitHub Actions, make sure to add a fix for the overwritten `$HOME`:

```
name: Test

jobs:
  test:
    runs-on: ubuntu-latest

    container:
      image: drevops/ci-runner:25.8.0

    steps:
      - name: Preserve $HOME set in the container
        run: echo HOME=/root >> "$GITHUB_ENV" # https://github.com/actions/runner/issues/863

      - name: Check out the repo
        uses: actions/checkout@v5
```

## Testing

The image includes [Goss](https://github.com/aelsabbahy/goss) for environment testing. To run tests locally using dgoss:

```bash
# Build the image
docker build -t drevops/ci-runner:test-ci .

# Run tests
dgoss run -i drevops/ci-runner:test-ci
```

**Note for ARM64 systems (Apple Silicon):** You'll need to install the correct goss binaries:

```bash
# Create bin directory
mkdir -p ~/bin

# Download macOS ARM64 goss binary for local use
curl -L "https://github.com/aelsabbahy/goss/releases/latest/download/goss-darwin-arm64" -o ~/bin/goss
chmod +x ~/bin/goss

# Download Linux AMD64 goss binary for container testing
curl -L "https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64" -o ~/bin/goss-linux-amd64
chmod +x ~/bin/goss-linux-amd64

# Download dgoss wrapper
curl -L "https://github.com/aelsabbahy/goss/releases/latest/download/dgoss" -o ~/bin/dgoss
chmod +x ~/bin/dgoss

# Run tests with correct binary
export GOSS_PATH=~/bin/goss-linux-amd64
~/bin/dgoss run -i drevops/ci-runner:test-ci
```

## Maintenance and releasing

### Versioning

This project uses _Year-Month-Patch_ versioning:

- `YY`: Last two digits of the year, e.g., `23` for 2023.
- `m`: Numeric month, e.g., April is `4`.
- `patch`: Patch number for the month, starting at `0`.

Example: `23.4.2` indicates the third patch in April 2023.

### Releasing

Releases are scheduled to occur at a minimum of once per month.

This image is built by DockerHub via an automated build and tagged as follows:

 - `YY.m.patch` tag - when release tag is published on GitHub.
 - `latest` - when release tag is published on GitHub.
 - `canary` - on every push to `main` branch

### Dependencies update

Renovate bot is used to update dependencies. It creates a PR with the changes
and automatically merges it if CI passes. These changes are then released as
a `canary` version.

---
_This repository was created using the [Scaffold](https://getscaffold.dev/) project template_
