
select
*
from
(
select
p.game_id,
p.period_id,
p.time,
coalesce(p.team_player_id,p.opponent_player_id) as player_id,
sum(
case when coalesce(p.team_event,p.opponent_event)='Enters Game' then 1
     else 0 end
) as enter,
sum(
case when coalesce(p.team_event,p.opponent_event) not in ('Enters Game','Leaves Game') then 1
     else 0 end
) as other,
sum(
case when coalesce(p.team_event,p.opponent_event)='Leaves Game' then 1
     else 0 end
) as leave,
count(*)
from ncaa_pbp.play_by_play_clean p
where
    coalesce(p.team_player_id,p.opponent_player_id) is not null
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')
--and p.game_id='1366153'
group by p.game_id,p.period_id,p.time,player_id
order by p.game_id,p.period_id,p.time,player_id desc
) same

where abs(enter-leave)>1;
--where enter>1 or leave>1 or enter+leave>1;
