select * from espn.teams e
full outer join pinnacle.teams p
on (p.team_name)=(e.team_name)
where e.team_key is null or p.team_id is null;
