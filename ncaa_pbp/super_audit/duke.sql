select
g.game_id,
(case when p.team_player is not null then g.team_id
      when p.opponent_player is not null then g.opponent_id
end) as team,
p.period,
p.event_id,
p.time,
coalesce(tr.id,opr.id) as id,
--coalesce(p.team_player,p.opponent_player) as player_name,
coalesce(p.team_event,p.opponent_event) as event
from rails.games g
join rails.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.team_id,1)
join rails.pbp p
 on p.game_id=g.game_id

left join rails.name_mappings tnm
 on (tnm.team_id,tnm.player_name)=(g.team_id,p.team_player)
left join rails.rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join rails.name_mappings onm
 on (onm.team_id,onm.player_name)=(g.opponent_id,p.opponent_player)
left join rails.rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    g.team_id < g.opponent_id
and coalesce(p.team_player,p.opponent_player) is not null
and not(coalesce(p.team_player,p.opponent_player)='TEAM')
--and g.game_id='1366153';
--and g.team_name='Duke';
