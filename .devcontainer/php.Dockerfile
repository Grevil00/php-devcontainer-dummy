ARG PHP
FROM php:7.4-cli

#Install xdebug and modify it accordingly for use in Drupal
RUN pecl install xdebug-3.0.1 \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode = debug" >>  /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request = yes" >>  /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port = 9000" >>  /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install Php_CodeSniffer
RUN set -eux \
	&& DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		curl \
		git \
	&& git clone https://github.com/squizlabs/PHP_CodeSniffer

ARG PHPCS
RUN set -eux \
	&& cd PHP_CodeSniffer \
	&& if [ "${PHPCS}" = "latest" ]; then \
		VERSION="$( git describe --abbrev=0 --tags )"; \
	else \
		VERSION="$( git tag | grep -E "^v?${PHPCS}\.[.0-9]+\$" | sort -V | tail -1 )"; \
	fi \
	&& curl -sS -L https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${VERSION}/phpcs.phar -o /phpcs.phar \
	&& chmod +x /phpcs.phar \
	&& mv /phpcs.phar /usr/bin/phpcs


FROM php:${PHP} as production

COPY --from=builder /usr/bin/phpcs /usr/bin/phpcs
ENV WORKDIR /data
WORKDIR /data

ENTRYPOINT ["phpcs"]
CMD ["--version"]
