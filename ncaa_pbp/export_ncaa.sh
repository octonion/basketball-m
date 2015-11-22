#!/bin/bash

#cd export

psql basketball-m -f export/export_box_scores.sql
psql basketball-m -f export/export_events.sql
psql basketball-m -f export/export_game_rosters.sql
psql basketball-m -f export/export_games.sql
psql basketball-m -f export/export_starters.sql

cp -f /tmp/ncaa_*.csv .
rm /tmp/ncaa_*.csv
#unix2dos ncaa_*.csv
#rm -f ncaa_2015.zip
#zip ncaa_2015.zip ncaa_*.csv
