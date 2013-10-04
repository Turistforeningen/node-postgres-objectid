#! /bin/sh

SCRIPTPATH=$(dirname $0)

psql -U postgres -w -c 'DROP DATABASE IF EXISTS test;'
psql -U postgres -w -c 'CREATE DATABASE test;'
psql -U postgres -w -d test -a -f $SCRIPTPATH/pg-init.sql

