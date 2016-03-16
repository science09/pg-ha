FROM localhost:5000/debian:stretch

MAINTAINER me

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt-get update && \
  apt-get install -y wget postgresql postgresql-contrib postgresql-client
#  echo 'deb http://apt.postgresql.org/pub/repos/apt jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list  && \
#  wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
#  apt-get update && apt-get install -y postgresql-9.5=9.5.1-1.pgdg80+1 postgresql-contrib-9.5=9.5.1-1.pgdg80+1 postgresql-client-9.5=9.5.1-1.pgdg80+1


RUN sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && dpkg-reconfigure --frontend=noninteractive locales && update-locale LANG=en_GB.UTF-8

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf

RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

RUN apt-get install -y rsync openssh-client openssh-server bind9-host corosync pacemaker vim less man tcpdump crmsh

RUN sed -i 's/^UsePAM.\+$/UsePAM no/' /etc/ssh/sshd_config

RUN apt-get clean && apt-get autoclean && apt-get autoremove

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

RUN mkdir -p /var/lib/postgresql/9.5/main/archive

USER root

EXPOSE 22
EXPOSE 5432
EXPOSE 5405/udp

CMD /usr/sbin/start.sh
