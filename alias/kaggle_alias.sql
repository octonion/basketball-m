select
k.team_name,
r.school_name
from kaggle.teams k
right join ncaa.rounds r
  on r.school_name=k.team_name
where r.round_id=3;
