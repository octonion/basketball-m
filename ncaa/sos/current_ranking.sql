begin;

create temporary table r (
       rk	 serial,
       school 	 text,
       school_id integer,
       div_id	 integer,
       year	 integer,
       str	 numeric(4,3),
--       o_div	 numeric(4,3),
--       d_div	 numeric(4,3),
       ofs	 numeric(4,3),
       dfs	 numeric(4,3),
       sos	 numeric(4,3)
);

insert into r
(school,school_id,div_id,year,str,ofs,dfs,sos)
(
select
coalesce(sd.school_name,sf.school_id::text),
sf.school_id,
sd.div_id as div_id,
sf.year,
(sf.strength*o.exp_factor/d.exp_factor)::numeric(4,3) as str,
--o.exp_factor::numeric(4,3) as o_div,
--d.exp_factor::numeric(4,3) as d_div,
(offensive*o.exp_factor)::numeric(4,3) as ofs,
(defensive*d.exp_factor)::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from ncaa._schedule_factors sf
--join ncaa.schools s
--  on (s.school_id)=(sf.school_id)
join ncaa.schools_divisions sd
--  on (sd.school_id)=(sf.school_id)
  on (sd.school_id,sd.year)=(sf.school_id,sf.year)
join ncaa._factors o
  on (o.parameter,o.level::integer)=('o_div',sd.div_id)
join ncaa._factors d
  on (d.parameter,d.level::integer)=('d_div',sd.div_id)
where sf.year in (2018)
order by (sf.strength*o.exp_factor/d.exp_factor) desc);

select
rk,
school,
'D'||div_id as div,
str,ofs,dfs,sos
from r
order by rk asc;

copy (
select
rk,
school,
'D'||div_id as div,
str,ofs,dfs,sos
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;

create temporary table r_d1 (
       rk	 serial,
       school 	 text,
       school_id integer,
       div_id	 integer,
       year	 integer,
       str	 numeric(4,3),
       ofs	 numeric(4,3),
       dfs	 numeric(4,3),
       sos	 numeric(4,3)
);

insert into r_d1
(school,school_id,div_id,year,str,ofs,dfs,sos)
(
select
school,school_id,div_id,year,str,ofs,dfs,sos
from r
where r.div_id=1
order by str desc
);

select
rk,
school,
'D'||div_id as div,
str,ofs,dfs,sos
from r_d1
order by rk asc;

copy (
select
rk,
school,
'D'||div_id as div,
str,ofs,dfs,sos
from r_d1
order by rk asc
) to '/tmp/current_ranking_d1.csv' csv header;

commit;
