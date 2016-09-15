#!/bin/bash

# Make postgres owner of the data directory (their volume
# is provided by the postgres-data container).
CLUSTER_VERSION=9.3
CLUSTER_NAME=main
CLUSTER_DATADIR=/var/lib/postgresql/$CLUSTER_VERSION/$CLUSTER_NAME
CLUSTER_CONFIGDIR=/etc/postgresql/$CLUSTER_VERSION/$CLUSTER_NAME

# Postgresql command
START_CMD="/usr/lib/postgresql/9.3/bin/postgres"

# Postgresql arguments
START_ARGS="--config-file=/etc/postgresql/9.3/main/postgresql.conf"

# If PG_VERSION file doesn't exists, the cluster should be initialized
if [ ! -e $CLUSTER_DATADIR/PG_VERSION ]; then
    # On Ubuntu/Debian, pg_createcluster is the high level wrapper for initdb
    # Data directory defaults to /var/lib/postgresql/<version>/<cluster>
    pg_dropcluster   $CLUSTER_VERSION $CLUSTER_NAME 2>/dev/null
    pg_createcluster $CLUSTER_VERSION $CLUSTER_NAME

    # Assign right ownership and permissions to cluster data
    chown -R postgres:root $CLUSTER_DATADIR
    chmod -R 0700 $CLUSTER_DATADIR

    # Configure pg_hba.conf
    TEMPLATE_FILE=/root/pg_hba.conf
    CONFIG_FILE=$CLUSTER_CONFIGDIR/pg_hba.conf
    cp $TEMPLATE_FILE $CONFIG_FILE
    chown postgres:postgres $CONFIG_FILE

    # Configure postgresql.conf (including connection to BarMan)
    TEMPLATE_FILE=/root/postgresql.conf
    CONFIG_FILE=$CLUSTER_CONFIGDIR/postgresql.conf
    cp $TEMPLATE_FILE $CONFIG_FILE

    if [ "$IS_TEST" == 1 ]; then
        LOG_STATEMENT="all"
        LOG_DESTINATION="csvlog"
        LOGGING_COLLECTOR="on"
        LOG_ROTATION_AGE="0"
        LOG_ROTATION_SIZE="0"
    else
        LOG_STATEMENT="none"
        LOG_DESTINATION="stderr"
        LOGGING_COLLECTOR="off"
        LOG_ROTATION_AGE="1d"
        LOG_ROTATION_SIZE="100MB"
    fi

    sed -i $CONFIG_FILE -e s,{PGSQL_PORT},$PGSQL_PORT,g
    sed -i $CONFIG_FILE -e s,{LOG_STATEMENT},$LOG_STATEMENT,g
    sed -i $CONFIG_FILE -e s,{LOG_DESTINATION},$LOG_DESTINATION,g
    sed -i $CONFIG_FILE -e s,{LOGGING_COLLECTOR},$LOGGING_COLLECTOR,g
    sed -i $CONFIG_FILE -e s,{LOG_ROTATION_AGE},$LOG_ROTATION_AGE,g
    sed -i $CONFIG_FILE -e s,{LOG_ROTATION_SIZE},$LOG_ROTATION_SIZE,g

    chown postgres:postgres $CONFIG_FILE

    # Start Postgres to change their admin password
    service postgresql start

    # Change postgres (server admin user) password
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$DB_PWD'";

    # Configure charset of "template" databases to use UTF8, for details see
    # https://techjourney.net/install-odoo-8-openerp-in-centos-red-hat-enterprise-linux/
    /bin/su postgres -c "psql -c \"update pg_database set encoding = 6, datcollate = 'C.UTF-8', datctype = 'C.UTF-8' where datname = 'template0'\""
    /bin/su postgres -c "psql -c \"update pg_database set encoding = 6, datcollate = 'C.UTF-8', datctype = 'C.UTF-8' where datname = 'template1'\""

    # Create the database and user using the postgres user on the postgres container
    # We just create one database per master PostgreSQL server. Although this approach
    # adds an extra resource consumption, it's good idea because RepMgr is able to
    # replicate an entire *server* (not a specific database), so separating databases
    # on their own servers, we have more flexibility regarding replication and backup
    # policy (and it's easier and faster restore a database that restore all databases
    # at the same time, even if we just want restore one specific database)
    /bin/su postgres -c "createuser $DB_USER"
    /bin/su postgres -c "createdb --owner $DB_USER $DB_NAME"
    /bin/su postgres -c "psql -c \"ALTER USER $DB_USER with password '$DB_PWD';\" "

    # Stop postgresql again
    service postgresql stop
fi

# Copy SSH config file to not have strict host checking for Postgres
TEMPLATE_FILE=/root/ssh_config
CONFIG_FILE=/var/lib/postgresql/.ssh/config
cp $TEMPLATE_FILE $CONFIG_FILE

# Assign permissions to mounted volumes
chown -R postgres:postgres /var/lib/postgresql
chown -R postgres:postgres /var/log/postgresql

chmod -R 700 /var/lib/postgresql
chmod -R 744 /var/log/postgresql

# Externally, SSH keys were mounted into home directory of user postgres
# at /var/lib/postgresql/.ssh, configure permissions here for private key
chmod 600 /var/lib/postgresql/.ssh/id_rsa

# We must start the Postgresql server using the postgres user.
# Otherwise, Postgresql refuse to start due security reasons.
su postgres -c "nohup $START_CMD $START_ARGS &"

exit 0
