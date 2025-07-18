FROM php:8.4-cli-bookworm AS builder

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
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
# hadolint ignore=DL3003
RUN version=43 && \
    curl -L -o "/tmp/kcov.tar.gz" "https://github.com/SimonKagstrom/kcov/archive/refs/tags/v${version}.tar.gz" && \
    mkdir -p /tmp/kcov && \
    tar -xz -C /tmp/kcov -f /tmp/kcov.tar.gz --strip 1 && \
    cd /tmp/kcov && \
    mkdir build && \
    cd build && \
    cmake -G 'Ninja' .. && \
    cmake --build . && \
    cmake --build . --target install

FROM php:8.4-cli-bookworm

# Upgrade all installed packages and clean up.
# hadolint ignore=DL3005
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.authors="Alex Skrypnyk <alex@drevops.com>" \
      org.opencontainers.image.description="CI runner with PHP, Node.js, Docker, and development tools" \
      org.opencontainers.image.source="https://github.com/drevops/ci-runner" \
      org.opencontainers.image.vendor="DrevOps" \
      maintainer="Alex Skrypnyk <alex@drevops.com>"

# Ensure temporary files are not retained in the image.
VOLUME /tmp

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
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
      zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p "$HOME/.gnupg"

# Install shellcheck
# @see https://github.com/koalaman/shellcheck/releases
# renovate: datasource=github-releases depName=koalaman/shellcheck extractVersion=^v(?<version>.*)$
RUN version=0.10.0 && \
    curl -L -o "/tmp/shellcheck-v${version}.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.linux.x86_64.tar.xz" && \
    tar --xz -xvf "/tmp/shellcheck-v${version}.tar.xz" && \
    mv "shellcheck-v${version}/shellcheck" /usr/local/bin/ && \
    rm -rf "/tmp/shellcheck-v${version}.tar.xz" "shellcheck-v${version}" && \
    shellcheck --version

# Install shfmt
# @see https://github.com/mvdan/sh/releases
# renovate: datasource=github-releases depName=mvdan/sh extractVersion=^v(?<version>.*)$
# hadolint ignore=SC2015
RUN version=3.12.0 && \
    curl -L -o "/tmp/shfmt-v${version}" "https://github.com/mvdan/sh/releases/download/v${version}/shfmt_v${version}_linux_amd64" && \
    mv "/tmp/shfmt-v${version}" /usr/local/bin/shfmt && \
    chmod +x /usr/local/bin/shfmt && \
    shfmt --version || true

