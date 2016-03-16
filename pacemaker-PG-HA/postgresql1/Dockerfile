FROM localhost:5000/pg:postgresql

MAINTAINER me

USER postgres

ADD postgresql.conf /etc/postgresql/9.5/main/postgresql.conf

RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER myuser WITH SUPERUSER PASSWORD 'mypass';" && \
    createdb -O myuser mydb && \
    psql --command "GRANT ALL PRIVILEGES ON DATABASE mydb to myuser;" && \
    /etc/init.d/postgresql stop

USER root
