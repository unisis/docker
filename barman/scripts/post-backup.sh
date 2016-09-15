#!/bin/sh

# This script is executed after BarMan performs a full backup (also known as "base backup").

# We use this event to make a rsync backup of the Odoo files, compress those files,
# and upload all to Amazon S3 so we are protected against a disk failure.

# Update our local replica/mirror of Odoo data files
rsync -az odoo@odoo.local:/var/lib/odoo/ /var/lib/barman/files

# Save the ID of current backup
BACKUPID_FILE=/tmp/backup_id
echo $BARMAN_BACKUP_ID > $BACKUPID_FILE

# Backup (perform a snapshot of the Odoo data files)
FILES_BACKUP=files.tar.gz
rm -rf /tmp/$FILES_BACKUP
cd /var/lib/barman/files
tar -zcvf /tmp/$FILES_BACKUP *

# Now tar and compress the Postgresql backup
TABLES_BACKUP=tables.tar.gz
rm -rf /tmp/$TABLES_BACKUP
cd $BARMAN_BACKUP_DIR
tar -zcvf /tmp/$TABLES_BACKUP *

# Upload files to Amazon S3
S3_BACKUP_DIR="$S3_BUCKET_BACKUPS/$S3_BACKUPS_DIR/$BARMAN_BACKUP_ID"
s3cmd --config=/var/lib/barman/.s3cfg put /tmp/$FILES_BACKUP s3://$S3_BACKUP_DIR/$FILES_BACKUP
s3cmd --config=/var/lib/barman/.s3cfg put /tmp/$TABLES_BACKUP s3://$S3_BACKUP_DIR/$TABLES_BACKUP

# NOTE: We don't delete temporary files yet,
#       Libelula need them to retrieve their size.
#       They will be deleted during the next backup

exit 0
