begin;

drop table if exists kaggle.teams;

create table kaggle.teams (
	team_id		      integer,
	team_name	      text,
	primary key (team_id)
);

copy kaggle.teams from '/tmp/teams.csv' csv header;

commit;
