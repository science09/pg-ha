#!/bin/bash

/etc/init.d/ssh start

for node in $NODES; do
    while ! grep "^$node " /var/lib/postgresql/.ssh/known_hosts > /dev/null 2>&1; do
        /usr/bin/ssh-keyscan $node >> /var/lib/postgresql/.ssh/known_hosts
        sleep 1
    done
done

chown postgres:postgres /var/lib/postgresql/.ssh/known_hosts


[ "$ROLE" = "SLAVE" ] && echo "COPY POSTGRESQL DATA" && su postgres -c 'bash /usr/sbin/repl_init.sh'

/usr/sbin/ha.sh

#su -c '/usr/lib/postgresql/9.5/bin/postgres -D /var/lib/postgresql/9.5/main -c config_file=/etc/postgresql/9.5/main/postgresql.conf' postgres

while :; do
    sleep 10
done
