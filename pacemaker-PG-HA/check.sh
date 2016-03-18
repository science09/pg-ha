#!/bin/bash

docker exec pg1 su postgres -c 'createdb -h 172.28.0.100 test_db'
docker exec pg1 su postgres -c 'psql -h 172.28.0.100 test_db -c "CREATE TABLE test_table (id int, name text)"'
docker exec pg1 su postgres -c 'psql -h 172.28.0.100 test_db -c "INSERT INTO test_table (id) VALUES (1)"'
docker exec pg3 su postgres -c 'psql test_db -c "SELECT * FROM test_table"'


# docker exec pg1 crm_mon -Afr -1
# docker exec pg1 crm resource cleanup msPostgresql
# docker exec pg1 corosync-cfgtool -R
