FROM php:7.4-cli

#Install xdebug and modify it accordingly for use in Drupal
RUN pecl install xdebug-3.0.1 \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode = debug" >>  /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request = yes" >>  /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port = 9000" >>  /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

#Install phpcs TODO!!
#RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar > /usr/local/bin/phpcs \
#    && curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar > /usr/local/bin/phpcs \
#    && chmod +x /usr/local/bin/phpcs
