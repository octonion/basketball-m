begin;

drop table if exists rails.pbp_clean;

create table rails.pbp_clean (
	game_id		      integer,
	period		      integer,
	event_id	      integer,
	time		      interval,
        team_player_id	      integer,
	team_event	      text,
	team_score	      integer,
	opponent_player_id    integer,
	opponent_event	      text,
	opponent_score	      integer,
	unique (game_id,period,event_id)
);

-- a small problem with the many-to-one player ID mapping I use
-- for the case of duplicate NCAA rosters IDs

create temporary table ids (
       id	       	   integer primary key,
       team_player_id  	   integer,
       opponent_player_id  integer
);

insert into ids
(id,team_player_id,opponent_player_id)
(
select

p.id,
tr.id,
opr.id

from rails.games g

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2013)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2013)

join rails.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.team_id,1)
join rails.pbp p
 on p.game_id=g.game_id

left join rails.lev_mapping tnm
 on (tnm.team_id,tnm.player_name)=(g.team_id,p.team_player)
left join rails.rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join rails.lev_mapping onm
 on (onm.team_id,onm.player_name)=(g.opponent_id,p.opponent_player)
left join rails.rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    TRUE
and sdt.div_id=1
and sdo.div_id=1
and coalesce(p.team_player,p.opponent_player) is not null
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

union

select

p.id,
tr.id,
opr.id

from rails.games g

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2013)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2013)

join rails.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.opponent_id,1)
join rails.pbp p
 on p.game_id=g.game_id

left join rails.lev_mapping tnm
 on (tnm.team_id,tnm.player_name)=(g.opponent_id,p.team_player)
left join rails.rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join rails.lev_mapping onm
 on (onm.team_id,onm.player_name)=(g.team_id,p.opponent_player)
left join rails.rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    TRUE
and sdt.div_id=1
and sdo.div_id=1
and coalesce(p.team_player,p.opponent_player) is not null
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

union

select

p.id,
tr.id,
opr.id

from rails.games g

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2013)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2013)

join rails.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.team_id,2)
join rails.pbp p
 on p.game_id=g.game_id

left join rails.lev_mapping tnm
 on (tnm.team_id,tnm.player_name)=(g.opponent_id,p.team_player)
left join rails.rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join rails.lev_mapping onm
 on (onm.team_id,onm.player_name)=(g.team_id,p.opponent_player)
left join rails.rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    TRUE
and sdt.div_id=1
and sdo.div_id=1
and coalesce(p.team_player,p.opponent_player) is not null
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

union

select

p.id,
tr.id,
opr.id

from rails.games g

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2013)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2013)

join rails.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.opponent_id,2)
join rails.pbp p
 on p.game_id=g.game_id

left join rails.lev_mapping tnm
 on (tnm.team_id,tnm.player_name)=(g.team_id,p.team_player)
left join rails.rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join rails.lev_mapping onm
 on (onm.team_id,onm.player_name)=(g.opponent_id,p.opponent_player)
left join rails.rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    TRUE
and sdt.div_id=1
and sdo.div_id=1
and coalesce(p.team_player,p.opponent_player) is not null
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

);

insert into rails.pbp_clean
(game_id,period,event_id,time,
 team_player_id,team_event,team_score,
 opponent_player_id,opponent_event,opponent_score)
(
select
p.game_id,p.period,p.event_id,p.time,
i.team_player_id,p.team_event,p.team_score,
i.opponent_player_id,p.opponent_event,p.opponent_score
from rails.pbp p
join ids i
on (i.id)=(p.id)
);

create temporary table type (
	game_id		      integer,
	period		      integer,
	time		      interval,
        player_id      	      integer,
	min_event_id	      integer,
	max_event_id	      integer,
	enter		      integer,
	other		      integer,
	leave		      integer
);

insert into type
(game_id,period,time,player_id,min_event_id,max_event_id,enter,other,leave)
(
select
game_id,
period,
time,
coalesce(team_player_id,opponent_player_id) as player_id,
min(event_id) as min_event_id,
max(event_id) as max_event_id,
sum(
case when coalesce(team_event,opponent_event)='Enters Game' then 1
     else 0 end
) as enter,
sum(
case when coalesce(team_event,opponent_event) not in ('Enters Game','Leaves Game') then 1
     else 0 end
) as other,
sum(
case when coalesce(team_event,opponent_event)='Leaves Game' then 1
     else 0 end
) as leave

from rails.pbp_clean
group by game_id,period,time,player_id
);

create temporary table reorder (
       	game_id		      integer,
	period		      integer,
	event_id	      integer,
	id		      integer
);

insert into reorder
(game_id,period,event_id,id)
(
select t.game_id,t.period,p.event_id,rank()
over
(partition by t.game_id
  order by
    t.period asc,t.time desc,(t.enter-t.leave) asc,t.min_event_id asc,
    p.event_id asc)
from rails.pbp_clean p
join type t
 on (t.game_id,t.period,t.time,coalesce(t.player_id,-1))
   =(p.game_id,p.period,p.time,coalesce(coalesce(p.team_player_id,p.opponent_player_id),-1))
);

alter table rails.pbp_clean add column id integer;

update rails.pbp_clean
-- w/o space for beginning/end of period
set id=r.id 
-- space for beginning/end of period
--set id=r.id+(r.period-1)*2+1
from reorder r
where (r.game_id,r.period,r.event_id)=
      (pbp_clean.game_id,pbp_clean.period,pbp_clean.event_id);

create index on rails.pbp_clean (id);

commit;
