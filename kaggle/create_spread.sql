begin;

create temporary table teams (
       year		     integer,
       ncaa_id	       	     integer,
       ncaa_name	     text,
       kaggle_id	     integer,
       kaggle_name	     text,
       strength		     float
);

insert into teams
(year,ncaa_id,ncaa_name,kaggle_id,kaggle_name,strength)
(
select
r.year,
r.school_id,
r.school_name,
k.kaggle_id,
k.kaggle_name,
sf.strength
from ncaa.rounds r
join ncaa._schedule_factors sf
  on (sf.year,sf.school_id)=(r.year,r.school_id)
join alias.kaggle k
  on (k.ncaa_id)=(r.school_id)
where
r.year=2021
and r.round_id=3
);

copy
(
select

t1.year::text||'_'||t1.kaggle_id::text||'_'||t2.kaggle_id as id,

--g.school_name as team,
--hd.div_id as h_div,
--'neutral' as site,
--g.opponent_name as opp,
--vd.div_id as v_div,
(exp(i.estimate)*y.exp_factor*hdof.exp_factor*h.offensive*v.defensive*vddf.exp_factor)-
(exp(i.estimate)*y.exp_factor*vdof.exp_factor*v.offensive*hddf.exp_factor*h.defensive) as Pred

from teams t1
join teams t2
  on (t1.kaggle_id < t2.kaggle_id)

join ncaa._schedule_factors h
  on (h.year,h.school_id)=(t1.year,t1.ncaa_id)
join ncaa._schedule_factors v
  on (v.year,v.school_id)=(t2.year,t2.ncaa_id)
  
join ncaa.schools_divisions hd
  on (hd.year,hd.school_id)=(h.year,h.school_id)
  
join ncaa._factors hdof
  on (hdof.parameter,hdof.level::integer)=('o_div',hd.div_id)
join ncaa._factors hddf
  on (hddf.parameter,hddf.level::integer)=('d_div',hd.div_id)
join ncaa.schools_divisions vd
  on (vd.year,vd.school_id)=(v.year,v.school_id)
join ncaa._factors vdof
  on (vdof.parameter,vdof.level::integer)=('o_div',vd.div_id)
join ncaa._factors vddf
  on (vddf.parameter,vddf.level::integer)=('d_div',vd.div_id)
join ncaa._factors y
  on (y.parameter,y.level)=('year',t1.year::text)
join ncaa._basic_factors i
  on (i.factor)=('(Intercept)')

order by t1.kaggle_id asc, t2.kaggle_id asc
) to '/tmp/spread_entry.csv' csv header;

commit;
