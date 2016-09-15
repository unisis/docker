# NginX Image

NOTE: Port 80 is published just to force a redirection to https

docker run --detach \
    --name nginx \
    --restart=always \
    --hostname nginx \
    --dns=127.0.0.1 \
    --publish 0.0.0.0:80:80 \
    --publish 0.0.0.0:443:{NGINX_PORT} \
    --volume {NGINX_CERTS}:/etc/nginx/certs \
    --volume {NGINX_LOGS}:/var/log/nginx \
    --env NGINX_PORT={NGINX_PORT} \
    --env DNS_NAME={INSTALL_DNS} \
    --env ODOO_HOST={ODOO_HOST} \
    --env ODOO_PORT={ODOO_PORT} \
    --env REQUEST_TIMEOUT=600 \
    unisis/nginx /bin/bash /root/start.sh
