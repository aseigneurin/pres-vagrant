#!/bin/bash
set -e
set -x

apt-get -y install nginx

if [ -f /etc/nginx/sites-enabled/default ]
then
  rm /etc/nginx/sites-enabled/default

  echo "upstream backend {
    server 192.168.1.11;
    server 192.168.1.12;
  }
  server {
    listen 80;
    server_name localhost;
    location / {
      proxy_pass http://backend/;
      proxy_connect_timeout 10;
    }
  }" > /etc/nginx/sites-available/ippon

  ln -s /etc/nginx/sites-available/ippon /etc/nginx/sites-enabled/ippon

  nginx
fi
