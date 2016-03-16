#!/bin/bash

HOSTNAME=`hostname`

ssh -o StrictHostKeyChecking=no $VIP "psql -c \"SELECT pg_start_backup('initial_backup');\"" && \
ssh -o StrictHostKeyChecking=no $VIP "rsync -a /var/lib/postgresql/9.5/main/ $HOSTNAME:/var/lib/postgresql/9.5/main/ --exclude  postmaster.pid" && \
ssh -o StrictHostKeyChecking=no $VIP "psql -c \"SELECT pg_stop_backup();\""

# rm /var/lib/pgsql/tmp/PGSQL.lock 

