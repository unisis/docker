#!/bin/bash

# This script only starts the SSH service.

# All the initialization is performed on init.sh, invoked
# extenally once the BarMan container is running and we have their IP

# Start SSH server on foreground (so we can track any problem
# on the PostgreSQL server even if it crash)
if [ ! -d /var/run/sshd ]; then
   mkdir /var/run/sshd
   chmod 0755 /var/run/sshd
fi
/usr/sbin/sshd -D
