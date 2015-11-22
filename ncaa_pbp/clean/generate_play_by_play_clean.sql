begin;

drop table if exists ncaa_pbp.play_by_play_clean;

create table ncaa_pbp.play_by_play_clean (
	game_id		      integer,
	period_id	      integer,
	event_id	      integer,
	time		      interval,
        team_player_id	      integer,
	team_event	      text,
	team_score	      integer,
	opponent_player_id    integer,
	opponent_event	      text,
	opponent_score	      integer,
	id 		      integer,
	unique (game_id,period_id,event_id)
);

-- a small problem with the many-to-one player ID mapping I use
-- for the case of duplicate NCAA rosters IDs

create temporary table ids (
--drop table if exists ids;
--create table ids (
       id	       	   integer, -- primary key,
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

from ncaa_pbp.team_schedules g

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2015)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2015)

join ncaa_pbp.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.team_id,0)
join ncaa_pbp.play_by_play p
 on p.game_id=g.game_id

left join ncaa_pbp.name_mappings tnm
 on (tnm.team_id,tnm.player_name)=(g.team_id,p.team_player)
left join ncaa_pbp.team_rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join ncaa_pbp.name_mappings onm
 on (onm.team_id,onm.player_name)=(g.opponent_id,p.opponent_player)
left join ncaa_pbp.team_rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    TRUE

and sdt.div_id in (1)
and sdo.div_id in (1)
and coalesce(p.team_player,p.opponent_player) is not null
--and 2759 not in (g.team_id,g.opponent_id)
and g.team_id < g.opponent_id
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

union

select

p.id,
tr.id,
opr.id

from ncaa_pbp.team_schedules g

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2015)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2015)

join ncaa_pbp.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.opponent_id,0)
join ncaa_pbp.play_by_play p
 on p.game_id=g.game_id

left join ncaa_pbp.name_mappings tnm
 on (tnm.team_id,tnm.player_name)=(g.opponent_id,p.team_player)
left join ncaa_pbp.team_rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join ncaa_pbp.name_mappings onm
 on (onm.team_id,onm.player_name)=(g.team_id,p.opponent_player)
left join ncaa_pbp.team_rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    TRUE

and sdt.div_id in (1)
and sdo.div_id in (1)
and coalesce(p.team_player,p.opponent_player) is not null
--and 2759 not in (g.team_id,g.opponent_id)
and g.team_id < g.opponent_id
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

union

select

p.id,
tr.id,
opr.id

from ncaa_pbp.team_schedules g

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2015)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2015)

join ncaa_pbp.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.team_id,1)
join ncaa_pbp.play_by_play p
 on p.game_id=g.game_id

left join ncaa_pbp.name_mappings tnm
 on (tnm.team_id,tnm.player_name)=(g.opponent_id,p.team_player)
left join ncaa_pbp.team_rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join ncaa_pbp.name_mappings onm
 on (onm.team_id,onm.player_name)=(g.team_id,p.opponent_player)
left join ncaa_pbp.team_rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    TRUE

and sdt.div_id in (1)
and sdo.div_id in (1)
and coalesce(p.team_player,p.opponent_player) is not null
--and 2759 not in (g.team_id,g.opponent_id)
and g.team_id < g.opponent_id
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

union

select

p.id,
tr.id,
opr.id

from ncaa_pbp.team_schedules g

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2015)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2015)

join ncaa_pbp.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.opponent_id,1)
join ncaa_pbp.play_by_play p
 on p.game_id=g.game_id

left join ncaa_pbp.name_mappings tnm
 on (tnm.team_id,tnm.player_name)=(g.team_id,p.team_player)
left join ncaa_pbp.team_rosters tr
 on (tr.team_id,tr.hashed_name)=(tnm.team_id,tnm.hashed_name)

left join ncaa_pbp.name_mappings onm
 on (onm.team_id,onm.player_name)=(g.opponent_id,p.opponent_player)
left join ncaa_pbp.team_rosters opr
 on (opr.team_id,opr.hashed_name)=(onm.team_id,onm.hashed_name)

where
    TRUE

and sdt.div_id in (1)
and sdo.div_id in (1)
and coalesce(p.team_player,p.opponent_player) is not null
--and 2759 not in (g.team_id,g.opponent_id)
and g.team_id < g.opponent_id
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

);

create index on ids (id);

create index on ncaa_pbp.play_by_play (id);

insert into ncaa_pbp.play_by_play_clean
(game_id,period_id,event_id,time,
 team_player_id,team_event,team_score,
 opponent_player_id,opponent_event,opponent_score)
(
select
p.game_id,p.period_id,p.event_id,p.time,
i.team_player_id,p.team_event,p.team_score,
i.opponent_player_id,p.opponent_event,p.opponent_score
from ncaa_pbp.play_by_play p
join ids i
on (i.id)=(p.id)
);

create index on ncaa_pbp.play_by_play_clean (game_id,period_id,event_id);

create temporary table type (
--drop table if exists type;
--create table type (
	game_id		      integer,
	period_id	      integer,
	time		      interval,
        player_id      	      integer,
	min_event_id	      integer,
	max_event_id	      integer,
	enter		      integer,
	other		      integer,
	leave		      integer
);

insert into type
(game_id,period_id,time,player_id,min_event_id,max_event_id,enter,other,leave)
(
select
game_id,
period_id,
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

from ncaa_pbp.play_by_play_clean
group by game_id,period_id,time,player_id
);

create temporary table reorder (
--drop table if exists reorder;
--create table reorder (
       	game_id		      integer,
	period_id	      integer,
	event_id	      integer,
	id		      integer
);

insert into reorder
(game_id,period_id,event_id,id)
(
select t.game_id,t.period_id,p.event_id,rank()
over
(partition by t.game_id
  order by
    t.period_id asc,t.time desc,(t.enter-t.leave) asc,t.min_event_id asc,
    p.event_id asc)
from ncaa_pbp.play_by_play_clean p
join type t
 on (t.game_id,t.period_id,t.time,coalesce(t.player_id,-1))
   =(p.game_id,p.period_id,p.time,coalesce(coalesce(p.team_player_id,p.opponent_player_id),-1))
);

create index on reorder (game_id,period_id,event_id);

--begin;

update ncaa_pbp.play_by_play_clean
-- w/o space for beginning/end of period
set id=r.id 
-- space for beginning/end of period
--set id=r.id+(r.period-1)*2+1
from reorder r
where (r.game_id,r.period_id,r.event_id)=
      (play_by_play_clean.game_id,play_by_play_clean.period_id,play_by_play_clean.event_id);

--commit;

create index on ncaa_pbp.play_by_play_clean (id);

commit;
