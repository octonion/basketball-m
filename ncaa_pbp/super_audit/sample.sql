begin;

create temporary table first (
       game_id	       	     integer,
       team_id		     integer,
       period		     integer,
       id		     integer,
       time		     text,
       player_id	     integer,
       event		     text
);

insert into first
(game_id,team_id,player_id,period,id)
(
select
g.game_id as game,
(case when p.team_player is not null then g.team_id
      when p.opponent_player is not null then g.opponent_id
end) as team,
coalesce(tr.id,opr.id) as player,
p.period,
min(p.id)

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
--and g.game_id='1366153'
and g.team_name='Duke'
group by game,team,player,period
);

update first
set event=coalesce(p.team_event,p.opponent_event),
    time=p.time
from rails.pbp p
where
    (p.game_id,p.period,p.id)=
    (first.game_id,first.period,first.id)
;

/*
select
game_id,team_id,period,count(*)
from
(select game_id,team_id,period from first
where
(not(event='Enters Game') or ((event,time)=('Enters Game','20:00')))
and not((event,time)=('Leaves Game','20:00'))
order by game_id,team_id,period,event_id
) c
group by game_id,team_id,period;
*/

select * from first
where
(not(event='Enters Game') or ((event,time)=('Enters Game','20:00')))
and not((event,time)=('Leaves Game','20:00'))
and game_id='1497833'
order by game_id,team_id,period,id;

commit;

/*
p.time,

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
and g.game_id='1366153';
--and g.team_name='Duke';
*/
