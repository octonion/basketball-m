#!/bin/bash

cp audit/bad_player_names.csv /tmp/bad_player_names.csv
psql basketball-m -f audit/list_bad_games.sql
rm /tmp/bad_player_names.csv
