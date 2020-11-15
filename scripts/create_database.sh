#!/bin/sh -x
if test $PSQL_HOST = 'localhost'
then
sed -e 's/#listen_addresses/listen_addresses/' /etc/postgresql/10/main/postgresql.conf > /tmp/postgresql.conf
cp /tmp/postgresql.conf /etc/postgresql/10/main/postgresql.conf
service postgresql start
service postgresql restart
sleep 1
sudo -u postgres psql postgres --command="CREATE DATABASE $PSQL_DBNAME ENCODING = UTF8;"
sudo -u postgres psql $PSQL_DBNAME --command="CREATE EXTENSION postgis;"
sudo -u postgres psql $PSQL_DBNAME --command="CREATE EXTENSION hstore;"
sudo -u postgres psql $PSQL_DBNAME --command="ALTER USER $PSQL_USERNAME WITH PASSWORD '$PSQL_PASSWORD';"
service postgresql stop
else
psql --host=$PSQL_HOST --port=$PSQL_PORT --username=$PSQL_USERNAME --dbname=postgres --password --command="CREATE DATABASE $PSQL_DBNAME ENCODING = UTF8;"
psql --host=$PSQL_HOST --port=$PSQL_PORT --username=$PSQL_USERNAME --dbname=$PSQL_DBNAME --password --command="CREATE EXTENSION postgis;"
psql --host=$PSQL_HOST --port=$PSQL_PORT --username=$PSQL_USERNAME --dbname=$PSQL_DBNAME --password --command="CREATE EXTENSION hstore;"
fi