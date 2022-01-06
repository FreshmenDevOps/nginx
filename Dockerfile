# https://github.com/apache/incubator-pagespeed-ngx/issues/1717
FROM debian:bullseye-slim

# install build env https://github.com/nginxinc/docker-nginx/blob/master/Dockerfile-debian.template
RUN apt-get update -y && \
	apt-get upgrade -y && \
  addgroup --system --gid 101 nginx && \
  adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx

RUN apt-get install -y \
	curl \
	unzip \
	libatomic-ops-dev \
	build-essential \
	ca-certificates \
	uuid-dev \
	zlib1g-dev \
	libssl-dev \
	libpcre3 \
	libpcre3-dev

# stable branch
ENV NGINX_VERSION 1.20.2
# -stable tag
ENV NGX_PAGESPEED_VERSION 1.13.35.2
# tip of master
ENV NGX_BROTLI_VERSION master
# https://github.com/google/brotli/issues/930
ENV BROTLI_VERSION 4ec67035c0d97c270c1c73038cc66fc5fcdfc120

RUN cd /tmp && \
  curl -o ngx_brotli-${NGX_BROTLI_VERSION}.zip -L https://github.com/google/ngx_brotli/archive/refs/heads/${NGX_BROTLI_VERSION}.zip && \
  unzip ngx_brotli-${NGX_BROTLI_VERSION}.zip

RUN cd /tmp && \
  curl -o brotli.zip -L https://github.com/google/brotli/archive/${BROTLI_VERSION}.zip && \
  unzip brotli.zip -d ngx_brotli-${NGX_BROTLI_VERSION}/deps/ && \
  rmdir ngx_brotli-${NGX_BROTLI_VERSION}/deps/brotli && \
  mv ngx_brotli-${NGX_BROTLI_VERSION}/deps/brotli-${BROTLI_VERSION} ngx_brotli-${NGX_BROTLI_VERSION}/deps/brotli

RUN cd /tmp && \
  curl -O -L https://github.com/pagespeed/ngx_pagespeed/archive/v${NGX_PAGESPEED_VERSION}-stable.zip && \
  unzip v${NGX_PAGESPEED_VERSION}-stable.zip

RUN cd /tmp/incubator-pagespeed-ngx-${NGX_PAGESPEED_VERSION}-stable/ && \
  curl -L https://dl.google.com/dl/page-speed/psol/${NGX_PAGESPEED_VERSION}-x64.tar.gz | tar -xz

# Build Nginx with support for PageSpeed
RUN cd /tmp && \
  curl -L http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -zx && \
  cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure --prefix=/var/lib/nginx \
  --add-module=/tmp/ngx_brotli-${NGX_BROTLI_VERSION} \
  --add-module=/tmp/incubator-pagespeed-ngx-${NGX_PAGESPEED_VERSION}-stable \
  --conf-path=/etc/nginx/nginx.conf \
  --modules-path=/usr/lib/nginx \
  --sbin-path=/usr/sbin \
  --group=nginx \
  --user=nginx \
  --with-cc-opt='-O3 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic' \
  --http-log-path=/var/log/nginx/access.log \
  --error-log-path=/var/log/nginx/error.log \
  --with-file-aio \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_dav_module \
  --with-http_degradation_module \
  --with-http_flv_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_mp4_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_slice_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-libatomic \
  --without-http_autoindex_module \
  --without-http_browser_module \
  --without-http_scgi_module \
  --without-http_split_clients_module \
  --without-http_upstream_ip_hash_module \
  --without-http_userid_module \
  --without-http_uwsgi_module \
  --without-mail_imap_module \
  --without-mail_pop3_module \
  --without-mail_smtp_module \
  --with-pcre \
  --with-pcre-jit \
  --with-perl=/usr/bin/perl \
  --without-poll_module \
  --without-select_module \
  --with-stream \
  --with-stream_ssl_module \
  --with-threads && \
  make -j4 install --silent

RUN apt-get remove -y --purge build-essential \
  curl \
  libatomic-ops-dev \
  libssl-dev \
	libpcre3-dev \
  uuid-dev \
  unzip \
	zlib1g-dev && \
  apt-get remove -y --autoremove && \
  apt-get clean && \
  rm -rf /var/lib/apt /var/cache/apt

VOLUME ["/etc/nginx/", \
  "/var/tmp/nginx", \
  "/var/lib/nginx", \
  "/var/log/nginx", \
  "/srv/www" ]

WORKDIR /etc/nginx

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 80 443
