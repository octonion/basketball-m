
/*
select *
from
(
select
p.game_id,
p.period,
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
from rails.pbp_clean p
where
    coalesce(p.team_player_id,p.opponent_player_id) is not null
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')
--and p.game_id='1366153'
group by p.game_id,p.period,p.time,player_id
order by p.game_id,p.period,p.time,player_id desc
) same

where enter>1;
*/

select
count(distinct g.game_id)
from
(
select
p.game_id,
p.period,
p.time,
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
from rails.games g
join rails.pbp_clean p
 on p.game_id=g.game_id
where
    coalesce(p.team_player_id,p.opponent_player_id) is not null
group by p.game_id,p.period,p.time
order by p.game_id,p.period,p.time desc
) same
join rails.games g
 on g.game_id=same.game_id
where abs(enter-leave)>0
and g.team_id<g.opponent_id
and 193 in (g.team_id,g.opponent_id);

