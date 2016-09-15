# BarMan image

Requirement: On {BARMAN_DATA}/.ssh directory we should place the private/public key for BarMan
             (id_rsa and id_rsa.pub) as well as the authorized_keys file including the public key of Postgresql

NOTE: Variable PGSQL_HOST is injected later since Barman is launched before 
      Pgsql and both containers (barman and pgsql) have mutual references

docker run --detach \
    --name barman \
    --restart=always \
    --hostname barman \
    --dns=127.0.0.1 \
    --volume {BARMAN_DATA}:/var/lib/barman \
    --volume {BARMAN_LOGS}:/var/log/barman \
    --env S3_ACCESS_KEY={S3_ACCESS_KEY} \
    --env S3_SECRET_KEY={S3_SECRET_KEY} \
    --env S3_BUCKET_FILES={S3_BUCKET_FILES} \
    --env S3_BUCKET_BACKUPS={S3_BUCKET_BACKUPS} \
    --env S3_BACKUPS_DIR={S3_BACKUPS_DIR} \
    unisis/barman /bin/bash /root/start.sh
