#!/bin/sh -x

echo $PSQL_HOST:$PSQL_PORT:postgres:$PSQL_USERNAME:$PSQL_PASSWORD > ~/.pgpass
echo $PSQL_HOST:$PSQL_PORT:$PSQL_DBNAME:$PSQL_USERNAME:$PSQL_PASSWORD >> ~/.pgpass
chmod 600 ~/.pgpass

for DATA in $@
do
cd /tmp
wget https://download.geofabrik.de/$DATA
FILE=`basename $DATA`
cd /opt
osm2pgsql -d $PSQL_DBNAME --username $PSQL_USERNAME --host $PSQL_HOST --port $PSQL_PORT --append --slim -G --hstore --tag-transform-script openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes 1 -S openstreetmap-carto/openstreetmap-carto.style /tmp/$FILE
rm /tmp/$FILE
done

