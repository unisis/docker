# Postgresql Image

Requirement: On {PGSQL_DATA}/.ssh directory we should place the private/public key for Postgresql
             (id_rsa and id_rsa.pub) as well as the authorized_keys file including the public key of BarMan

NOTE: Variable BARMAN_HOST is injected later since Barman is launched before
      Pgsql and both containers (barman and pgsql) have mutual references

docker run --detach \
    --name pgsql \
    --restart=always \
    --hostname pgsql \
    --dns=127.0.0.1 \
    --volume {PGSQL_DATA}:/var/lib/postgresql \
    --volume {PGSQL_LOGS}:/var/log/postgresql \
    --env PGSQL_PORT=$PGSQL_PORT \
    --env DB_NAME={DB_NAME} \
    --env DB_USER={DB_USER} \
    --env DB_PWD={DB_PWD} \
    unisis/pgsql /bin/bash /root/start.sh
