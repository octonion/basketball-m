
select
p.game_id,
p.period,
p.time,
coalesce(p.team_player_id,p.opponent_player_id) as player_id,
(
case when coalesce(p.team_event,p.opponent_event)='Enters Game' then 1
     else 0 end
) as enter,
(
case when coalesce(p.team_event,p.opponent_event) not in ('Enters Game','Leaves Game') then 1
     else 0 end
) as other,
(
case when coalesce(p.team_event,p.opponent_event)='Leaves Game' then 1
     else 0 end
) as leave
from rails.pbp_clean p
where
TRUE
--    coalesce(p.team_player_id,p.opponent_player_id) is not null
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')
and p.game_id='1366153'
order by p.game_id,p.period,p.time,player_id desc;
