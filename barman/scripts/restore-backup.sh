#!/bin/bash

set -x

# This script is used to restore a backup stored on S3

if [ "$#" != 2 ]; then
   echo "ERROR: Not enough parameters were provided"
   echo "USAGE: restore-backup.sh <install-id> <name-of-backup>"
   echo "SAMPLE: restore-backup.sh 21 20160605T120124"
   exit 1
fi

INSTALL_ID=$1
BARMAN_BACKUP_ID=$2

S3_BACKUPS_DIR="install-${INSTALL_ID}"
S3_BACKUP_DIR="$S3_BUCKET_BACKUPS/$S3_BACKUPS_DIR/$BARMAN_BACKUP_ID"

# Download backup of files from Amazon S3
echo "INFO: Downloading backup of files..."
FILES_BACKUP=files.tar.gz
rm -rf /tmp/$FILES_BACKUP
s3cmd --config=/var/lib/barman/.s3cfg get s3://$S3_BACKUP_DIR/$FILES_BACKUP /tmp/$FILES_BACKUP
if [ ! -e /tmp/$FILES_BACKUP ] || [ ! -s /tmp/$FILES_BACKUP ]; then
    echo "ERROR: An error occurred trying to download backup of files from s3://$S3_BACKUP_DIR/$FILES_BACKUP"
    exit 1
fi

# Download backup of tables from Amazon S3
echo "INFO: Downloading backup of tables..."
TABLES_BACKUP=tables.tar.gz
rm -rf /tmp/$TABLES_BACKUP
s3cmd --config=/var/lib/barman/.s3cfg get s3://$S3_BACKUP_DIR/$TABLES_BACKUP /tmp/$TABLES_BACKUP
if [ ! -e /tmp/$TABLES_BACKUP ] || [ ! -s /tmp/$TABLES_BACKUP ]; then
    echo "ERROR: An error occurred trying to download backup of tables from s3://$S3_BACKUP_DIR/$TABLES_BACKUP"
    exit 1
fi

# We have the required files to start the restore. However, for security reasons,
# before restore we will create a full backup so if this restore fails we can rollback
# THIS FEATURE IS CURRENTLY DISABLED - IT COULD BE OPTIONAL
# echo "INFO: Perfoming backup of current database before restore (for rollback if a problem occurs)..."
# su barman -c "barman backup main"

# Restore tables
echo "INFO: Restoring database..."
TABLES_DIR="/var/lib/barman/main/base/$BARMAN_BACKUP_ID"
rm -rf $TABLES_DIR
mkdir -p $TABLES_DIR
mv /tmp/$TABLES_BACKUP $TABLES_DIR
cd $TABLES_DIR
tar xvf $TABLES_BACKUP -C .
rm $TABLES_DIR/$TABLES_BACKUP
chown -R barman:barman $TABLES_DIR
su barman -c "ssh postgres@pgsql.local service postgresql stop"
su barman -c "ssh postgres@pgsql.local rm -rf /var/lib/postgresql/9.3/main/*"
su barman -c "barman recover main --remote-ssh-command='ssh postgres@pgsql.local' $BARMAN_BACKUP_ID /var/lib/postgresql/9.3/main"
su barman -c "ssh postgres@pgsql.local rm /var/lib/postgresql/9.3/main/backup_label"
su barman -c "ssh postgres@pgsql.local /usr/lib/postgresql/9.3/bin/pg_resetxlog -f /var/lib/postgresql/9.3/main"
su barman -c "ssh postgres@pgsql.local service postgresql start"

# Restore files
echo "INFO: Restoring files..."
FILES_DIR="/var/lib/barman/files"
rm -rf $FILES_DIR/*
mv /tmp/$FILES_BACKUP $FILES_DIR
cd $FILES_DIR
tar xvf $FILES_BACKUP -C .
rm $FILES_DIR/$FILES_BACKUP
chown -R barman:barman $FILES_DIR
su barman -c "ssh odoo@odoo.local rm -rf /var/lib/odoo/*"
su barman -c "rsync -az /var/lib/barman/files/ odoo@odoo.local:/var/lib/odoo/"

echo "INFO: Restore completed..."

exit 0
