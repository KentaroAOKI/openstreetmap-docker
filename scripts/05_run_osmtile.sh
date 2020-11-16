#!/bin/sh
if test $PSQL_HOST = 'localhost'
then
service postgresql start
fi
service apache2 start
renderd -f -c /usr/local/etc/renderd.conf
