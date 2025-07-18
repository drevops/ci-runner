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

## Included

- [Ahoy](https://github.com/ahoy-cli/ahoy) - workflow helper
- [Aspell](https://github.com/GNUAspell/aspell) - English language spellcheker
- [Bats](https://github.com/bats-core/bats-core) - Bash Automated Testing System (2018)
- [Composer](https://github.com/composer/composer)
- curl
- [Docker](https://github.com/docker/docker-ce) and [Docker Compose](https://github.com/docker/compose)
- git
- [Goss](https://github.com/aelsabbahy/goss) - environment testing
- [kcov](https://github.com/SimonKagstrom/kcov) - code coverage tester for compiled languages, Python and Bash
- lsof
- Lynx
- [NVM](https://github.com/nvm-sh/nvm) and [NodeJS](https://github.com/nodejs/node)
- PHP
- [Shellcheck](https://github.com/koalaman/shellcheck) - a shell script static analysis tool
- [shfmt](https://github.com/mvdan/sh) - a shell parser, formatter, and interpreter.
- [Task](https://github.com/go-task/task) - workflow helper
- vim
- [yarn](https://yarnpkg.com/)
- zip/unzip

## Usage

Make sure to **always** pin the version of this image to the tag:

```
drevops/ci-runner:25.1.0
```

For testing purposes, you can use the `canary` tag:

```
drevops/ci-runner:canary
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
