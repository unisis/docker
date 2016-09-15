#!/bin/sh

# This script is executed after BarMan perform the archiving of a WAL file.
# See www.postgresql.org/docs/9.3/static/continuous-archiving.html for details.

# We have configured "continuous WAL archiving" (http://docs.pgbarman.org/)
# See http://blog.2ndquadrant.com/management-wal-archive-barman/ for details

# HOWEVER, currently we don't perform any special routine on received wall failes.
# Wal files are not stored in Amazon S3, only complete backups

# Some variables (like BARMAN_FILE) are injected by BarMan.
WAL_FILE=$BARMAN_FILE

exit 0
