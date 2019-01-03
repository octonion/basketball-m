begin;

drop table if exists ncaa.rounds;

create table ncaa.rounds (
	region				integer,
	year				integer,
	round_id			integer,
	school_id			integer,
	school_name			text,
	bracket				int[],
	p				float,
	primary key (year,round_id,school_id)
);

copy ncaa.rounds from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

commit;
