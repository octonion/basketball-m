#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball-m';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb basketball-m;"
   eval $cmd
fi

psql basketball-m -f schema/create_kaggle.sql

cp csv/Teams.csv /tmp/teams.csv
psql basketball-m -f loaders/load_teams.sql
rm /tmp/teams.csv

#psql basketball-m -f schema/create_teams.sql
