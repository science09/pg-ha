#!/bin/bash

cat<<EOF >/etc/corosync/corosync.conf
quorum {
    provider: corosync_votequorum
    expected_votes: 2
}
aisexec {
    user: root
    group: root
}
service {
    name: pacemaker
    ver: 1
}
totem {
    version: 2
    secauth: off
    transport: udpu
    cluster_name: docker
    interface {
        ringnumber: 0
        bindnetaddr: `ip -f inet addr show eth0 |tail -2 | sed -e "s/^[^0-9]\+//" | sed -e "s/\/.\+$//"`
    }
}
logging {
    to_logfile: yes
    logfile: /var/log/corosync.log
}
nodelist {
EOF

for node in $NODES; do
cat<<EOF >>/etc/corosync/corosync.conf
    node {
        ring0_addr: `host -t a $node | cut -f 4 -d ' '`
    }
EOF
done

cat<<EOF >>/etc/corosync/corosync.conf
}
EOF

/usr/sbin/corosync -p

nohup /usr/sbin/pacemakerd -V &

while ! crm_mon -Afr -1 >/dev/null 2>&1; do
    sleep 3
done

#sleep 10

[ "$ROLE" = "MASTER" ] && bash /usr/sbin/config_crm.sh
