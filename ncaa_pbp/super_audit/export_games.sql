
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

trim(both from split_part(opponent_name,'@',1+length(opponent_name)-length(replace(opponent_name,'@','')))) as site_name

from rails.games
)

to '/tmp/ncaa_games.csv' csv header;
