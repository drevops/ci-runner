# CI Builder
Docker image for CI Builder container

[![CircleCI](https://circleci.com/gh/drevops/ci-builder.svg?style=svg)](https://circleci.com/gh/drevops/ci-builder)
[![DockerHub](https://img.shields.io/docker/build/drevops/ci-builder.svg)](https://hub.docker.com/r/drevops/ci-builder/)
[![DockerHub](https://img.shields.io/docker/automated/drevops/ci-builder.svg)](https://hub.docker.com/r/drevops/ci-builder/)

It contains several tools required to run Docker-based builds:
- git
- php
- lsof
- lynx
- curl
- vim
- zip/unzip
- [Docker](https://github.com/docker/docker-ce) and [Docker Compose] (https://github.com/docker/compose)
- [Composer](https://github.com/composer/composer) + parallel download plugin ([hirak/prestissimo](https://github.com/hirak/prestissimo))
- [NVM](https://github.com/nvm-sh/nvm) and [NodeJS](https://github.com/nodejs/node)
- [Goss](https://github.com/aelsabbahy/goss) - environment testing
- [Ahoy](https://github.com/ahoy-cli/ahoy) - workflow helper
- [Aspell](https://github.com/GNUAspell/aspell) - English language spellcheker
- [Shellcheck](https://github.com/koalaman/shellcheck) - a shell script static analysis tool
- [Bats](https://github.com/bats-core/bats-core) - Bash Automated Testing System (2018)
