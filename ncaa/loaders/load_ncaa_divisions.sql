begin;

create table ncaa.schools_divisions (
	sport_code		text,
	school_name		text,
	school_id		integer,
	pulled_name		text,
	javascript		text,
	year			integer,
	div_id			integer,
        school_year		text,
	sport			text,
	division		text,
	primary key (school_id,year)
);

copy ncaa.schools_divisions from '/tmp/ncaa_divisions.csv' with delimiter as ',' csv quote as '"';

insert into ncaa.schools_divisions
(sport_code,school_name,school_id,pulled_name,javascript,year,div_id,school_year,sport,division)
(
select sport_code,school_name,school_id,pulled_name,javascript,2017,div_id,school_year,sport,division
from ncaa.schools_divisions
where year=2018
and (school_id,2017) not in
(select school_id,year from ncaa.schools_divisions)
);

insert into ncaa.schools_divisions
(sport_code,school_name,school_id,pulled_name,javascript,year,div_id,school_year,sport,division)
(
select sport_code,school_name,school_id,pulled_name,javascript,2018,div_id,school_year,sport,division
from ncaa.schools_divisions
where year=2019
and (school_id,2018) not in
(select school_id,year from ncaa.schools_divisions)
);

insert into ncaa.schools_divisions
(sport_code,school_name,school_id,pulled_name,javascript,year,div_id,school_year,sport,division)
(
select sport_code,school_name,school_id,pulled_name,javascript,2019,div_id,school_year,sport,division
from ncaa.schools_divisions
where year=2020
and (school_id,2019) not in
(select school_id,year from ncaa.schools_divisions)
);

insert into ncaa.schools_divisions
(sport_code,school_name,school_id,pulled_name,javascript,year,div_id,school_year,sport,division)
(
select sport_code,school_name,school_id,pulled_name,javascript,2020,div_id,school_year,sport,division
from ncaa.schools_divisions
where year=2019
and (school_id,2020) not in
(select school_id,year from ncaa.schools_divisions)
);

insert into ncaa.schools_divisions
(sport_code,school_name,school_id,pulled_name,javascript,year,div_id,school_year,sport,division)
(
select sport_code,school_name,school_id,pulled_name,javascript,2021,div_id,school_year,sport,division
from ncaa.schools_divisions
where year=2020
and (school_id,2021) not in
(select school_id,year from ncaa.schools_divisions)
);

insert into ncaa.schools_divisions
(sport_code,school_name,school_id,pulled_name,javascript,year,div_id,school_year,sport,division)
(
select sport_code,school_name,school_id,pulled_name,javascript,2022,div_id,school_year,sport,division
from ncaa.schools_divisions
where year=2021
and (school_id,2022) not in
(select school_id,year from ncaa.schools_divisions)
);

insert into ncaa.schools_divisions
(sport_code,school_name,school_id,pulled_name,javascript,year,div_id,school_year,sport,division)
(
select sport_code,school_name,school_id,pulled_name,javascript,2023,div_id,school_year,sport,division
from ncaa.schools_divisions
where year=2022
and (school_id,2023) not in
(select school_id,year from ncaa.schools_divisions)
);

/*
create table ncaa.schools_divisions (
	school_id		integer,
	division		text,
	primary key (school_id)
);

copy ncaa.schools_divisions from '/tmp/ncaa_schools_divisions.csv' with delimiter as ',' csv header quote as '"';

alter table ncaa.schools_divisions add column div_id integer;

update ncaa.schools_divisions
set div_id=length(division);
*/

commit;
