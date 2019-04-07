FROM php:7.1-cli
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
ENV SHELLCHECK_VERSION=0.6.0
RUN curl -L -o "/tmp/shellcheck-v$SHELLCHECK_VERSION.tar.xz" "https://storage.googleapis.com/shellcheck/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \
  && tar --xz -xvf "/tmp/shellcheck-v${SHELLCHECK_VERSION}.tar.xz" \
  && mv "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" /usr/bin/ \
  && shellcheck --version

# Install docker && docker compose.
RUN curl -L -o /tmp/docker-18.06.1-ce.tgz https://download.docker.com/linux/static/stable/x86_64/docker-18.06.1-ce.tgz \
    && tar -xz -C /tmp -f /tmp/docker-18.06.1-ce.tgz \
    && mv /tmp/docker/* /usr/bin \
    && docker --version \
    && curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && docker-compose --version

# Install composer.
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/download/1.6.3/composer.phar \
    && echo "52cb7bbbaee720471e3b34c8ae6db53a38f0b759c06078a80080db739e4dcab6 /usr/local/bin/composer" | sha256sum \
    && chmod +x /usr/local/bin/composer \
    && composer --version \
    # Install composer plugin to speed up packages downloading.
    && composer global require hirak/prestissimo \
    && composer clear-cache
ENV PATH /root/.composer/vendor/bin:$PATH

# Install NVM and NodeJS.
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash \
  && . $HOME/.nvm/nvm.sh \
  && nvm --version

ENV SHIPPABLE_NODE_VERSION=v8.9.1
RUN . $HOME/.nvm/nvm.sh \
	&& nvm install $SHIPPABLE_NODE_VERSION \
	&& nvm alias default $SHIPPABLE_NODE_VERSION \
	&& nvm use default \
	&& npm --version
ENV PATH $NVM_DIR/versions/node/$SHIPPABLE_NODE_VERSION/bin:$PATH

# Install Goss.
ENV GOSS_FILES_STRATEGY=cp
RUN curl -fsSL https://goss.rocks/install | sh \
  && goss --version

# Install Bats.
RUN curl -L -o /tmp/bats.tar.gz https://github.com/bats-core/bats-core/archive/v1.1.0.tar.gz \
    && mkdir -p /tmp/bats && tar -xz -C /tmp/bats -f /tmp/bats.tar.gz --strip 1 \
    && cd /tmp/bats \
    && ./install.sh /usr/local \
    && bats -v \
    && rm -Rf /tmp/bats

# Install Ahoy.
RUN curl -L https://github.com/ahoy-cli/ahoy/releases/download/2.0.0/ahoy-bin-`uname -s`-amd64 -o /usr/local/bin/ahoy \
  && chmod +x /usr/local/bin/ahoy \
  && ahoy --version

# Install a stub for pygmy.
# Some frameworks may require presence of pygmy to run, but pygmy is not required in CI container.
RUN touch /usr/local/bin/pygmy \
 && chmod +x /usr/local/bin/pygmy
