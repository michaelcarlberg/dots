#!/usr/bin/bash -ex

if [ $# -eq 0 ]; then
  set "$(mktemp -d)"
fi

mkdir -p "$1"
pushd "$1"

sudo dnf install -y perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel GeoIP GeoIP-devel

if [ ! -f nginx-1.15.8.tar.gz ]; then
  wget https://nginx.org/download/nginx-1.15.8.tar.gz
  tar xzvf nginx-1.15.8.tar.gz
fi

if [ ! -f pcre-8.42.tar.gz ]; then
  wget https://ftp.exim.org/pub/pcre/pcre-8.42.tar.gz
  tar xzvf pcre-8.42.tar.gz
fi

if [ ! -f zlib-1.2.11.tar.gz ]; then
  wget https://www.zlib.net/zlib-1.2.11.tar.gz
  tar xzvf zlib-1.2.11.tar.gz
fi

if [ ! -f openssl-1.1.1a.tar.gz ]; then
  wget https://www.openssl.org/source/openssl-1.1.1a.tar.gz
  tar xzvf openssl-1.1.1a.tar.gz
fi

pushd nginx-1.15.8
  ./configure --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib64/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --user=nginx \
    --group=nginx \
    --build=Fedora \
    --builddir=nginx-1.15.8 \
    --with-select_module \
    --with-poll_module \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_rewrite_module \
    --with-http_proxy_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-http_perl_module=dynamic \
    --with-perl_modules_path=/usr/lib64/perl5 \
    --with-perl=/usr/bin/perl \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-stream_ssl_preread_module \
    --with-compat \
    --with-pcre=../pcre-8.42 \
    --with-pcre-jit \
    --with-zlib=../zlib-1.2.11 \
    --with-openssl=../openssl-1.1.1a \
    --with-openssl-opt=no-nextprotoneg \
    --with-debug
  make
  sudo make install

  sudo cp man/nginx.8 /usr/share/man/man8
  sudo gzip /usr/share/man/man8/nginx.8

  if ! sudo passwd -S nginx >/dev/null 2>&1; then
    sudo useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx
  fi

  sudo rm /etc/nginx/*.default
  sudo mkdir -p /etc/nginx/{conf.d,snippets,sites-available,sites-enabled}
  sudo chmod 640 /var/log/nginx/* || true
  sudo chown nginx:adm /var/log/nginx/access.log /var/log/nginx/error.log || true
  sudo ln -s /usr/lib64/nginx/modules /etc/nginx/modules || true

  cat <<EOF | sudo tee /etc/systemd/system/nginx.service
[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target
EOF

  cat <<EOF | sudo tee /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 nginx adm
    sharedscripts
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            pkill -USR1 -F /var/run/nginx.pid
        fi
    endscript
}
EOF

popd

popd
