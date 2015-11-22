begin;

-- a small problem with the many-to-one player ID mapping I use
-- for the case of duplicate NCAA rosters IDs

create temporary table ids (
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

-- bad games
--and g.game_id not in (3716444,3790819,3624745,3519236)
--

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

-- bad games
--and g.game_id not in (3716444,3790819,3624745,3519236)
--

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

-- bad games
--and g.game_id not in (3716444,3790819,3624745,3519236)
--

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

-- bad games
--and g.game_id not in (3716444,3790819,3624745,3519236)
--

and sdt.div_id in (1)
and sdo.div_id in (1)
and coalesce(p.team_player,p.opponent_player) is not null
--and 2759 not in (g.team_id,g.opponent_id)
and g.team_id < g.opponent_id
--and not(coalesce(p.team_player,p.opponent_player)='TEAM')

);

create index on ids (id);

create index on ncaa_pbp.play_by_play (id);

select distinct game_id from
(
select 
p.game_id,p.period_id,p.event_id,count(*)
from ncaa_pbp.play_by_play p
join ids i
on (i.id)=(p.id)
group by p.game_id,p.period_id,p.event_id
having count(*)>1)
as bad
order by game_id;

commit;
