begin;

drop table if exists kaggle.sharps;

create table kaggle.sharps (
	entry		      integer,
	win_id		      integer,
	win_name	      text,
	lose_id		      integer,
	lose_name	      text
);

copy kaggle.sharps from '/tmp/sharps.csv' csv header;

commit;
