#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball-m';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database basketball-m\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb basketball-m"
   eval $cmd
fi

psql basketball-m -f loaders/create_ncaa_pbp_schema.sql

cp csv/ncaa_team_schedules_mt.csv /tmp/ncaa_team_schedules.csv
chmod 777 /tmp/ncaa_team_schedules.csv
psql basketball-m -f loaders/load_ncaa_team_schedules.sql
rm /tmp/ncaa_team_schedules.csv

cp csv/ncaa_team_rosters_mt.csv /tmp/ncaa_team_rosters.csv
chmod 777 /tmp/ncaa_team_rosters.csv
psql basketball-m -f loaders/load_ncaa_team_rosters.sql
rm /tmp/ncaa_team_rosters.csv

cp csv/ncaa_games_periods_mt.csv /tmp/ncaa_games_periods.csv
chmod 777 /tmp/ncaa_games_periods.csv
rpl "[" "{" /tmp/ncaa_games_periods.csv
rpl "]" "}" /tmp/ncaa_games_periods.csv
psql basketball-m -f loaders/load_ncaa_games_periods.sql
rm /tmp/ncaa_games_periods.csv

cp csv/ncaa_games_play_by_play_mt.csv /tmp/ncaa_games_play_by_play.csv
chmod 777 /tmp/ncaa_games_play_by_play.csv
psql basketball-m -f loaders/load_ncaa_games_play_by_play.sql
rm /tmp/ncaa_games_play_by_play.csv
