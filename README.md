# CI Builder
Docker image used in CI as a builder container

[![CircleCI](https://circleci.com/gh/drevops/ci-builder.svg?style=shield)](https://circleci.com/gh/drevops/ci-builder)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/drevops/ci-builder)
[![DockerHub](https://img.shields.io/docker/pulls/drevops/ci-builder.svg)](https://hub.docker.com/r/drevops/ci-builder/)
![LICENSE](https://img.shields.io/github/license/drevops/ci-builder)

It contains several tools required to run Docker-based builds (in alphabetical order):
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
- zip/unzip

## Usage

Make sure to **always** pin the version of this image to the tag:

```
drevops/ci-builder:23.8.1
```

For testing purposes, you can use the `canary` tag:

```
drevops/ci-builder:canary
```

## Maintenance and releasing

### Versioning

This project uses _Year-Month-Patch_ versioning:

- `YY`: Last two digits of the year, e.g., `23` for 2023.
- `m`: Numeric month, e.g., April is `4`.
- `patch`: Patch number for the month, starting at `0`.

Example: `23.4.2` indicates the third patch in April 2023.

### Releasing

This image is built by DockerHub via an automated build and tagged as follows:

 - `YY.m.patch` tag - when release tag is published on GitHub.
 - `latest` - when release tag is published on GitHub.
 - `canary` - on every push to `main` branch
