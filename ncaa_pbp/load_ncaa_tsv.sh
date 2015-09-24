#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball-m';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb basketball-m"
   eval $cmd
fi

psql basketball-m -f loaders_tsv/create_ncaa_pbp_schema.sql

tail -q -n+2 tsv/ncaa_teams_*.tsv >> /tmp/ncaa_teams.tsv
psql basketball-m -f loaders_tsv/load_ncaa_teams.sql
rm /tmp/ncaa_teams.tsv

tail -q -n+2 tsv/ncaa_team_schedules_mt_*.tsv >> /tmp/ncaa_team_schedules.tsv
psql basketball-m -f loaders_tsv/load_ncaa_team_schedules.sql
rm /tmp/ncaa_team_schedules.tsv

cp tsv/ncaa_games_box_scores_mt_*.tsv.gz /tmp
pigz -d /tmp/ncaa_games_box_scores_mt_*.tsv.gz
tail -q -n+2 /tmp/ncaa_games_box_scores_mt_*.tsv >> /tmp/ncaa_games_box_scores.tsv
psql basketball-m -f loaders_tsv/load_ncaa_box_scores.sql
rm /tmp/ncaa_games_box_scores*.tsv

tail -q -n+2 tsv/ncaa_team_rosters_mt_*.tsv >> /tmp/ncaa_team_rosters.tsv
psql basketball-m -f loaders_tsv/load_ncaa_team_rosters.sql
rm /tmp/ncaa_team_rosters.tsv

tail -q -n+2 tsv/ncaa_games_periods_mt_*.tsv >> /tmp/ncaa_games_periods.tsv
rpl "[" "{" /tmp/ncaa_games_periods.tsv
rpl "]" "}" /tmp/ncaa_games_periods.tsv
psql basketball-m -f loaders_tsv/load_ncaa_games_periods.sql
rm /tmp/ncaa_games_periods.tsv

cp tsv/ncaa_games_play_by_play_mt_*.tsv.gz /tmp
pigz -d /tmp/ncaa_games_play_by_play_mt_*.tsv.gz
tail -q -n+2 /tmp/ncaa_games_play_by_play_mt_*.tsv >> /tmp/ncaa_games_play_by_play.tsv
psql basketball-m -f loaders_tsv/load_ncaa_games_play_by_play.sql
rm /tmp/ncaa_games_play_by_play*.tsv

exit
