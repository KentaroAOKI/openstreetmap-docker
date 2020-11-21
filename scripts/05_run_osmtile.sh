#!/bin/bash

# Update the PostgreSQL connection information.
/opt/scripts/04_make_mapnik.sh

# Start the postgresql process
if test $PSQL_HOST = 'localhost'; then
  service postgresql start
  status=$?
  if [ $status -ne 0 ]; then
    echo "Failed to start postgresql: $status"
    exit $status
  fi
fi

# Start the apache2 process
service apache2 start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start apache2: $status"
  exit $status
fi

# Start the renderd process
renderd -c /usr/local/etc/renderd.conf
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start renderd: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 10 seconds

while sleep 10; do
  if test $PSQL_HOST = 'localhost'; then
    ps aux |grep postgresql |grep -q -v grep
    POSTGRESQL_STATUS=$?
  else
    POSTGRESQL_STATUS=0
  fi
  ps aux |grep apache2 |grep -q -v grep
  APACHE2_STATUS=$?
  ps aux |grep renderd |grep -q -v grep
  RENDERD_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $POSTGRESQL_STATUS -ne 0 -o $APACHE2_STATUS -ne 0 -o $RENDERD_STATUS -ne 0 ]; then
   echo "One of the processes has already exited."
   exit 1
  fi
done
fi