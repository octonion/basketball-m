#!/bin/bash

cp rounds_updated.csv /tmp/rounds.csv
psql basketball-m -f load_rounds.sql
rm /tmp/rounds.csv

psql basketball-m -f update_round.sql

rpl "round_id=1" "round_id=2" update_round.sql
psql basketball-m -f update_round.sql

rpl "round_id=2" "round_id=3" update_round.sql
psql basketball-m -f update_round.sql

rpl "round_id=3" "round_id=4" update_round.sql
psql basketball-m -f update_round.sql

rpl "round_id=4" "round_id=5" update_round.sql
psql basketball-m -f update_round.sql

rpl "round_id=5" "round_id=6" update_round.sql
psql basketball-m -f update_round.sql

rpl "round_id=6" "round_id=1" update_round.sql

psql basketball-m -f round_p.sql > round_p.txt
cp /tmp/round_p.csv .

psql basketball-m -f champion_p.sql > champion_p.txt
cp /tmp/champion_p.csv .