# Install Docker and Docker Compose V2 (docker compose).
# @see https://download.docker.com/linux/static/stable/x86_64
# @see https://github.com/docker/compose/releases
# renovate: datasource=github-releases depName=docker/compose extractVersion=^v(?<version>.*)$
RUN version=28.1.1 && \
    compose_version=2.38.2 && \
    curl -L -o "/tmp/docker-${version}.tgz" "https://download.docker.com/linux/static/stable/x86_64/docker-${version}.tgz" && \
    tar -xz -C /tmp -f "/tmp/docker-${version}.tgz" && \
    mv /tmp/docker/* /usr/bin && \
    rm -rf /tmp/docker* && \
    docker --version && \
    mkdir -p "$HOME/.docker/cli-plugins" && \
    curl -sSL "https://github.com/docker/compose/releases/download/v${compose_version}/docker-compose-$(uname -s)-$(uname -m)" -o "$HOME/.docker/cli-plugins/docker-compose" && \
    chmod +x "$HOME/.docker/cli-plugins/docker-compose" && \
    docker compose version

# Install Docker buildx (docker buildx).
# @see https://github.com/docker/buildx/releases
# renovate: datasource=github-releases depName=docker/buildx extractVersion=^v(?<version>.*)$
RUN version=0.25.0 && \
    curl --silent -L "https://github.com/docker/buildx/releases/download/v${version}/buildx-v${version}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx && \
    chmod a+x "$HOME/.docker/cli-plugins/docker-buildx" && \
    docker buildx version

# Install composer.
# @see https://getcomposer.org/download
# renovate: datasource=github-releases depName=composer/composer extractVersion=^(?<version>.*)$
ENV COMPOSER_ALLOW_SUPERUSER=1
# hadolint ignore=DL4006
RUN version=2.8.8 && \
    sha=dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6 && \
    curl -L -o "/usr/local/bin/composer" "https://getcomposer.org/download/${version}/composer.phar" && \
    echo "${sha} /usr/local/bin/composer" | sha256sum && \
    chmod +x /usr/local/bin/composer && \
    composer --version && \
    composer clear-cache
ENV PATH=/root/.composer/vendor/bin:$PATH

# Install NodeJS.
# @see https://nodejs.org/download/release/
# renovate: datasource=node versioning=node extractVersion=^v(?<version>.*)$
RUN version=v23.11.0 && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then arch="x64"; elif [ "${arch}" = "aarch64" ]; then arch="arm64"; fi && \
    curl -L -o "/tmp/node-${version}-linux-${arch}.tar.xz" "https://nodejs.org/download/release/${version}/node-${version}-linux-${arch}.tar.xz" && \
    tar -xJ -C /usr/local --strip-components=1 -f "/tmp/node-${version}-linux-${arch}.tar.xz" && \
    rm -rf "/tmp/node-${version}-linux-${arch}.tar.xz" && \
    node --version && \
    npm --version

# Install Yarn.
# renovate: datasource=npm depName=yarn extractVersion=^(?<version>.*)$
RUN version=1.22.22 && \
    npm install --global "yarn@${version}" --no-audit --no-fund && \
    npm cache clean --force && \
    yarn --version

# Install Goss.
# @see https://github.com/goss-org/goss/releases
# renovate: datasource=github-releases depName=aelsabbahy/goss extractVersion=^(?<version>.*)$
ENV GOSS_FILES_STRATEGY=cp
# hadolint ignore=DL4006,SC2034
RUN GOSS_VER=v0.4.9 && \
    curl -fsSL https://goss.rocks/install | sh && \
    goss --version

# Install Bats.
# @see https://github.com/bats-core/bats-core/releases
# renovate: datasource=github-releases depName=bats-core/bats-core extractVersion=^v(?<version>.*)$
# hadolint ignore=DL3003
RUN version=1.12.0 && \
    curl -L -o "/tmp/bats.tar.gz" "https://github.com/bats-core/bats-core/archive/v${version}.tar.gz" && \
    mkdir -p /tmp/bats && tar -xz -C /tmp/bats -f /tmp/bats.tar.gz --strip 1 && \
    cd /tmp/bats && \
    ./install.sh /usr/local && \
    rm -rf /tmp/bats* && \
    bats -v

# Install Ahoy.
# @see https://github.com/ahoy-cli/ahoy/releases
# renovate: datasource=github-releases depName=ahoy-cli/ahoy extractVersion=^v(?<version>.*)$
RUN version=2.4.0 && \
    set -x && curl -L -o "/usr/local/bin/ahoy" "https://github.com/ahoy-cli/ahoy/releases/download/v${version}/ahoy-bin-$(uname -s)-amd64" && \
    chmod +x /usr/local/bin/ahoy && \
    ahoy --version

# Install Task.
# @see https://github.com/go-task/task/releases
# renovate: datasource=github-releases depName=go-task/task extractVersion=^v(?<version>.*)$
RUN version=3.44.0 && \
    sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -b /usr/local/bin "v$version"

# Install Codecov reporter.
# @see https://github.com/codecov/uploader/releases
# renovate: datasource=github-releases depName=codecov/uploader extractVersion=^v(?<version>.*)$
RUN version=0.8.0 && \
    curl -L -o "/usr/local/bin/codecov" "https://github.com/codecov/uploader/releases/download/v${version}/codecov-linux" && \
    chmod +x /usr/local/bin/codecov && \
    codecov --version

# Install PCOV
# @see https://pecl.php.net/package/pcov
# renovate: datasource=pecl depName=pcov extractVersion=^(?<version>.*)$
RUN version=1.0.12 && \
    pecl install "pcov-${version}" && \
    docker-php-ext-enable pcov && \
    rm -rf /tmp/pear && \
    php -m

COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov

# Install a stub for pygmy.
# Some frameworks may require presence of tools that are not required in CI container.
RUN ln -s /usr/bin/true /usr/local/bin/pygmy && \
    ln -s /usr/bin/true /usr/local/bin/sendmail
