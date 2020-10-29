FROM php:7.4-cli
LABEL Maintainer="Alex Skrypnyk <alex@integratedexperts.com>"

# Install git and ssh.
RUN apt-get update -qq \
    && apt-get install -y git ssh lsof zip unzip vim lynx curl aspell-en jq tree

RUN git --version \
    && ssh -V \
    && lsof -v \
    && zip --version \
    && unzip -v \
    && vim --version \
    && lynx --version \
    && curl --version \
    && aspell --version \
    && jq --version \
    && tree --version

# Install shellcheck
# @see https://github.com/koalaman/shellcheck/releases
ENV SHELLCHECK_VERSION=0.7.1
RUN curl -L -o "/tmp/shellcheck-v${SHELLCHECK_VERSION}.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \
  && tar --xz -xvf "/tmp/shellcheck-v${SHELLCHECK_VERSION}.tar.xz" \
  && mv "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" /usr/bin/ \
  && shellcheck --version

# Install docker && docker compose.
# @see https://download.docker.com/linux/static/stable/x86_64
# @see https://github.com/docker/compose/releases
ENV DOCKER_VERSION=19.03.13
ENV DOCKER_COMPOSE_VERSION=1.27.4
RUN curl -L -o "/tmp/docker-${DOCKER_VERSION}.tgz" "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
    && tar -xz -C /tmp -f "/tmp/docker-${DOCKER_VERSION}.tgz" \
    && mv /tmp/docker/* /usr/bin \
    && docker --version \
    && curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose --version

# Install composer.
# @see https://getcomposer.org/download
ENV COMPOSER_VERSION=1.10.16
ENV COMPOSER_SHA=1f210b9037fcf82670d75892dfc44400f13fe9ada7af9e787f93e50e3b764111
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -L -o "/usr/local/bin/composer" "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" \
    && echo "${COMPOSER_SHA} /usr/local/bin/composer" | sha256sum \
    && chmod +x /usr/local/bin/composer \
    && composer --version \
    # Install composer plugin to speed up packages downloading.
    && composer global require hirak/prestissimo \
    && composer clear-cache
ENV PATH /root/.composer/vendor/bin:$PATH

# Install NVM and NodeJS.
# @see https://github.com/nvm-sh/nvm/releases
ENV NVM_VERSION=v0.36.0
ENV NVM_DIR=/root/.nvm
RUN mkdir -p "${NVM_DIR}" \
  && curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash \
  && . $HOME/.nvm/nvm.sh \
  && nvm --version

ENV SHIPPABLE_NODE_VERSION=v15.0.1
RUN . $HOME/.nvm/nvm.sh \
	&& nvm install "${SHIPPABLE_NODE_VERSION}" \
	&& nvm alias default "${SHIPPABLE_NODE_VERSION}" \
	&& nvm use default \
	&& npm --version
ENV PATH ${NVM_DIR}/versions/node/${SHIPPABLE_NODE_VERSION}/bin:$PATH

# Install Goss.
# @see https://github.com/aelsabbahy/goss
ENV GOSS_FILES_STRATEGY=cp
RUN curl -fsSL https://goss.rocks/install | sh \
  && goss --version

# Install Bats.
# @see https://github.com/bats-core/bats-core/releases
ENV BATS_VERSION=v1.2.1
RUN curl -L -o "/tmp/bats.tar.gz" "https://github.com/bats-core/bats-core/archive/${BATS_VERSION}.tar.gz" \
    && mkdir -p /tmp/bats && tar -xz -C /tmp/bats -f /tmp/bats.tar.gz --strip 1 \
    && cd /tmp/bats \
    && ./install.sh /usr/local \
    && bats -v \
    && rm -Rf /tmp/bats

# Install Ahoy.
# @see https://github.com/ahoy-cli/ahoy/releases
ENV AHOY_VERSION=2.0.0
RUN curl -L -o "/usr/local/bin/ahoy" "https://github.com/ahoy-cli/ahoy/releases/download/${AHOY_VERSION}/ahoy-bin-$(uname -s)-amd64" \
  && chmod +x /usr/local/bin/ahoy \
  && ahoy --version

# Install a stub for pygmy.
# Some frameworks may require presence of pygmy to run, but pygmy is not required in CI container.
RUN touch /usr/local/bin/pygmy \
 && chmod +x /usr/local/bin/pygmy
