#/bin/sh
cd /opt
sed -e 's/PSQL_HOST/'$PSQL_HOST'/' -e 's/PSQL_PORT/'$PSQL_PORT'/' -e 's/PSQL_USERNAME/'$PSQL_USERNAME'/' -e 's/PSQL_PASSWORD/'$PSQL_PASSWORD'/' -e 's/PSQL_DBNAME/'$PSQL_DBNAME'/' openstreetmap-carto/project.mml.tmplate > openstreetmap-carto/project.mml
cd openstreetmap-carto
carto project.mml > mapnik.xml
