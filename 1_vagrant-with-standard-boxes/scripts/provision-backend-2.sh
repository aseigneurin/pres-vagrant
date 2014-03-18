#!/bin/bash
set -e
set -x

apt-get -y install apache2

echo "<html><body><h1>Je suis le back-end #2</h1></body></html>" > /var/www/index.html
