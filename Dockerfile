# OpenStreetMap https://switch2osm.org/serving-tiles/manually-building-a-tile-server-18-04-lts/
FROM ubuntu:18.04
# postgresql connection settings
ENV PSQL_HOST=postgresql
ENV PSQL_PORT=5432
ENV PSQL_USERNAME=postgres
ENV PSQL_PASSWORD=postgrespassword
ENV PSQL_DBNAME=gis
# Installing packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository multiverse
RUN apt update
RUN apt install -y libboost-all-dev git-core tar unzip wget bzip2 build-essential autoconf libtool libxml2-dev libgeos-dev libgeos++-dev libpq-dev libbz2-dev libproj-dev munin-node munin libprotobuf-c0-dev protobuf-c-compiler libfreetype6-dev libtiff5-dev libicu-dev libgdal-dev libcairo-dev libcairomm-1.0-dev apache2 apache2-dev libagg-dev liblua5.2-dev ttf-unifont lua5.1 liblua5.1-dev libgeotiff-epsg
WORKDIR /opt
# Installing postgresql / postgis
RUN apt install -y postgresql postgresql-contrib postgis postgresql-10-postgis-2.4 postgresql-10-postgis-scripts
# RUN echo $PSQL_HOST:$PSQL_PORT:postgres:$PSQL_USERNAME:$PSQL_PASSWORD > ~/.pgpass
# RUN echo $PSQL_HOST:$PSQL_PORT:$PSQL_DBNAME:$PSQL_USERNAME:$PSQL_PASSWORD >> ~/.pgpass
# RUN chmod 600 ~/.pgpass
RUN mkdir psql
COPY psql/create-gis.sql psql/
# RUN psql --host=$PSQL_HOST --port=$PSQL_PORT --username=$PSQL_USERNAME --dbname=postgres --password --file=psql/create-gis.sql
# Installing osm2pgsql
RUN apt install -y make cmake g++ libboost-dev libboost-system-dev libboost-filesystem-dev libexpat1-dev zlib1g-dev libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev lua5.2 liblua5.2-dev
RUN apt install -y clang-tidy postgresql-server-dev-10 pandoc
RUN apt-get install -y autoconf apache2-dev libtool libxml2-dev libbz2-dev libgeos-dev libgeos++-dev libproj-dev gdal-bin libmapnik-dev mapnik-utils python-mapnik python3-psycopg2
RUN git clone https://github.com/openstreetmap/osm2pgsql.git \
    && cd osm2pgsql && git checkout refs/tags/1.3.0
RUN cd osm2pgsql && mkdir build && cd build && cmake .. && make && make install
# Mapnik
RUN apt-get install autoconf apache2-dev libtool libxml2-dev libbz2-dev libgeos-dev libgeos++-dev libproj-dev gdal-bin libmapnik-dev mapnik-utils python-mapnik python3-psycopg2
# Install mod_tile and renderd
RUN git clone -b switch2osm https://github.com/SomeoneElseOSM/mod_tile.git \
    && cd mod_tile && git checkout e25bfdba1c1f2103c69529f1a30b22a14ce311f1
# RUN git clone https://github.com/openstreetmap/mod_tile.git \
#     && cd mod_tile && git checkout a3f4230df6bc320b3b564ab20a29b57f787dbfe4
RUN cd mod_tile && ./autogen.sh && ./configure && make && make install && make install-mod_tile && ldconfig
# Stylesheet configuration
RUN apt-get install -y nodejs-dev node-gyp libssl1.0-dev
RUN apt install -y npm nodejs
RUN git clone https://github.com/gravitystorm/openstreetmap-carto.git \
    && cd openstreetmap-carto && git checkout b10aef3866bacf387581b8fea4eec265010b0d14
COPY openstreetmap-carto/project.mml.tmplate openstreetmap-carto/
RUN cd openstreetmap-carto && npm install -g carto && carto -v
# RUN sed -e 's/PSQL_HOST/'$PSQL_HOST'/' -e 's/PSQL_PORT/'$PSQL_PORT'/' -e 's/PSQL_USERNAME/'$PSQL_USERNAME'/' -e 's/PSQL_PASSWORD/'$PSQL_PASSWORD'/' -e 's/PSQL_DBNAME/'$PSQL_DBNAME'/' openstreetmap-carto/project.mml.tmplate > openstreetmap-carto/project.mml
# RUN cd openstreetmap-carto && carto project.mml > mapnik.xml
# Loading data
RUN mkdir data
# RUN cd data && wget https://download.geofabrik.de/asia/japan-latest.osm.pbf
# RUN osm2pgsql -d $PSQL_DBNAME --username $PSQL_USERNAME --host $PSQL_HOST --port $PSQL_PORT --create --slim -G --hstore --tag-transform-script openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes 1 -S openstreetmap-carto/openstreetmap-carto.style data/japan-latest.osm.pbf
# Loading data - Shapefile download
RUN apt install -y python-yaml python-requests python-psycopg2
RUN apt install -y python3-yaml python3-requests python3-psycopg2
COPY openstreetmap-carto/scripts/get-external-data.py openstreetmap-carto/scripts/
# RUN cd openstreetmap-carto && python3 scripts/get-external-data.py --host $PSQL_HOST --port $PSQL_PORT --username $PSQL_USERNAME --password $PSQL_PASSWORD --database gis
# Loading data - Fonts
RUN apt-get install -y fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted ttf-unifont
# Setting up your webserver for switch2osm
RUN mv /usr/local/etc/renderd.conf /usr/local/etc/_renderd.conf
RUN sed 's/\/home\/renderaccount\/src/\/opt/' /usr/local/etc/_renderd.conf > /usr/local/etc/renderd.conf
# Configuring Apache
RUN mkdir /var/lib/mod_tile
RUN mkdir /var/run/renderd && chmod 777 /var/run/renderd
RUN echo LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so > /etc/apache2/conf-available/mod_tile.conf
RUN a2enconf mod_tile
RUN sed -e 's/DocumentRoot \/var\/www\/html/LoadTileConfigFile \/usr\/local\/etc\/renderd.conf\n\tModTileRenderdSocketName \/var\/run\/renderd\/renderd.sock\n\tModTileRequestTimeout 0\n\tModTileMissingRequestTimeout 60\n\tDocumentRoot \/var\/www\/html/' /etc/apache2/sites-available/000-default.conf > /tmp/000-default.conf
RUN cp /tmp/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN sed -e 's/http:\/\/127.0.0.1//' mod_tile/extra/sample_leaflet.html > /var/www/html/sample_leaflet.html
RUN apt install -y sudo
COPY scripts scripts
