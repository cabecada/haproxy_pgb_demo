#!/bin/bash

$setup
initdb -D db1
echo 'port=5432' >> db1/postgresql.conf
pg_basebackup -D db2 -R -c fast -C -S db3 -d "port=5432"
echo 'port=5433' >> db2/postgresql.conf
pg_basebackup -D db3 -R -c fast -C -S db3 -d "port=5432"
echo 'port=5434' >> db2/postgresql.conf

pg_ctl -D db1 -l db1.log start
pg_ctl -D db2 -l db2.log start
pg_ctl -D db3 -l db3.log start

# start pgb
pgbouncer -u postgres -d pgbouncer/db1.ini
pgbouncer -u postgres -d pgbouncer/db2.ini
pgbouncer -u postgres -d pgbouncer/db3.ini


#setup xinetd
cp xinetd/checkscripts/pgsqlchk* /opt/
cp xinetd/conf.d/* /etc/xinetd.d/

# for xinetd
echo '
pgsqlchk1 23267/tcp # pgsqlchk1
pgsqlchk2 23268/tcp # pgsqlchk2
pgsqlchk3 23269/tcp # pgsqlchk2
' >> /etc/services 

#setup haproxy
cp haproxy/haproxy.cfg /etc/haproxy/


systemctl restart xinetd
systemctl restart haproxy


psql -p 8001 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'
psql -p 8002 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'
psql -p 8003 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'

psql -p 5001 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'
psql -p 5002 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'
psql -p 5003 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'


psql -p 5432 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'
psql -p 5433 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'
psql -p 5434 -h 127.0.0.1 -d postgres -U postgres -c 'select 1'


#tests 
