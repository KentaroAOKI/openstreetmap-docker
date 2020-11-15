#!/bin/sh
psql --host=$PSQL_HOST --port=$PSQL_PORT --username=$PSQL_USERNAME --dbname=postgres --password --file=psql/create-gis.sql
