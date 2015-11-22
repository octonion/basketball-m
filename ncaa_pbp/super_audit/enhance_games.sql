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
case when g.opponent_name like '%@%' then g.opponent_id
      else g.team_id
end
) then 'HT'
else 'AT' end
) as team_type,

(case when
p2.team_id=(
case when g.opponent_name like '%@%' then g.opponent_id
      else g.team_id
end
) then 'HT'
else 'AT' end
) as opponent_type,

g.game_id,
(
case when g.opponent_name like '%@%' then g.opponent_id
      else g.team_id
end
) as home_team_id,
(
case when g.opponent_name like '%@%' then g.team_id
      else g.opponent_id
end
) as away_team_id,

g.game_date,
null as wall_clock,

(
case when g.opponent_name like '%@%' then
(
trim(both from split_part(g.opponent_name,'@',1+length(g.opponent_name)-length(replace(g.opponent_name,'@',''))))
)
else trim(both from g.team_name) end
) as site_name

from rails.games g
join rails.periods p1
 on (p1.game_id,p1.section_id)=(g.game_id,1)
join rails.periods p2
 on (p2.game_id,p2.section_id)=(g.game_id,2)
where g.team_id < g.opponent_id
order by g.game_id
);

--alter table rails.games add column team_type text;
--alter table rails.games add column opponent_type text;
--alter table rails.games add column pbp_team_id text;
--alter table rails.games add column pbp_opponent_id text;
alter table rails.games drop column home_team_id;
alter table rails.games drop column away_team_id;
alter table rails.games add column home_team_id integer;
alter table rails.games add column away_team_id integer;

update rails.games
set team_type=ge.team_type,
    opponent_type=ge.opponent_type,
    pbp_team_id=ge.team_id,
    pbp_opponent_id=ge.opponent_id,
    home_team_id=ge.home_team_id,
    away_team_id=ge.away_team_id
from ge
where ge.game_id=games.game_id;

commit;
