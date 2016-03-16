crm configure property \
     stonith-enabled="false" \
     expected-quorum-votes="2" \
     crmd-transition-delay="0s"
 
crm configure rsc_defaults \
     resource-stickiness="INFINITY" \
     migration-threshold="1"

crm configure primitive pingCheck ocf:pacemaker:ping \
    params \
        name="default_ping_set" \
        host_list="$NODES" \
        multiplier="100"\
    op start   timeout="180s" interval="0"  on-fail="restart" \
    op monitor timeout="180s" interval="10s" on-fail="restart" \
    op stop    timeout="180s" interval="0"  on-fail="ignore"

crm configure clone clnPingCheck pingCheck

crm configure primitive vip-rep ocf:heartbeat:IPaddr2 \
     params \
         ip="$VIP" \
         nic="eth0" \
         cidr_netmask="24" \
     meta \
             migration-threshold="0" \
     op start   timeout="60s" interval="0s"  on-fail="restart" \
     op monitor timeout="60s" interval="10s" on-fail="restart" \
     op stop    timeout="60s" interval="0s"  on-fail="block"
 
crm configure primitive pgsql ocf:heartbeat:pgsql \
     params \
         pgctl="/usr/lib/postgresql/9.5/bin/pg_ctl" \
         psql="/usr/bin/psql" \
         pgdata="/var/lib/postgresql/9.5/main/" \
         config="/etc/postgresql/9.5/main/postgresql.conf" \
         start_opt="-p 5432" \
         rep_mode="sync" \
         node_list="$NODES" \
         restore_command="cp -f /var/lib/postgresql/9.5/main/archive/%f %p </dev/null" \
         primary_conninfo_opt="keepalives_idle=60 keepalives_interval=5 keepalives_count=5" \
         master_ip="$VIP" \
         restart_on_promote="true" \
     op start   timeout="180s" interval="0s"  on-fail="restart" \
     op monitor timeout="180s" interval="4s" on-fail="restart" \
     op monitor timeout="180s" interval="3s"  on-fail="restart" role="Master" \
     op promote timeout="180s" interval="0s"  on-fail="restart" \
     op demote  timeout="180s" interval="0s"  on-fail="stop" \
     op stop    timeout="180s" interval="0s"  on-fail="block" \
     op notify  timeout="180s" interval="0s"
 
crm configure ms msPostgresql pgsql \
     meta \
         master-max="1" \
         master-node-max="1" \
         clone-max="3" \
         clone-node-max="1" \
         notify="true"

crm configure group master-group \
       vip-rep
 
crm configure colocation rsc_colocation-1 inf: master-group msPostgresql:Master
crm configure order rsc_order-1 0: msPostgresql:promote  master-group:start  symmetrical=false
crm configure order rsc_order-2 0: msPostgresql:demote   master-group:stop   symmetrical=false
