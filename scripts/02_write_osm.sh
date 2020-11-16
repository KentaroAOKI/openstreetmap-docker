#!/bin/sh
# https://download.geofabrik.de/index.html
osm_datas="asia/japan-latest.osm.pbf"

if test $PSQL_HOST = 'localhost'
then
service postgresql start
service postgresql restart
fi

first_data=1
for DATA in $osm_datas
do
cd /opt/data
wget https://download.geofabrik.de/$DATA
cd /opt
FILE=`basename $DATA`
if test $first_data -eq 1
then
first_data=0
osm2pgsql -d $PSQL_DBNAME --username $PSQL_USERNAME --host $PSQL_HOST --port $PSQL_PORT --create --slim -G --hstore --tag-transform-script openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes 1 -S openstreetmap-carto/openstreetmap-carto.style data/$FILE
else
osm2pgsql -d $PSQL_DBNAME --username $PSQL_USERNAME --host $PSQL_HOST --port $PSQL_PORT --append --slim -G --hstore --tag-transform-script openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes 1 -S openstreetmap-carto/openstreetmap-carto.style data/$FILE
fi
rm /opt/data/$FILE
done

cd /opt/openstreetmap-carto
python3 scripts/get-external-data.py --host $PSQL_HOST --port $PSQL_PORT --username $PSQL_USERNAME --password $PSQL_PASSWORD --database $PSQL_DBNAME

if test $PSQL_HOST = 'localhost'
then
service postgresql stop
fi

