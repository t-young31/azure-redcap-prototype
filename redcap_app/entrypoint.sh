#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# Check the database is up..


a2enmod headers  # enable apache headers module
echo "Header set MyHeader \"%D %t"\" >> /etc/apache2/apache2.conf
echo "Header always unset \"X-Powered-By\"" >> /etc/apache2/apache2.conf
echo "Header unset \"X-Powered-By\"" >> /etc/apache2/apache2.conf

service cron start 
/usr/sbin/apache2ctl -D FOREGROUND
