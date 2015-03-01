#!/bin/bash

psql basketball-m -f sos/standardized_results.sql

psql basketball-m -c "drop table ncaa._geo_basic_factors;"
psql basketball-m -c "drop table ncaa._geo_parameter_levels;"

R --vanilla < sos/geo_lmer.R

psql basketball-m -f sos/geo_normalize_factors.sql
psql basketball-m -f sos/geo_schedule_factors.sql

#psql basketball-m -f sos/connectivity.sql > sos/connectivity.txt
psql basketball-m -f sos/geo_current_ranking.sql > sos/geo_current_ranking.txt
#psql basketball-m -f sos/division_ranking.sql > sos/division_ranking.txt

#psql basketball-m -f sos/test_predictions.sql > sos/test_predictions.txt
