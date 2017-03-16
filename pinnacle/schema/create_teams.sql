begin;

drop table if exists pinnacle.teams;

create table pinnacle.teams (
       team_id		    integer,
       team_name	    text,
       primary key (team_id)
);

insert into pinnacle.teams
(team_id,team_name)
(
select team_id,team_name from pinnacle.lines
union
select opponent_id,opponent_name from pinnacle.lines
);

commit;
