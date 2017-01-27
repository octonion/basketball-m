select
team_name,
avg(split_part(height,'-',1)::float*12+split_part(height,'-',2)::float)::numeric(3,1) as avg_height
from ncaa_pbp.team_rosters
where not(height='-')
and not(height like '4-%')
and year=2017
--and not(height 
group by team_name
order by avg_height desc;
