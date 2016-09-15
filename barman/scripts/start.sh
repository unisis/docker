#!/bin/bash

# This script only starts the SSH server without initialize
# because we need the PGSQL_HOST variable to initialize. See init.sh

# Start SSH server on foreground (barman is not a server)
if [ ! -d /var/run/sshd ]; then
   mkdir /var/run/sshd
   chmod 0755 /var/run/sshd
fi
/usr/sbin/sshd -D
