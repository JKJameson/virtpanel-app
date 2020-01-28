# docker image build -t virtpanel .
# winpty docker run --rm -it --name virtpanel -p 80:80 -p 443:443 -v D:\\docker\\virtpanel-app-conf:/usr/local/virtpanel virtpanel
FROM alpine:latest

RUN apk add --no-cache openssl certbot certbot-nginx nginx bind-tools unzip nano wget php7 php7-fpm php7-gd php7-pecl-redis php7-curl php7-gmp bc php7-pecl-igbinary php7-zip mariadb php7-phar php7-mbstring php7-openssl php7-pdo php7-pdo_mysql php7-ctype php7-posix php7-pcntl php7-sockets bash redis influxdb
RUN mkdir -p /run/nginx

# Install ionCube
RUN ARCH=`uname -m`;ARCH=${ARCH//x86_64/x86-64};cd /tmp;wget --progress=dot -O ioncube_loaders.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${ARCH}.tar.gz;tar xf ioncube_loaders.tar.gz;PHPEXTDIR=`php -i | grep extension_dir | awk '{print $3}'`;PHPINILOC=`php -i | grep "Loaded Configuration File" | awk '{print $5}'`;PHPVERSION=`php -v | head -n 1 | awk '{print $2}'`;PHPVERSION=${PHPVERSION%.*};cp ioncube/ioncube_loader_lin_$PHPVERSION.so $PHPEXTDIR;sed -i '/ioncube/d' $PHPINILOC;echo "zend_extension = $PHPEXTDIR/ioncube_loader_lin_$PHPVERSION.so" > $PHPINILOC.new;cat $PHPINILOC >> $PHPINILOC.new;rm -f $PHPINILOC;mv $PHPINILOC.new $PHPINILOC;rm -rf ioncube*

COPY files/php.ini /etc/php7/php.ini
COPY files/nginx-conf /etc/nginx/nginx.conf
COPY files/nginx-vh /etc/nginx/conf.d/default.conf
COPY files/start /start
RUN chmod +x /start
COPY files/php-fpm-conf /etc/php7/php-fpm.conf
COPY files/php-fpm-vh /etc/php7/php-fpm.d/www.conf
COPY files/my.cnf /etc/my.cnf
RUN rm -rf /etc/my.cnf.d
COPY files/redis.conf /etc/redis.conf
COPY files/influxdb.conf /etc/influxdb.conf
RUN touch /root/.bashrc;sed -i '/virtpanel/d' /root/.bashrc;echo 'alias virtpanel="php /usr/local/virtpanel/www/cli.php"' >> /root/.bashrc
#RUN nginx -t

ENTRYPOINT ["/bin/bash"]
CMD ["./start"]