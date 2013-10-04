#! /bin/sh

SCRIPTPATH=$(dirname $0)

sudo -u postgres psql -c 'DROP DATABASE IF EXISTS test;'
sudo -u postgres psql -c 'CREATE DATABASE test;'
sudo -u postgres psql -c "ALTER USER postgres password '1234';"
sudo -u postgres psql -d test -a -f $SCRIPTPATH/pg-init.sql

