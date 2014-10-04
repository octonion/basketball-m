begin;

drop table if exists ncaa_pbp.periods;

create table ncaa_pbp.periods (
	game_id		      integer,
	section_id	      integer,
	team_id		      integer,
	team_name	      text,
	team_url	      text,
	period_scores	      integer[]
);

--truncate table ncaa_pbp.periods;

copy ncaa_pbp.periods from '/tmp/ncaa_games_periods.csv' with delimiter as E'\t' csv header;

commit;
