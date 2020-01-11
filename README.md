# CI Builder
Docker image for CI Builder container

[![CircleCI](https://circleci.com/gh/drevops/ci-builder.svg?style=svg)](https://circleci.com/gh/drevops/ci-builder)
[![DockerHub](https://img.shields.io/docker/build/drevops/ci-builder.svg)](https://hub.docker.com/r/drevops/ci-builder/)
[![DockerHub](https://img.shields.io/docker/automated/drevops/ci-builder.svg)](https://hub.docker.com/r/drevops/ci-builder/)

It contains several tools required to run docker-based builds:
- git
- lsof
- lynx
- curl
- vim
- zip/unzip
- Docker
- docker-compose
- php
- Composer + parallel download plugin (hirak/prestissimo)
- NVM and NodeJS
- Goss - environment testing
- Ahoy - workflow helper
- Aspell - English language spellcheker
- Shellcheck - a shell script static analysis tool
- Bats - Bash Automated Testing System (2018)
