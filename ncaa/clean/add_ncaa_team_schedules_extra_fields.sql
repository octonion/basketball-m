begin;

create temporary table ge (
       team_id 	       integer,
       opponent_id     integer,
       team_type       text,
       opponent_type   text,
       game_id	       integer,
       home_team_id    integer,
       away_team_id    integer,
       game_date       date,
       wall_clock      text,
       site_name       text
);

insert into ge
(team_id,opponent_id,team_type,opponent_type,game_id,home_team_id,away_team_id,game_date,wall_clock,site_name)
(
select
p1.team_id as team_id,
p2.team_id as opponent_id,

(case when
p1.team_id=(
case when g.game_string like '%@%' then g.opponent_id
      else g.team_id
end
) then 'HT'
else 'AT' end
) as team_type,

(case when
p2.team_id=(
case when g.game_string like '%@%' then g.opponent_id
      else g.team_id
end
) then 'HT'
else 'AT' end
) as opponent_type,

g.game_id,
(
case when g.game_string like '%@%' then g.opponent_id
      else g.team_id
end
) as home_team_id,
(
case when g.game_string like '%@%' then g.team_id
      else g.opponent_id
end
) as away_team_id,

g.game_date,
null as wall_clock,

-- This needs to be checked and possibly improved

(
case when g.opponent_name like '%@%' then
(
trim(both from split_part(g.opponent_name,'@',1+length(g.opponent_name)-length(replace(g.opponent_name,'@',''))))
)
else trim(both from g.team_name) end
) as site_name

--(
--case when g.game_string like '%@%' then g.opponent_name
--     else g.team_name end
--) as site_name

from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p1
 on (p1.game_id,p1.section_id)=(g.game_id,0)
join ncaa_pbp.periods p2
 on (p2.game_id,p2.section_id)=(g.game_id,1)
where g.team_id < g.opponent_id
order by g.game_id
);

alter table ncaa_pbp.team_schedules drop column if exists team_type;
alter table ncaa_pbp.team_schedules drop column if exists opponent_type;
alter table ncaa_pbp.team_schedules drop column if exists pbp_team_id;
alter table ncaa_pbp.team_schedules drop column if exists pbp_opponent_id;
alter table ncaa_pbp.team_schedules drop column if exists home_team_id;
alter table ncaa_pbp.team_schedules drop column if exists away_team_id;
alter table ncaa_pbp.team_schedules drop column if exists site_name;

alter table ncaa_pbp.team_schedules add column team_type text;
alter table ncaa_pbp.team_schedules add column opponent_type text;
alter table ncaa_pbp.team_schedules add column pbp_team_id text;
alter table ncaa_pbp.team_schedules add column pbp_opponent_id text;
alter table ncaa_pbp.team_schedules add column home_team_id integer;
alter table ncaa_pbp.team_schedules add column away_team_id integer;
alter table ncaa_pbp.team_schedules add column site_name text;

update ncaa_pbp.team_schedules
set team_type=ge.team_type,
    opponent_type=ge.opponent_type,
    pbp_team_id=ge.team_id,
    pbp_opponent_id=ge.opponent_id,
    home_team_id=ge.home_team_id,
    away_team_id=ge.away_team_id,
    site_name=ge.site_name
from ge
where ge.game_id=team_schedules.game_id;

commit;
