--.BOX files
--all we get from here are the team id/team name relationships
--one row per team (two rows total)
--header: GameID, Period, BoxScoreOrder, TPType, TPID, Jersey,
--Name1, Name2, Minutes, FGM, FGA, TPM, TPA, FTM, FTA,
--OffRebound, DefRebound, TotalRebound, Assist, PerFoul, Steal,
--TurnOver, Block, Point

copy
(
select
g.game_id,
0 as period,
g.team_type as team_id_type,
g.team_id,
r.id as person_id,
r.jersey_number as jersey,
trim(both from split_part(r.player_name,',',2)) as first_name,
trim(both from split_part(r.player_name,',',1)) as last_name,
minutes_played,field_goals_made,field_goals_attempted,three_point_field_goals_made,three_point_field_goals_attempted,free_throws,free_throws_attempted,offensive_rebounds,defensive_rebounds,total_rebounds,assists,fouls,steals,blocks,points
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
  on (p.game_id,p.team_id)=(g.game_id,g.team_id)
join ncaa_pbp.box_scores b
  on (b.game_id,b.section_id)=(p.game_id,p.section_id)
join ncaa_pbp.team_rosters r
  on (r.team_id,r.ncaa_id)=(p.team_id,b.player_id)
where g.team_id<g.opponent_id

union

select
g.game_id,
0 as period,
g.opponent_type as team_id_type,
g.opponent_id,
r.id as person_id,
r.jersey_number as jersey,
trim(both from split_part(r.player_name,',',2)) as first_name,
trim(both from split_part(r.player_name,',',1)) as last_name,
minutes_played,field_goals_made,field_goals_attempted,three_point_field_goals_made,three_point_field_goals_attempted,free_throws,free_throws_attempted,offensive_rebounds,defensive_rebounds,total_rebounds,assists,fouls,steals,blocks,points
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
  on (p.game_id,p.team_id)=(g.game_id,g.opponent_id)
join ncaa_pbp.box_scores b
  on (b.game_id,b.section_id)=(p.game_id,p.section_id)
join ncaa_pbp.team_rosters r
  on (r.team_id,r.ncaa_id)=(p.team_id,b.player_id)
where g.team_id<g.opponent_id

)

to '/tmp/ncaa_player_box.csv' csv;
