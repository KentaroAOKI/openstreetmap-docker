# OpenStreetMap Tile Server

The Dockerfile that builds an OpenStreetMap tile server. The image contains a map of Antarctica. If you want to import a map of another region, use external PostgreSQL.

## Build
```
git clone https://github.com/KentaroAOKI/openstreetmap-docker.git
cd openstreetmap-docker
docker build -t openstreetmaptile .
```

## Usage
Specify the port to bind to and start it.
```
docker run -d -p 80:80 openstreetmaptile
```
You can access the following URL with a web browser. If this is your first time, it will take some time for the map to appear.
```
http://xxx/sample_leaflet.html
```

## How to use an external PostgreSQL database
By connecting to an external PostgreSQL, you will be able to use large map data.
Use environment variables to specify the external PostgreSQL.
- PSQL_HOST is PostgreSQL host name. (default is "localhost")
- PSQL_PORT is PostgreSQL port number. (default is "5432")
- PSQL_USERNAME PostgreSQL login user. (default is "postgres")
- PSQL_PASSWORD PostgreSQL login password. (default is "postgrespassword")
- PSQL_DBNAME Database name to build the map. (default is "gis")

### 1. Create a database
Creates the specified database.
```
docker run -ti -e PSQL_HOST=xxxx.postgres.database.azure.com -e PSQL_USERNAME=xxx@xxx -e PSQL_PASSWORD=xxxx openstreetmaptile scripts/01_initialize_database.sh
```

### 2. Write the open street map data to the database.
Write the map data of Antarctica to the database. If you want to write map data of other areas, please specify in "osm_datas" of "scripts/02_write_osm.sh". When writing multiple items at once, set them separated by spaces.
```
docker run -ti -e PSQL_HOST=xxxx.postgres.database.azure.com -e PSQL_USERNAME=xxx@xxx -e PSQL_PASSWORD=xxxx openstreetmaptile scripts/02_write_osm.sh
```

### 3. Write the external data to the database.
```
docker run -ti -e PSQL_HOST=xxxx.postgres.database.azure.com -e PSQL_USERNAME=xxx@xxx -e PSQL_PASSWORD=xxxx openstreetmaptile scripts/03_write_external.sh
```

### 4. Start the open street map tile server.
You also specify environment variables when you start the tile server.
```
docker run -d -p 80:80 -e PSQL_HOST=xxxx.postgres.database.azure.com -e PSQL_USERNAME=xxx@xxx -e PSQL_PASSWORD=xxxx openstreetmaptile
```
If you reuse the created tile images, it is better to mount the file system as follows.
```
docker run -d -p 80:80 -e PSQL_HOST=xxxx.postgres.database.azure.com -v /home/user/mod_tile:/var/lib/mod_tile openstreetmaptile
```
If you use PostgreSQL on the host, you may start it as follows.
```
docker run -d -p 80:80 --add-host postgresql:`ifconfig eth0 | grep "inet " | awk '{print $2}'` -e PSQL_HOST=postgresql -v /home/user/mod_tile:/var/lib/mod_tile openstreetmaptile
```

## How to speed up the startup of the OpenStreetMap tile server.
In this Docker image, the startup script is created assuming that the PostgreSQL connection information will be changed. If the PostgreSQL connection information does not change, change the Dockerfile to run "scripts/04_make_mapnik.sh" when building the Docker image. Change the PostgreSQL connection information in the Dockerfile as well. And then, Please comment out "/opt/scripts/04_make_mapnik.sh" from "scripts/05_make_mapnik.sh".