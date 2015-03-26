#!/bin/bash

psql basketball-m -f clean/add_ncaa_play_by_play_id.sql

psql basketball-m -f clean/add_ncaa_team_schedules_extra_fields.sql

psql basketball-m -f clean/generate_play_by_play_clean.sql

