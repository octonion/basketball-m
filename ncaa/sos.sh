#!/bin/bash

psql basketball-m -f sos/standardized_results.sql

psql basketball-m -c "drop table ncaa._parameter_levels;"
psql basketball-m -c "drop table ncaa._basic_factors;"

psql basketball-m -c "vacuum analyze ncaa.results;"

Rscript sos/lmer.R

psql basketball-m -c "vacuum analyze ncaa._parameter_levels;"
psql basketball-m -c "vacuum analyze ncaa._basic_factors;"

psql basketball-m -f sos/normalize_factors.sql

psql basketball-m -c "vacuum analyze ncaa._factors;"

psql basketball-m -f sos/schedule_factors.sql

psql basketball-m -c "vacuum analyze ncaa._schedule_factors;"

psql basketball-m -f sos/connectivity.sql > sos/connectivity.txt

psql basketball-m -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos/current_ranking.csv
cp /tmp/current_ranking_d1.csv sos/current_ranking_d1.csv

psql basketball-m -f sos/division_ranking.sql > sos/division_ranking.txt

psql basketball-m -f sos/test_predictions.sql > sos/test_predictions.txt

psql basketball-m -f sos/predict_daily.sql > sos/predict_daily.txt
