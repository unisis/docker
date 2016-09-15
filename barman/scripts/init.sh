#!/bin/bash

# Configure s3cmd command to upload BarMan backups
CONFIG_FILE=/var/lib/barman/.s3cfg
wget https://s3.amazonaws.com/$S3_BUCKET_FILES/s3cfg -O $CONFIG_FILE
sed -i $CONFIG_FILE -e s,S3_ACCESS_KEY,$S3_ACCESS_KEY,g
sed -i $CONFIG_FILE -e s,S3_SECRET_KEY,$S3_SECRET_KEY,g

# Configure BarMan file
TEMPLATE_FILE=/root/barman.conf
CONFIG_FILE=/etc/barman.conf
cp $TEMPLATE_FILE $CONFIG_FILE
# NOTE: We don't have variables on barman.conf at this moment

# Copy SSH config file to not have strict host checking for Postgres
TEMPLATE_FILE=/root/ssh_config
CONFIG_FILE=/var/lib/barman/.ssh/config
cp $TEMPLATE_FILE $CONFIG_FILE

# Create directory to receive Pgsql wal files
mkdir -p /var/lib/barman/main/incoming

# Create directory to copy Odoo files (used by post-x.sh scripts)
mkdir -p /var/lib/barman/files

# Assign permissions to mounted volumes
chown -R barman:barman /var/lib/barman
chown -R barman:barman /var/log/barman

chmod -R 740 /var/lib/barman
chmod -R 740 /var/log/barman

# Externally, SSH keys were mounted into home directory of user barman
# at /var/lib/barman/.ssh, configure permissions here for private key
chmod 600 /var/lib/barman/.ssh/id_rsa

exit 0
