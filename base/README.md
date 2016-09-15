# Unisis base image (Ubuntu with Dnsmasq and common utilities)

Usage (test):

1) sudo docker run -i -t --dns=127.0.0.1 unisis/base /bin/bash (we will enter to the container)

2) set-host pgsql.local 172.17.0.5

3) list-hosts

4) ping pgsql.local



