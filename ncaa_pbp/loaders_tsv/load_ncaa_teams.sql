begin;

drop table if exists ncaa_pbp.teams;

create table ncaa_pbp.teams (
	year		      integer,
	year_id		      integer,
	team_id		      integer,
        team_name	      text,
	team_url	      text,
	primary key (year_id,team_id)
);

copy ncaa_pbp.teams from '/tmp/ncaa_teams.tsv' with delimiter as E'\t' csv;

commit;
