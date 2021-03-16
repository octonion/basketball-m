begin;

create temporary table t (
       espn_key	       text,
       espn_name       text,
       pinnacle_id     integer,
       pinnacle_name   text
);

copy t from '/tmp/manual.csv' csv header;

insert into alias.teams
(espn_key,espn_name,pinnacle_id,pinnacle_name)
(
select espn_key,espn_name,pinnacle_id,pinnacle_name
from t
);

commit;
