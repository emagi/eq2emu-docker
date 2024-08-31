FROM php:7.4-apache

ENV LISTEN_DBWEB_ADDRESS=80
ENV LISTEN_DBWEB_ADDRESS="127.0.0.1"

RUN apt-get update -y && apt-get install -y libpng-dev

RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) gd