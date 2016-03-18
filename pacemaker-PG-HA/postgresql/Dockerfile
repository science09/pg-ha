FROM localhost:5000/debian:stretch

MAINTAINER me

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt-get update && \
  apt-get install -y wget postgresql postgresql-contrib postgresql-client

RUN apt-get update && \
  apt-get install -y rsync openssh-client openssh-server bind9-host corosync pacemaker vim less man tcpdump crmsh


RUN apt-get clean && apt-get autoclean && apt-get autoremove

RUN sed -i 's/^UsePAM.\+$/UsePAM no/' /etc/ssh/sshd_config

ADD start.sh /usr/sbin/start.sh

ADD repl_init.sh /usr/sbin/repl_init.sh
ADD repl_restore.sh /usr/sbin/repl_restore.sh

ADD ha.sh /usr/sbin/ha.sh
ADD config_crm.sh /usr/sbin/config_crm.sh

USER postgres

RUN \
  ssh-keygen -t rsa -f /var/lib/postgresql/.ssh/id_rsa -q -N "" && \
  cp /var/lib/postgresql/.ssh/id_rsa.pub /var/lib/postgresql/.ssh/authorized_keys && \
  chmod go= /var/lib/postgresql/.ssh/authorized_keys

ADD pg_hba.conf /etc/postgresql/9.5/main/pg_hba.conf

ADD postgresql.conf /etc/postgresql/9.5/main/postgresql.conf

RUN mkdir -p /var/lib/postgresql/9.5/main/archive

RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER myuser WITH SUPERUSER PASSWORD 'mypass';" && \
    createdb -O myuser mydb && \
    psql --command "GRANT ALL PRIVILEGES ON DATABASE mydb to myuser;" && \
    /etc/init.d/postgresql stop

USER root

EXPOSE 22
EXPOSE 5432
EXPOSE 5405/udp

CMD /usr/sbin/start.sh
