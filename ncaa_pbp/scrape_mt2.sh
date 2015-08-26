#!/bin/bash

./scrapers2/ncaa_teams.rb

./scrapers2/ncaa_team_rosters_mt.rb

./scrapers2/ncaa_summaries_mt.rb

./scrapers2/ncaa_team_schedules_mt.rb

./scrapers2/ncaa_periods_stats_mt.rb &

./scrapers2/ncaa_team_box_scores_mt.rb &

./scrapers2/ncaa_play_by_play_mt.rb &
