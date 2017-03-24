begin;

drop table if exists pinnacle.lines;

create table pinnacle.lines (
	league_id	      integer,
	event_id	      integer,
	date_time	      timestamp,
	period_number	      integer,
	team_id		      integer,
	team_name	      text,
	team_type	      text,
	team_price	      text,
	team_min	      text,
	team_max	      text,
	team_moneyline	      text,
	team_totals	      text,
	team_draw	      text,
	team_pitcher	      text,
	team_red_cards	      text,
	team_score	      integer,
	opponent_id	      integer,
	opponent_name	      text,
	opponent_type	      text,
	opponent_price	      text,
	opponent_min	      text,
	opponent_max	      text,
	opponent_moneyline    text,
	opponent_totals	      text,
	opponent_draw	      text,
	opponent_pitcher      text,
	opponent_red_cards    text,
	opponent_score	      integer
);

copy pinnacle.lines from '/tmp/lines.csv' csv header;

commit;
