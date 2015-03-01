#!/bin/bash

psql basketball-m -f mapping/rosters_remove_duplicates.sql

cp mapping/team_rosters_missing.csv /tmp/team_rosters_missing.csv
psql basketball-m -f mapping/rosters_manually_load_missing.sql
rm /tmp/team_rosters_missing.csv

psql basketball-m -f mapping/rosters_create_name_mappings.sql

./mapping/rosters_create_name_hashes.rb

cp mapping/team_rosters_remaps.csv /tmp/team_rosters_remaps.csv
psql basketball-m -f mapping/rosters_manually_update_remaps.sql
rm /tmp/team_rosters_remaps.csv

# Requires the PostgreSQL Levenshtein functionfound in the contributed
# fuzzystrmatch module

# To install:
# apt-get install postgresql-contrib
# CREATE EXTENSION fuzzystrmatch;

psql basketball-m -f mapping/rosters_compute_levenshtein_distances.sql
