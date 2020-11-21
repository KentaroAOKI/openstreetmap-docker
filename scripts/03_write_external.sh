#!/bin/sh
if test $PSQL_HOST = 'localhost'
then
service postgresql start
service postgresql restart
fi

cd /opt/openstreetmap-carto
python3 scripts/get-external-data.py --force --host $PSQL_HOST --port $PSQL_PORT --username $PSQL_USERNAME --password $PSQL_PASSWORD --database $PSQL_DBNAME

if test $PSQL_HOST = 'localhost'
then
service postgresql stop
fi

