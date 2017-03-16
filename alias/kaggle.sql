begin;

drop table if exists alias.kaggle;

create table alias.kaggle (
     ncaa_id 	     	integer,
     ncaa_name		text,
     kaggle_id		integer,
     kaggle_name	text
);

insert into alias.kaggle
(ncaa_id,ncaa_name,kaggle_id,kaggle_name)
(
select
r.school_id,
r.school_name,
k.team_id,
k.team_name
from kaggle.teams k
join ncaa.rounds r
  on r.school_name=k.team_name
where r.round_id=3
);

commit;
