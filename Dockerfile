# docker image build -t virtpanel .
# winpty docker run --rm -it --name virtpanel -p 80:80 -p 443:443 -v D:\\docker\\virtpanel-app-conf:/usr/local/virtpanel virtpanel
FROM php:7.3-fpm

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
    certbot nginx dnsutils unzip nano wget bc mariadb-server mariadb-client bash expect openssh-client redis influxdb \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    libgmp-dev \
    libzip-dev libbz2-dev \
    libonig-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
    
# php7-pecl-redis php7-pecl-igbinary php7-ctype
RUN mkdir -p /run/nginx

RUN docker-php-ext-configure gd --with-png-dir=/usr/include --with-jpeg-dir=/usr/include --with-freetype-dir=/usr/include \
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
 && docker-php-ext-install -j$(nproc) sockets
 
# Install ionCube
RUN cd /tmp;wget --progress=dot -O ioncube_loaders.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz;tar xf ioncube_loaders.tar.gz;cp ioncube/ioncube_loader_lin_7.3.so /usr/lib/php/;rm -rf ioncube*

COPY files/php.ini /usr/local/etc/php/
COPY files/nginx-conf /etc/nginx/nginx.conf
COPY files/nginx-vh /etc/nginx/conf.d/default.conf
COPY files/start /start
RUN chmod +x /start
COPY files/php-fpm-conf /usr/local/etc/php-fpm.conf
COPY files/php-fpm-vh /usr/local/etc/php-fpm.d/www.conf
COPY files/my.cnf /etc/my.cnf
RUN rm -rf /etc/my.cnf.d
COPY files/redis.conf /etc/redis.conf
COPY files/influxdb.conf /etc/influxdb.conf
RUN touch /root/.bashrc;sed -i '/virtpanel/d' /root/.bashrc;echo 'alias virtpanel="php /usr/local/virtpanel/www/cli.php"' >> /root/.bashrc
#RUN nginx -t

ENTRYPOINT ["/bin/bash"]
CMD ["./start"]
