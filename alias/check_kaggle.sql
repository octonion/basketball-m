copy
(
select
r.school_id,
r.school_name,
k.team_id,
k.team_name
from kaggle.teams k
right join ncaa.rounds r
  on r.school_name=k.team_name
where r.round_id=3
and k.team_id is null)
to '/tmp/kaggle_missing.csv' csv header;


