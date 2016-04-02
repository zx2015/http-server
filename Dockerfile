FROM ubuntu:14.04
MAINTAINER gnesis@163.com

#add 163 mirror for apt
ADD sources.list /etc/apt/sources.list
ADD .bashrc /root/.bashrc

ENV DEBIAN_FRONTEND noninteractive

# Packages
RUN rm -rf /var/lib/apt/lists
RUN apt-get update -q --fix-missing
RUN apt-get -y upgrade

#Install apache2 php
RUN apt-get install -y apache2 curl libapache2-mod-php5 php5-curl php5-gd php5-mysql rsync mysql-client -qq

#set recommended php.ini settings
#copied from wordpress project
#RUN { \
#		echo 'opcache.memory_consumption=128'; \
#		echo 'opcache.interned_strings_buffer=8'; \
#		echo 'opcache.max_accelerated_files=4000'; \
#		echo 'opcache.revalidate_freq=60'; \
#		echo 'opcache.fast_shutdown=1'; \
#		echo 'opcache.enable_cli=1'; \
#	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite
RUN a2enmod expires
RUN apt-get autoclean
RUN rm -rf /var/lib/apt/lists/*

# Setup environmnt for apache's init script
ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars


ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE $APACHE_RUN_DIR/apache2.pid
ENV APACHE_LOCK_DIR /var/lock/apache2

ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

RUN find "$APACHE_CONFDIR" -type f -exec sed -ri ' \
        s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
        s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
' '{}' ';'

EXPOSE 80
CMD ["apache2", "-DFOREGROUND"]

