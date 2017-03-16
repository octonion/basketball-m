begin;

drop schema if exists alias cascade;
create schema alias;

drop table if exists alias.teams;

create table alias.teams (
     team_id  	        serial,
     espn_key 	     	text,
     espn_name		text,
     pinnacle_id	integer,
     pinnacle_name	text,
     primary key (team_id)
);

insert into alias.teams
(espn_key,espn_name,pinnacle_id,pinnacle_name)
(
select
e.team_key as espn_key,
e.team_name as espn_name,
p.team_id as pinnacle_id,
p.team_name as pinnacle_name
from espn.teams e
join pinnacle.teams p
on (p.team_name)=(e.team_name)
);

commit;
