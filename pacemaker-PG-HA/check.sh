#!/bin/bash

docker exec postgresql1 su postgres -c 'createdb -h 172.28.0.100 test_db'
docker exec postgresql1 su postgres -c 'psql -h 172.28.0.100 test_db -c "CREATE TABLE test_table (id int, name text)"'
docker exec postgresql1 su postgres -c 'psql -h 172.28.0.100 test_db -c "INSERT INTO test_table (id) VALUES (1)"'
docker exec postgresql3 su postgres -c 'psql test_db -c "SELECT * FROM test_table"'


# docker exec postgresql1 crm_mon -Afr -1
# docker exec postgresql1 crm resource cleanup msPostgresql
# docker exec postgresql1 corosync-cfgtool -R
