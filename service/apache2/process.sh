#!/bin/bash -e

chmod 664 /etc/apache2/conf.d/proxy_settings.conf

echo -n "Waiting config file /etc/apache2/conf.d/proxy_settings.conf"
while [ ! -e "/etc/apache2/conf.d/proxy_settings.conf" ]
do
  echo -n "."
  sleep 0.1
done
echo "ok"

exec /usr/sbin/httpd -DFOREGROUND
