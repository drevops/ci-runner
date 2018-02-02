FROM php:7.1-cli

# Install git and ssh.
RUN apt-get update -qq \
    && apt-get install -y git ssh

# Install docker.
RUN curl -L -o /tmp/docker-17.03.0-ce.tgz https://get.docker.com/builds/Linux/x86_64/docker-17.03.0-ce.tgz \
    && tar -xz -C /tmp -f /tmp/docker-17.03.0-ce.tgz \
    && mv /tmp/docker/* /usr/bin

# Install docker-compose.
RUN curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install composer.
RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/download/1.5.2/composer.phar \
    && echo "61dfd2f9262a0a2469e0c1864ab1cce6d3e63f9053faf883cd08307413d92119010638bfbee7c90c9b6977e284814bcb7bfdc01dd9cb9125ac947a2968c791bc  /usr/local/bin/composer" | sha512sum \
    && chmod +x /usr/local/bin/composer
