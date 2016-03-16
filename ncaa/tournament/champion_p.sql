begin;

select
school_name,p::numeric(5,4)
from ncaa.rounds
where round_id=8
order by p desc;

copy
(
select
school_name,p::numeric(5,4)
from ncaa.rounds
where round_id=8
order by p desc
) to '/tmp/champion_p.csv' csv header;

commit;
