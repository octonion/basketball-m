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
pd.game_id,
0 as period,
(case when pd.team_id=sm.home_team_id then 'HT'
      else 'AT' end) as team_id_type,
pd.team_id,
pd.player_id as person_id,
null as jersey,
trim(both from split_part(pd.player_name,',',2)) as first_name,
trim(both from split_part(pd.player_name,',',1)) as last_name,
minutes,fgm,fga,three_fgm,three_fga,ft,fta,offreb,defreb,totreb,
ast,fouls,stl,blk,pts
from rails.schedule_mappings sm
join rails.player_data pd
 on (pd.game_id)=(sm.game_id)
)

to '/tmp/ncaa_player_box.csv' csv header;
