FROM php:8.4-cli-bookworm AS builder

# hadolint ignore=DL3008
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
      binutils-dev \
      build-essential \
      cmake \
      curl \
      git \
      libcurl4-openssl-dev \
      libdw-dev \
      libiberty-dev \
      libssl-dev \
      ninja-build \
      python3 \
      zlib1g-dev

# Install kcov.
# @see https://github.com/SimonKagstrom/kcov/releases
# renovate: datasource=github-releases depName=SimonKagstrom/kcov extractVersion=^v(?<version>.*)$
ENV KCOV_VERSION=43
# hadolint ignore=DL3003
RUN curl -L -o "/tmp/kcov.tar.gz" "https://github.com/SimonKagstrom/kcov/archive/refs/tags/v${KCOV_VERSION}.tar.gz" \
    && mkdir -p /tmp/kcov \
    && tar -xz -C /tmp/kcov -f /tmp/kcov.tar.gz --strip 1 \
    && cd /tmp/kcov \
    && mkdir build \
    && cd build \
    && cmake -G 'Ninja' .. \
    && cmake --build . \
    && cmake --build . --target install

FROM php:8.4-cli-bookworm

# Upgrade all installed packages and clean up.
# hadolint ignore=DL3005
RUN apt-get update -qq \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.authors="Alex Skrypnyk <alex@drevops.com>" maintainer="Alex Skrypnyk <alex@drevops.com>"

# Ensure temporary files are not retained in the image.
VOLUME /tmp

# hadolint ignore=DL3008
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
      aspell-en \
      binutils \
      curl \
      git \
      gnupg \
      jq \
      libcurl4 \
      libdw1 \
      lsof \
      lynx \
      openssh-client \
      procps \
      rsync \
      tree \
      unzip \
      vim \
      zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p "$HOME/.gnupg"

# Install shellcheck
# @see https://github.com/koalaman/shellcheck/releases
# renovate: datasource=github-releases depName=koalaman/shellcheck extractVersion=^v(?<version>.*)$
ENV SHELLCHECK_VERSION=0.10.0
RUN curl -L -o "/tmp/shellcheck-v${SHELLCHECK_VERSION}.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \
  && tar --xz -xvf "/tmp/shellcheck-v${SHELLCHECK_VERSION}.tar.xz" \
  && mv "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" /usr/bin/ \
  && shellcheck --version

# Install shfmt
# @see https://github.com/mvdan/sh/releases
# renovate: datasource=github-releases depName=mvdan/sh extractVersion=^v(?<version>.*)$
ENV SH_VERSION=3.12.0
# hadolint ignore=SC2015
RUN curl -L -o "/tmp/shfmt-v${SH_VERSION}" "https://github.com/mvdan/sh/releases/download/v${SH_VERSION}/shfmt_v${SH_VERSION}_linux_386" \
  && mv "/tmp/shfmt-v${SH_VERSION}" /usr/bin/shfmt \
  && chmod +x /usr/bin/shfmt \
  && shfmt --version || true

