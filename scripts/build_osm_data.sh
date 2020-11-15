#!/bin/sh

# https://download.geofabrik.de/index.html
osm_datas="africa-latest.osm.pbf "\
"antarctica-latest.osm.pbf "\
"asia-latest.osm.pbf "\
"australia-oceania-latest.osm.pbf "\
"central-america-latest.osm.pbf "\
"europe-latest.osm.pbf "\
"north-america-latest.osm.pbf "\
"south-america-latest.osm.pbf"
first_data=1
for DATA in $osm_datas
do
cd data && wget https://download.geofabrik.de/$DATA
if first_data -eq 1
then
first_data=0
osm2pgsql -d $PSQL_DBNAME --username $PSQL_USERNAME --host $PSQL_HOST --port $PSQL_PORT --create --slim -G --hstore --tag-transform-script openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes 1 -S openstreetmap-carto/openstreetmap-carto.style data/$DATA
else
osm2pgsql -d $PSQL_DBNAME --username $PSQL_USERNAME --host $PSQL_HOST --port $PSQL_PORT --append --slim -G --hstore --tag-transform-script openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes 1 -S openstreetmap-carto/openstreetmap-carto.style data/$DATA
fi
done

cd openstreetmap-carto && carto project.mml > mapnik.xml