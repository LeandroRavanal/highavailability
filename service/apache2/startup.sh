#!/bin/bash -e

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-apache2-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # balancer member ips
  for bmip in $(complex-bash-env iterate APACHE2_BALANCER_MEMBER_IPS)
  do
    sed -i "s|{{ APACHE2_BALANCER_MEMBER_IPS }}|BalancerMember http://${!bmip}:8080\n    {{ APACHE2_BALANCER_MEMBER_IPS }}|g" ${CONTAINER_SERVICE_DIR}/apache2/assets/proxy_settings.conf
  done
  sed -i "/{{ APACHE2_BALANCER_MEMBER_IPS }}/d" ${CONTAINER_SERVICE_DIR}/apache2/assets/proxy_settings.conf

  touch $FIRST_START_DONE
fi

if [ ! -e "/etc/apache2/conf.d/proxy_settings.conf" ]; then
  ln -sf ${CONTAINER_SERVICE_DIR}/apache2/assets/proxy_settings.conf /etc/apache2/conf.d/proxy_settings.conf
fi

exit 0
