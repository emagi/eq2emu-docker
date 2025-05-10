FROM php:7.4-apache

# 1) Install curl (to grab Adminer) and htpasswd utility
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl \
      apache2-utils \
	  libpng-dev \
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) gd

# 6) Expose & run
CMD ["apache2-foreground"]
