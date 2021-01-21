ARG PHP="7.4-cli"
FROM php:${PHP} as builder

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

ARG PHPCS="latest"
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

# Install PHP-CS-FIXER
RUN set -eux \
	&& git clone https://github.com/FriendsOfPHP/PHP-CS-Fixer

ARG PCF="latest"
RUN set -eux \
	&& cd PHP-CS-Fixer \
	&& if [ "${PCF}" = "latest" ]; then \
	VERSION="$( git tag | sort -V | tail -1 )"; \
	else \
	VERSION="$( git tag | grep -E "^v?${PCF}\.[.0-9]+\$" | sort -V | tail -1 )"; \
	fi \
	&& curl -sS -L https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/${VERSION}/php-cs-fixer.phar -o /php-cs-fixer \
	&& chmod +x /php-cs-fixer \
	&& mv /php-cs-fixer /usr/bin/php-cs-fixer

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHPUnit
RUN composer global require phpunit/phpunit ^9.0 --no-progress --no-scripts --no-interaction
