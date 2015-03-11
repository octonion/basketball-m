begin;

drop table if exists ncaa_pbp.periods_cats;

create table ncaa_pbp.periods_cats (
	game_id		      integer,
	period_id	      text,
	category	      text,
	team_value	      text,
	opponent_value	      text,
	primary key (game_id, period_id, category)
);

copy ncaa_pbp.periods_cats from '/tmp/ncaa_games_periods_cats.csv' with delimiter as E'\t' csv header;

commit;
