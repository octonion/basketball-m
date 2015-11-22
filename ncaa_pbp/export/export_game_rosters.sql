--TP files
--rosters for the game
--one row per player
--header: GameID, TeamIdType, TeamID, PersonIDType, PersonID,
--Jersey, ShortName, FirstName, LastName, Status

copy
(
select
g.game_id as game_id,
g.team_type as team_id_type,
g.team_id as team_id,
(case when g.team_type='HT' then 'HP'
      else 'AP' end) as person_id_type,
r.id as person_id,
r.jersey_number as jersey,
trim(both from split_part(r.player_name,',',2)) as short_name,
trim(both from split_part(r.player_name,',',2)) as first_name,
trim(both from split_part(r.player_name,',',1)) as last_name,
'A' as status
from ncaa_pbp.team_schedules g
join ncaa_pbp.team_rosters r
  on (r.team_id)=(g.team_id)
where g.team_id<g.opponent_id

union

select
g.game_id as game_id,
g.opponent_type as team_id_type,
g.opponent_id as team_id,
(case when g.opponent_type='HT' then 'HP'
      else 'AP' end) as person_id_type,
r.id as person_id,
r.jersey_number as jersey,
trim(both from split_part(r.player_name,',',2)) as short_name,
trim(both from split_part(r.player_name,',',2)) as first_name,
trim(both from split_part(r.player_name,',',1)) as last_name,
'A' as status
from ncaa_pbp.team_schedules g
join ncaa_pbp.team_rosters r
  on (r.team_id)=(g.opponent_id)
where g.team_id<g.opponent_id
)

to '/tmp/ncaa_game_rosters.csv' csv;
