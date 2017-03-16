begin;

drop table if exists espn.teams;

create table espn.teams (
       team_key		    text,
       team_name	    text,
       primary key (team_key)
);

insert into espn.teams
(team_key,team_name)
(
select away_abbr,away_name from espn.predictions
union
select home_abbr,home_name from espn.predictions
);

commit;
