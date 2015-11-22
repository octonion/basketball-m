--TP files
--rosters for the game
--one row per player
--header: GameID, TeamIdType, TeamID, PersonIDType, PersonID,
--Jersey, ShortName, FirstName, LastName, Status

copy
(
select
sm.game_id as game_id,
(case when spd.team_id=sm.home_team_id then 'HT'
      else 'AT' end) as team_id_type,
spd.team_id as team_id,
(case when spd.team_id=sm.home_team_id then 'HP'
      else 'AP' end) as team_id_type,
spd.player_id as person_id,
spd.jersey as jersey,
trim(both from split_part(spd.player_name,',',2)) as short_name,
trim(both from split_part(spd.player_name,',',2)) as first_name,
trim(both from split_part(spd.player_name,',',1)) as last_name,
'A' as status
from rails.schedule_mappings sm
--join rails.player_data pd
-- on (pd.team_id)=(sm.team_id)
join rails.summary_player_data spd
 on ((spd.team_id) in (sm.home_team_id,sm.away_team_id))
)

to '/tmp/ncaa_game_rosters.csv' csv header;
