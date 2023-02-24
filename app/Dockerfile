# docker image build -t virtpanel/app .
# winpty docker run --rm -it --name virtpanel -p 80:80 -p 443:443 -v D:\\docker\\virtpanel-app-conf:/usr/local/virtpanel virtpanel
FROM php:8.1-fpm

RUN useradd --system --shell /bin/bash --home /usr/local/virtpanel --create-home virtpanel

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
    certbot nginx dnsutils unzip nano procps wget bc mariadb-client bash expect openssh-client supervisor \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    libgmp-dev \
    libzip-dev libbz2-dev \
    libonig-dev \
    git \
    sudo \
    openssl python3-certbot-nginx bind9-utils bc mariadb-client dnsutils iputils-ping \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/www \
 && mkdir -p /tmp \
 && ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock \
 && mkdir -p /run/php-fpm \
 && chown www-data:www-data /run/php-fpm \
 && rm -f /usr/local/etc/php-fpm.d/zz*
    
RUN docker-php-ext-configure gd --with-jpeg=/usr/include --with-freetype=/usr/include \
 && docker-php-ext-install -j$(nproc) gd \
 && docker-php-ext-configure gmp \
 && docker-php-ext-install -j$(nproc) gmp \
 && docker-php-ext-configure zip \
 && docker-php-ext-install -j$(nproc) zip \
 && docker-php-ext-configure mbstring \
 && docker-php-ext-install -j$(nproc) mbstring \
 && docker-php-ext-configure pdo_mysql \
 && docker-php-ext-install -j$(nproc) pdo_mysql \
 && docker-php-ext-configure posix \
 && docker-php-ext-install -j$(nproc) posix \
 && docker-php-ext-configure pcntl \
 && docker-php-ext-install -j$(nproc) pcntl \
 && docker-php-ext-configure sockets \
 && docker-php-ext-install -j$(nproc) sockets \
 && pecl install redis \
 && docker-php-ext-enable redis
# && pecl install swoole \
# && docker-php-ext-enable swoole

COPY ./openswoole/openswoole.so /usr/local/lib/php/extensions/no-debug-non-zts-20210902/
COPY ./openswoole/php_openswoole.h /usr/local/lib/php/extensions/no-debug-non-zts-20210902/
COPY ./openswoole/config.h /usr/local/lib/php/extensions/no-debug-non-zts-20210902/
COPY ./openswoole/openswoole.ini /usr/local/etc/php/conf.d/zz-openswoole.ini
 
# Install ionCube
RUN cd /tmp;wget --progress=dot -O ioncube_loaders.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz;tar xf ioncube_loaders.tar.gz;mkdir -p /usr/lib/php/;cp ioncube/ioncube_loader_lin_8.1.so /usr/lib/php/;rm -rf ioncube*

COPY files/php.ini /usr/local/etc/php/
COPY files/nginx-conf /etc/nginx/nginx.conf
COPY files/nginx-vh /etc/nginx/conf.d/default.conf
COPY files/start-* /usr/bin/
RUN chmod +x /usr/bin/start-*
COPY files/sudoers /etc/sudoers
COPY files/php-fpm-conf /usr/local/etc/php-fpm.conf
COPY files/php-fpm-vh /usr/local/etc/php-fpm.d/www.conf
COPY files/supervisord.conf /etc/supervisord.conf
RUN chown -R virtpanel:virtpanel /var/run/php-fpm /var/lib/nginx /run
#RUN touch /usr/local/virtpanel/.bashrc;sed -i '/virtpanel/d' /usr/local/virtpanel/.bashrc;echo 'alias virtpanel="php /usr/local/virtpanel/www/cli.php"' >> /usr/local/virtpanel/.bashrc;chown virtpane
#RUN nginx -t
USER virtpanel

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
