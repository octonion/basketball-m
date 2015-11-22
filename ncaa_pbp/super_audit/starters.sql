begin;

create temporary table first (
       game_id	       	     integer,
       team_id		     integer,
       period		     integer,
       time		     text,
       player_id	     integer,
       event		     text,
       id	     	     integer
);

insert into first
(game_id,team_id,period,player_id,id)
(
select
g.game_id as game,
(case when p.team_event is not null then g.team_id
      when p.opponent_event is not null then g.opponent_id
end) as team,
p.period,
coalesce(p.team_player_id,p.opponent_player_id) as player,
min(p.id)

from rails.games g
join rails.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.team_id,1)
join rails.pbp_clean p
 on (p.game_id)=(g.game_id)

where
TRUE
and coalesce(p.team_player_id,p.opponent_player_id) is not null
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')
--and g.game_id='1366153'
and g.team_name='Duke'

and not((coalesce(p.team_event,p.opponent_event),p.time)=
         ('Enters Game','20:00'))
and not((coalesce(p.team_event,p.opponent_event),p.time)=
        ('Leaves Game','20:00'))

/*
and (not(coalesce(p.team_event,p.opponent_event)='Enters Game') or
        ((coalesce(p.team_event,p.opponent_event),p.time)=
         ('Enters Game','20:00')))
and not((coalesce(p.team_event,p.opponent_event),p.time)=
        ('Leaves Game','20:00'))
*/

group by game,team,period,player
);

update first
set event=coalesce(p.team_event,p.opponent_event),
    time=p.time
from rails.pbp_clean p
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
order by game_id,team_id,period,id
) c
group by game_id,team_id,period;
*/

select * from first
where
(not(event='Enters Game') or ((event,time)=('Enters Game','20:00')))
and not((event,time)=('Leaves Game','20:00'))
--and game_id='1497833'
--and game_id=1560720
--and game_id=1870092
and game_id=1686018
order by game_id,team_id,period,id;

commit;
