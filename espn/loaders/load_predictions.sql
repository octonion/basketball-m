begin;

drop table if exists espn.predictions;

create table espn.predictions (
	game_date	      date,
	date_time	      timestamp,
	away_name	      text,
	away_abbr	      text,
	away_score	      integer,
	away_pred_diff	      text,
	away_win_prob	      text,
	matchup_quality	      text,
	away_game_score	      text,
	home_name	      text,
	home_abbr	      text,
	home_score	      integer,
	home_pred_diff	      text,
	home_win_prob	      text,
	home_game_score	      text
);

copy espn.predictions from '/tmp/predictions.csv' csv header;

commit;
