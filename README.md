# CI Builder
Docker image used in CI as a builder container

[![CircleCI](https://circleci.com/gh/drevops/ci-builder.svg?style=shield)](https://circleci.com/gh/drevops/ci-builder)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/drevops/ci-builder)
[![DockerHub](https://img.shields.io/docker/pulls/drevops/ci-builder.svg)](https://hub.docker.com/r/drevops/ci-builder/)
![LICENSE](https://img.shields.io/github/license/drevops/ci-builder)

It contains several tools required to run Docker-based builds:
- git
- php
- lsof
- lynx
- curl
- vim
- zip/unzip
- [Docker](https://github.com/docker/docker-ce) and [Docker Compose](https://github.com/docker/compose)
- [Composer](https://github.com/composer/composer)
- [NVM](https://github.com/nvm-sh/nvm) and [NodeJS](https://github.com/nodejs/node)
- [Goss](https://github.com/aelsabbahy/goss) - environment testing
- [Ahoy](https://github.com/ahoy-cli/ahoy) - workflow helper
- [Task](https://github.com/go-task/task) - workflow helper
- [Aspell](https://github.com/GNUAspell/aspell) - English language spellcheker
- [Shellcheck](https://github.com/koalaman/shellcheck) - a shell script static analysis tool
- [shfmt](https://github.com/mvdan/sh) - a shell parser, formatter, and interpreter.
- [Bats](https://github.com/bats-core/bats-core) - Bash Automated Testing System (2018)


## Maintenance and releasing

This image is built by DockerHub via an automated build when release tag is published on GitHub.

Pre-release version is tested using `preview/x.y.z` branch. Pushes to this branches are built in DockerHub.
