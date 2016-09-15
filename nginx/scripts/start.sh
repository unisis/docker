#!/bin/bash

################################################################
# Start SSH on foreground, so we can start NginX safely on
# background, and we can easily debug in case we have a problem
if [ ! -d /var/run/sshd ]; then
   mkdir /var/run/sshd
   chmod 0755 /var/run/sshd
fi
/usr/sbin/sshd -D
