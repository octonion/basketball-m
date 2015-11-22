
copy
(
select
game_id,
(
case when opponent_name like '%@%' then opponent_id
      else team_id
end
) as home_team_id,
(
case when opponent_name like '%@%' then team_id
      else opponent_id
end
) as away_team_id,

game_date,
null as wall_clock,

site_name

from ncaa_pbp.team_schedules
where TRUE
and team_id < opponent_id
)

to '/tmp/ncaa_games.csv' csv;
