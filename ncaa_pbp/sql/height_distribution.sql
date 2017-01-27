select
split_part(height,'-',1)::integer*12+split_part(height,'-',2)::integer as height,
count(*) from ncaa_pbp.team_rosters
where
    not(height='-')
and not(height like '4%')
and not(height='5-1')
and year=2017
group by height order by height;
