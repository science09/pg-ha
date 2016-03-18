#!/bin/bash

#while ! ssh pg1 "psql -c \"SELECT pg_start_backup('initial_backup');\""; do
#    echo 'waiting for pg1 to be ready'
#    sleep 3
#done

ssh pg1 "rsync -a /var/lib/postgresql/9.5/main/ `hostname`:/var/lib/postgresql/9.5/main/ --exclude  postmaster.pid"
#ssh pg1 "psql -c \"SELECT pg_stop_backup();\""
