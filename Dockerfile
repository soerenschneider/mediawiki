FROM mediawiki:1.41.0 AS builder
RUN apt update && apt -y install git jq
#RUN cat composer.local.json | jq '.extra."merge-plugin".include += ["extensions/OpenIDConnect/composer.json"]' > composer.local.json
RUN mkdir /extensions
RUN git -C /extensions clone https://gerrit.wikimedia.org/r/mediawiki/extensions/OpenIDConnect
RUN git -C /extensions clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PluggableAuth

FROM composer:2.7.1 AS composer

FROM mediawiki:1.41.0
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
COPY --from=builder --chown=www-data:www-data /extensions/OpenIDConnect /var/www/html/extensions/OpenIDConnect
COPY --from=builder --chown=www-data:www-data /extensions/PluggableAuth /var/www/html/extensions/PluggableAuth
COPY composer.local.json .
USER www-data
RUN composer -d extensions/OpenIDConnect/ install --no-cache
