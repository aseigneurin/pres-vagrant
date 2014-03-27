#!/bin/bash
set -e
set -x

apt-get -y install apache2

echo "Je suis le back-end #1" > /var/www/index.html
