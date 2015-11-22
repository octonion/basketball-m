#!/bin/bash

cp deleted_games.csv /tmp/deleted_games.csv
psql basketball-m -f delete_games.sql
rm /tmp/deleted_games.csv
