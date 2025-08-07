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
# renovate: datasource=github-releases depName=SimonKagstrom/kcov extractVersion=^(?<version>.*)$
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

LABEL org.opencontainers.image.authors="Alex Skrypnyk <alex@drevops.com>" \
      org.opencontainers.image.description="CI runner with PHP, Node.js, Docker, and development tools" \
      org.opencontainers.image.source="https://github.com/drevops/ci-runner" \
      org.opencontainers.image.vendor="DrevOps" \
      maintainer="Alex Skrypnyk <alex@drevops.com>"

# Ensure temporary files are not retained in the image.
VOLUME /tmp

COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov

# Some frameworks may require presence of tools that are not required in CI container.
RUN ln -s /usr/bin/true /usr/local/bin/pygmy && \
    ln -s /usr/bin/true /usr/local/bin/sendmail

# Upgrade all installed packages and clean up.
# hadolint ignore=DL3005
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
# renovate: datasource=github-releases depName=koalaman/shellcheck extractVersion=^(?<version>.*)$
RUN version=0.11.0 && \
    curl -L -o "/tmp/shellcheck-v${version}.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.linux.x86_64.tar.xz" && \
    tar --xz -xvf "/tmp/shellcheck-v${version}.tar.xz" && \
    mv "shellcheck-v${version}/shellcheck" /usr/local/bin/ && \
    rm -rf "/tmp/shellcheck-v${version}.tar.xz" "shellcheck-v${version}" && \
    shellcheck --version

# Install shfmt
# @see https://github.com/mvdan/sh/releases
# renovate: datasource=github-releases depName=mvdan/sh extractVersion=^(?<version>.*)$
# hadolint ignore=SC2015
RUN version=3.12.0 && \
    curl -L -o "/tmp/shfmt-v${version}" "https://github.com/mvdan/sh/releases/download/v${version}/shfmt_v${version}_linux_amd64" && \
    mv "/tmp/shfmt-v${version}" /usr/local/bin/shfmt && \
    chmod +x /usr/local/bin/shfmt && \
    shfmt --version || true

# Install PCOV
# @see https://pecl.php.net/package/pcov
# renovate: datasource=github-releases depName=krakjoe/pcov extractVersion=^(?<version>.*)$
RUN version=1.0.12 && \
    pecl install "pcov-${version}" && \
    docker-php-ext-enable pcov && \
    rm -rf /tmp/pear && \
    php -m

# Install Codecov reporter.
# @see https://github.com/codecov/uploader/releases
# renovate: datasource=github-releases depName=codecov/uploader extractVersion=^(?<version>.*)$
RUN version=0.8.0 && \
    curl -L -o "/usr/local/bin/codecov" "https://github.com/codecov/uploader/releases/download/v${version}/codecov-linux" && \
    chmod +x /usr/local/bin/codecov && \
    codecov --version

# Install Bats.
# @see https://github.com/bats-core/bats-core/releases
# renovate: datasource=github-releases depName=bats-core/bats-core extractVersion=^(?<version>.*)$
# hadolint ignore=DL3003
RUN version=1.12.0 && \
    curl -L -o "/tmp/bats.tar.gz" "https://github.com/bats-core/bats-core/archive/v${version}.tar.gz" && \
    mkdir -p /tmp/bats && tar -xz -C /tmp/bats -f /tmp/bats.tar.gz --strip 1 && \
    cd /tmp/bats && \
    ./install.sh /usr/local && \
    rm -rf /tmp/bats* && \
    bats -v

# Install Docker.
# @see https://download.docker.com/linux/static/stable/x86_64
# renovate: datasource=github-releases depName=moby/moby extractVersion=^(?<version>.*)$
RUN version=28.3.2 && \
    curl -L -o "/tmp/docker-${version}.tgz" "https://download.docker.com/linux/static/stable/x86_64/docker-${version}.tgz" && \
    tar -xz -C /tmp -f "/tmp/docker-${version}.tgz" && \
    mv /tmp/docker/* /usr/bin && \
    rm -rf /tmp/docker* && \
    docker --version

# Install Docker Compose V2 (docker compose).
# @see https://github.com/docker/compose/releases
# renovate: datasource=github-releases depName=docker/compose extractVersion=^(?<version>.*)$
RUN version=2.39.1 && \
    mkdir -p "$HOME/.docker/cli-plugins" && \
    curl -sSL "https://github.com/docker/compose/releases/download/v${version}/docker-compose-$(uname -s)-$(uname -m)" -o "$HOME/.docker/cli-plugins/docker-compose" && \
    chmod +x "$HOME/.docker/cli-plugins/docker-compose" && \
    docker compose version

# Install Docker buildx (docker buildx).
# @see https://github.com/docker/buildx/releases
# renovate: datasource=github-releases depName=docker/buildx extractVersion=^(?<version>.*)$
RUN version=0.26.1 && \
    curl --silent -L "https://github.com/docker/buildx/releases/download/v${version}/buildx-v${version}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx && \
    chmod a+x "$HOME/.docker/cli-plugins/docker-buildx" && \
    docker buildx version

# Install composer.
# @see https://getcomposer.org/download
# renovate: datasource=github-releases depName=composer/composer extractVersion=^(?<version>.*)$
ENV COMPOSER_ALLOW_SUPERUSER=1
# hadolint ignore=DL4006
RUN version=2.8.10 && \
    curl -sS https://getcomposer.org/download/${version}/composer.phar.sha256sum | awk '{ print $1, "composer.phar" }' > composer.phar.sha256sum && \
    curl -sS -o composer.phar https://getcomposer.org/download/${version}/composer.phar && \
    sha256sum -c composer.phar.sha256sum && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    rm composer.phar.sha256sum && \
    composer --version && \
    composer clear-cache
ENV PATH=/root/.composer/vendor/bin:$PATH

# Install NodeJS.
# @see https://nodejs.org/download/release/
# renovate: datasource=node depName=node versioning=node extractVersion=^v(?<version>.*)$
RUN version=23.11.1 && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then arch="x64"; elif [ "${arch}" = "aarch64" ]; then arch="arm64"; fi && \
    curl -L -o "/tmp/node-${version}-linux-${arch}.tar.xz" "https://nodejs.org/download/release/v${version}/node-v${version}-linux-${arch}.tar.xz" && \
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
