#!/bin/bash

################################################################
# Start SSH on foreground, used for BarMan to copy Odoo files
# using rsync. And it's better run SSH on foreground (and not
# Odoo to keep the container alive and debug if Odoo can't start)
if [ ! -d /var/run/sshd ]; then
   mkdir /var/run/sshd
   chmod 0755 /var/run/sshd
fi
/usr/sbin/sshd -D
