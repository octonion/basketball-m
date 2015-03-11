begin;

drop table if exists ncaa_pbp.periods_stats;

create table ncaa_pbp.periods_stats (
	game_id		      integer,
	period_id	      text,
	section_id	      integer,
	team_name	      text,
	fgm		      integer,
	fga		      integer,
	tpfg		      integer,
	tpfga		      integer,
	ft		      integer,
	fta		      integer,
	pts		      integer,
	orebs		      integer,
	drebs		      integer,
	totrebs		      integer,
	ast		      integer,
	tovers		      integer,
	stl		      integer,
	blk		      integer,
	fouls		      integer,
	dq		      integer,
	primary key (game_id, period_id, section_id)
);

copy ncaa_pbp.periods_stats from '/tmp/ncaa_games_periods_stats.csv' with delimiter as E'\t' csv header;

commit;
