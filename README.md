## nginx + Google Pagespeed + Brotli

[NGINX](http://nginx.org/) bundle with support for Google Pagespeed [ngx_pagespeed](https://github.com/apache/incubator-pagespeed-ngx) \
and [Brotli](https://github.com/google/ngx_brotli/)

### Base Docker Image

* [debian](https://hub.docker.com/_/debian/)

### Installation

1. Install [Docker](https://www.docker.com/).

2. Clone this repo

3. Build an image from Dockerfile: `docker build -t="nginx:brotli-pgspd" -f="nginx/Dockerfile" .`)


### Usage

    docker run -d -p 80:8180 -p 443:8543

#### Attach persistent/shared directories

    docker run -d -p 80:8180 -p 443:8543 -v <nginx-dir>:/etc/nginx:ro -v <log-dir>:/var/log/nginx -v <html-dir>:/srv/www nginx:latest

Open `http://<host>:8180` to verify.

