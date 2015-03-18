select s.team_name as team,avg(t.pt::float) as pt,count(*) as n
from
(select p.team_id,pc.team_value as pt
from ncaa_pbp.periods_cats pc
join ncaa_pbp.periods p
  on (p.game_id,p.section_id)=(pc.game_id,0)
where
    p.team_id is not null
and pc.period_id='1st Half'
and pc.category='Time of Possession'
and pc.team_value::integer+pc.opponent_value::integer=1200
union all
select p.team_id,pc.opponent_value as pt
from ncaa_pbp.periods_cats pc
join ncaa_pbp.periods p
  on (p.game_id,p.section_id)=(pc.game_id,1)
where
    p.team_id is not null
and pc.period_id='1st Half'
and pc.category='Time of Possession'
and pc.team_value::integer+pc.opponent_value::integer=1200)
as t
join ncaa_pbp.teams s
  on (s.team_id)=(t.team_id)
group by team;
