## run
docker-compose up

## cluster with 1xMASTER and 2xSLAVES

docker exec pg2 crm_mon -Afr -1
Last updated: Fri Mar 18 09:50:39 2016		Last change: Fri Mar 18 09:50:29 2016 by root via crm_attribute on pg1
Stack: corosync
Current DC: pg3 (version 1.1.14-70404b0) - partition with quorum
3 nodes and 7 resources configured

Online: [ pg1 pg2 pg3 ]

Full list of resources:

 Clone Set: clnPingCheck [pingCheck]
     Started: [ pg1 pg2 pg3 ]
 Master/Slave Set: msPostgresql [pgsql]
     Masters: [ pg1 ]
     Slaves: [ pg2 pg3 ]
 Resource Group: master-group
     vip-rep	(ocf::heartbeat:IPaddr2):	Started pg1

Node Attributes:
* Node pg1:
    + default_ping_set                	: 300       
    + master-pgsql                    	: 1000      
    + pgsql-data-status               	: LATEST    
    + pgsql-master-baseline           	: 0000000002000098
    + pgsql-status                    	: PRI       
* Node pg2:
    + default_ping_set                	: 300       
    + master-pgsql                    	: 100       
    + pgsql-data-status               	: STREAMING|SYNC
    + pgsql-status                    	: HS:sync   
* Node pg3:
    + default_ping_set                	: 300       
    + master-pgsql                    	: -INFINITY 
    + pgsql-data-status               	: STREAMING|ASYNC
    + pgsql-status                    	: HS:async  

Migration Summary:
* Node pg1:
* Node pg2:
* Node pg3:

## simulate MASTER failure

- kill master
docker exec pg1 sh -c 'kill `cat /var/run/postgresql/9.5-main.pid`'

- check status after couple of seconds
docker exec pg1 crm_mon -Afr -1
Last updated: Fri Mar 18 09:52:30 2016		Last change: Fri Mar 18 09:52:22 2016 by root via crm_attribute on pg2
Stack: corosync
Current DC: pg3 (version 1.1.14-70404b0) - partition with quorum
3 nodes and 7 resources configured

Online: [ pg1 pg2 pg3 ]

Full list of resources:

 Clone Set: clnPingCheck [pingCheck]
     Started: [ pg1 pg2 pg3 ]
 Master/Slave Set: msPostgresql [pgsql]
     Masters: [ pg2 ]
     Slaves: [ pg3 ]
     Stopped: [ pg1 ]
 Resource Group: master-group
     vip-rep	(ocf::heartbeat:IPaddr2):	Started pg2

Node Attributes:
* Node pg1:
    + default_ping_set                	: 300       
    + master-pgsql                    	: -INFINITY 
    + pgsql-data-status               	: DISCONNECT
    + pgsql-status                    	: STOP      
* Node pg2:
    + default_ping_set                	: 300       
    + master-pgsql                    	: 1000      
    + pgsql-data-status               	: LATEST    
    + pgsql-master-baseline           	: 0000000003000098
    + pgsql-status                    	: PRI       
* Node pg3:
    + default_ping_set                	: 300       
    + master-pgsql                    	: 100       
    + pgsql-data-status               	: STREAMING|SYNC
    + pgsql-status                    	: HS:sync   

Migration Summary:
* Node pg1:
   pgsql: migration-threshold=1 fail-count=1 last-failure='Fri Mar 18 09:52:06 2016'
* Node pg2:
* Node pg3:

Failed Actions:
* pgsql_monitor_3000 on pg1 'unknown error' (1): call=26, status=complete, exitreason='none',
    last-rc-change='Fri Mar 18 09:52:06 2016', queued=0ms, exec=0ms

## restore pg1

- restore DB
docker exec pg1 su postgres -c /usr/sbin/repl_restore.sh
Warning: Permanently added '172.28.0.100' (ECDSA) to the list of known hosts.
 pg_start_backup 
-----------------
 0/4000060
(1 row)

NOTICE:  pg_stop_backup complete, all required WAL segments have been archived
 pg_stop_backup 
----------------
 0/4000130
(1 row)

- remove lock
docker exec pg1 rm /var/lib/pgsql/tmp/PGSQL.lock

- refresh pacemaker
docker exec pg1 crm resource cleanup msPostgresql
Waiting for 3 replies from the CRMd... OK
Cleaning up pgsql:0 on pg1, removing fail-count-pgsql
Cleaning up pgsql:0 on pg2, removing fail-count-pgsql
Cleaning up pgsql:0 on pg3, removing fail-count-pgsql

- check status after a while
docker exec pg1 crm_mon -Afr -1
Last updated: Fri Mar 18 10:02:14 2016		Last change: Fri Mar 18 10:02:07 2016 by root via crm_attribute on pg2
Stack: corosync
Current DC: pg3 (version 1.1.14-70404b0) - partition with quorum
3 nodes and 7 resources configured

Online: [ pg1 pg2 pg3 ]

Full list of resources:

 Clone Set: clnPingCheck [pingCheck]
     Started: [ pg1 pg2 pg3 ]
 Master/Slave Set: msPostgresql [pgsql]
     Masters: [ pg2 ]
     Slaves: [ pg1 pg3 ]
 Resource Group: master-group
     vip-rep	(ocf::heartbeat:IPaddr2):	Started pg2

Node Attributes:
* Node pg1:
    + default_ping_set                	: 300       
    + master-pgsql                    	: -INFINITY 
    + pgsql-data-status               	: STREAMING|ASYNC
    + pgsql-status                    	: HS:async  
* Node pg2:
    + default_ping_set                	: 300       
    + master-pgsql                    	: 1000      
    + pgsql-data-status               	: LATEST    
    + pgsql-master-baseline           	: 0000000003000098
    + pgsql-status                    	: PRI       
* Node pg3:
    + default_ping_set                	: 300       
    + master-pgsql                    	: 100       
    + pgsql-data-status               	: STREAMING|SYNC
    + pgsql-status                    	: HS:sync   
    + pgsql-xlog-loc                  	: 0000000005000060

Migration Summary:
* Node pg1:
* Node pg2:
* Node pg3:

