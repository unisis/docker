#!/bin/bash

# Configure Supervisord file
TEMPLATE_FILE=/root/supervisord.conf
CONFIG_FILE=/etc/supervisor/conf.d/supervisord.conf
cp $TEMPLATE_FILE $CONFIG_FILE
sed -i $CONFIG_FILE -e s,{AEROO_PORT},$AEROO_PORT,g

# Start supervisord
supervisord -c /etc/supervisor/conf.d/supervisord.conf
