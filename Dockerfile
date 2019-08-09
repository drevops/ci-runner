FROM php:7.2-cli
LABEL Maintainer="Alex Skrypnyk <alex@integratedexperts.com>"

# Install git and ssh.
RUN apt-get update -qq \
    && apt-get install -y git ssh lsof zip unzip vim lynx curl aspell-en jq

RUN git --version \
    && ssh -V \
    && lsof -v \
    && zip --version \
    && unzip -v \
    && vim --version \
    && lynx --version \
    && curl --version \
    && aspell --version \
    && jq --version

# Install shellcheck
ENV SHELLCHECK_VERSION=0.7.0
RUN curl -L -o "/tmp/shellcheck-v${SHELLCHECK_VERSION}.tar.xz" "https://storage.googleapis.com/shellcheck/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \
  && tar --xz -xvf "/tmp/shellcheck-v${SHELLCHECK_VERSION}.tar.xz" \
  && mv "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" /usr/bin/ \
  && shellcheck --version

# Install docker && docker compose.
ENV DOCKER_VERSION=18.09.2
ENV DOCKER_COMPOSE_VERSION=1.23.2
RUN curl -L -o "/tmp/docker-${DOCKER_VERSION}.tgz" "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
    && tar -xz -C /tmp -f "/tmp/docker-${DOCKER_VERSION}.tgz" \
    && mv /tmp/docker/* /usr/bin \
    && docker --version \
    && curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose --version

# Install composer.
ENV COMPOSER_VERSION=1.8.6
ENV COMPOSER_SHA=b66f9b53db72c5117408defe8a1e00515fe749e97ce1b0ae8bdaa6a5a43dd542
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
ENV NVM_VERSION=v0.34.0
ENV NVM_DIR=/root/.nvm
RUN mkdir -p "${NVM_DIR}" \
  && curl -o- "https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh" | bash \
  && . $HOME/.nvm/nvm.sh \
  && nvm --version

ENV SHIPPABLE_NODE_VERSION=v8.16.0
RUN . $HOME/.nvm/nvm.sh \
	&& nvm install "${SHIPPABLE_NODE_VERSION}" \
	&& nvm alias default "${SHIPPABLE_NODE_VERSION}" \
	&& nvm use default \
	&& npm --version
ENV PATH ${NVM_DIR}/versions/node/${SHIPPABLE_NODE_VERSION}/bin:$PATH

# Install Goss.
ENV GOSS_FILES_STRATEGY=cp
RUN curl -fsSL https://goss.rocks/install | sh \
  && goss --version

# Install Bats.
ENV BATS_VERSION=v1.1.0
RUN curl -L -o "/tmp/bats.tar.gz" "https://github.com/bats-core/bats-core/archive/${BATS_VERSION}.tar.gz" \
    && mkdir -p /tmp/bats && tar -xz -C /tmp/bats -f /tmp/bats.tar.gz --strip 1 \
    && cd /tmp/bats \
    && ./install.sh /usr/local \
    && bats -v \
    && rm -Rf /tmp/bats

# Install Ahoy.
ENV AHOY_VERSION=2.0.0
RUN curl -L -o "/usr/local/bin/ahoy" "https://github.com/ahoy-cli/ahoy/releases/download/${AHOY_VERSION}/ahoy-bin-$(uname -s)-amd64" \
  && chmod +x /usr/local/bin/ahoy \
  && ahoy --version

# Install a stub for pygmy.
# Some frameworks may require presence of pygmy to run, but pygmy is not required in CI container.
RUN touch /usr/local/bin/pygmy \
 && chmod +x /usr/local/bin/pygmy