# Install Docker and Docker Compose V2 (docker compose).
# @see https://download.docker.com/linux/static/stable/x86_64
ENV DOCKER_VERSION=28.1.1
# @see https://github.com/docker/compose/releases
# renovate: datasource=github-releases depName=docker/compose extractVersion=^v(?<version>.*)$
ENV DOCKER_COMPOSE_VERSION=2.38.2
RUN curl -L -o "/tmp/docker-${DOCKER_VERSION}.tgz" "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
    && tar -xz -C /tmp -f "/tmp/docker-${DOCKER_VERSION}.tgz" \
    && mv /tmp/docker/* /usr/bin \
    && docker --version \
    && mkdir -p "$HOME/.docker/cli-plugins" \
    && curl -sSL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o "$HOME/.docker/cli-plugins/docker-compose" \
    && chmod +x "$HOME/.docker/cli-plugins/docker-compose" \
    && docker compose version

# Install Docker buildx (docker buildx).
# @see https://github.com/docker/buildx/releases
# renovate: datasource=github-releases depName=docker/buildx extractVersion=^v(?<version>.*)$
ENV BUILDX_VERSION=0.25.0
RUN curl --silent -L "https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx \
    && chmod a+x "$HOME/.docker/cli-plugins/docker-buildx" \
    && docker buildx version

# Install composer.
# @see https://getcomposer.org/download
ENV COMPOSER_VERSION=2.8.8
ENV COMPOSER_SHA=dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6
ENV COMPOSER_ALLOW_SUPERUSER=1
# hadolint ignore=DL4006
RUN curl -L -o "/usr/local/bin/composer" "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" \
    && echo "${COMPOSER_SHA} /usr/local/bin/composer" | sha256sum \
    && chmod +x /usr/local/bin/composer \
    && composer --version \
    && composer clear-cache
ENV PATH=/root/.composer/vendor/bin:$PATH

# Install NVM and NodeJS.
# @see https://github.com/nvm-sh/nvm/releases
ENV NVM_VERSION=v0.40.3
ENV NVM_DIR=/root/.nvm
# hadolint ignore=DL4006,SC1091
RUN mkdir -p "${NVM_DIR}" \
  && curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash \
  && . "$HOME/.nvm/nvm.sh" \
  && nvm --version

ENV SHIPPABLE_NODE_VERSION=v23.11.0
# hadolint ignore=SC1091
RUN . "$HOME/.nvm/nvm.sh" \
	&& nvm install "${SHIPPABLE_NODE_VERSION}" \
	&& nvm alias default "${SHIPPABLE_NODE_VERSION}" \
	&& nvm use default \
	&& npm --version
ENV PATH=${NVM_DIR}/versions/node/${SHIPPABLE_NODE_VERSION}/bin:$PATH

# Install Yarn.
# renovate: datasource=npm depName=yarn extractVersion=^(?<version>.*)$
ENV YARN_VERSION=1.22.22
RUN npm install --global "yarn@${YARN_VERSION}" \
  && yarn --version

# Install Goss.
# @see https://github.com/goss-org/goss/releases
# renovate: datasource=github-releases depName=aelsabbahy/goss extractVersion=^(?<version>.*)$
ENV GOSS_VER=v0.4.9
ENV GOSS_FILES_STRATEGY=cp
# hadolint ignore=DL4006
RUN curl -fsSL https://goss.rocks/install | sh \
  && goss --version

# Install Bats.
# @see https://github.com/bats-core/bats-core/releases
# renovate: datasource=github-releases depName=bats-core/bats-core extractVersion=^v(?<version>.*)$
ENV BATS_VERSION=1.12.0
# hadolint ignore=DL3003
RUN curl -L -o "/tmp/bats.tar.gz" "https://github.com/bats-core/bats-core/archive/v${BATS_VERSION}.tar.gz" \
    && mkdir -p /tmp/bats && tar -xz -C /tmp/bats -f /tmp/bats.tar.gz --strip 1 \
    && cd /tmp/bats \
    && ./install.sh /usr/local \
    && bats -v

# Install Ahoy.
# @see https://github.com/ahoy-cli/ahoy/releases
# renovate: datasource=github-releases depName=ahoy-cli/ahoy extractVersion=^v(?<version>.*)$
ENV AHOY_VERSION=2.4.0
RUN set -x && curl -L -o "/usr/local/bin/ahoy" "https://github.com/ahoy-cli/ahoy/releases/download/v${AHOY_VERSION}/ahoy-bin-$(uname -s)-amd64" \
  && chmod +x /usr/local/bin/ahoy \
  && ahoy --version

# Install Task.
# @see https://github.com/go-task/task/releases
# renovate: datasource=github-releases depName=go-task/task extractVersion=^v(?<version>.*)$
ENV TASK_VERSION=3.44.0
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -b /usr/local/bin "v$TASK_VERSION"

# Install Codecov reporter.
# @see https://github.com/codecov/uploader/releases
# renovate: datasource=github-releases depName=codecov/uploader extractVersion=^v(?<version>.*)$
ENV CODECOV_VERSION=0.8.0
RUN curl -L -o "/usr/local/bin/codecov" "https://github.com/codecov/uploader/releases/download/v${CODECOV_VERSION}/codecov-linux" \
  && chmod +x /usr/local/bin/codecov \
  && codecov --version

# Install PCOV
# @see https://pecl.php.net/package/pcov
ENV CODECOV_VERSION=1.0.12
RUN pecl install "pcov-${CODECOV_VERSION}" && docker-php-ext-enable pcov && php -m

# Install a stub for pygmy.
# Some frameworks may require presence of tools that are not required in CI container.
RUN ln -s /usr/bin/true /usr/local/bin/pygmy \
 && ln -s /usr/bin/true /usr/local/bin/sendmail

COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov
