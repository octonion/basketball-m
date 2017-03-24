begin;

create temporary table kelly (
       game_date		date,
       team_name		text,
       team_predicted_p		float,
       team_moneyline		text,
       team_implied_p		float,
       team_kelly		float,
       opponent_name		text,
       opponent_predicted_p	float,
       opponent_moneyline	text,
       opponent_implied_p	float,
       opponent_kelly		float
);

insert into kelly
(
game_date,
team_name,team_predicted_p,team_moneyline,
opponent_name,opponent_predicted_p,opponent_moneyline)
(
select
p.game_date,
p.home_name as team_name,
coalesce((p.home_win_prob::float)/100.0,1.0-(p.away_win_prob::float)/100.0) as team_predicted_p,
(case when t2.pinnacle_name=l.team_name then l.team_moneyline
      when t2.pinnacle_name=l.opponent_name then l.opponent_moneyline
      else null
end) as team_moneyline,
p.away_name as opponent_name,
coalesce((p.away_win_prob::float)/100.0,1.0-(p.home_win_prob::float)/100.0) as opponent_predicted_p,
(case when t1.pinnacle_name=l.team_name then l.team_moneyline
      when t1.pinnacle_name=l.opponent_name then l.opponent_moneyline
      else null
end) as opponent_moneyline
from
espn.predictions p
join alias.teams t1
on (t1.espn_key)=(p.away_abbr)
join alias.teams t2
on (t2.espn_key)=(p.home_abbr)
join pinnacle.lines l
on (
   (l.team_name,l.opponent_name)=(t1.pinnacle_name,t2.pinnacle_name)
or (l.team_name,l.opponent_name)=(t2.pinnacle_name,t1.pinnacle_name)
)
where p.game_date>='03/23/2017'::date
and l.period_number=0
);

--set team_kelly=((1/team_implied_p-1)*team_predicted_p-(1-team_predicted_p))/(1/team_implied_p)

update kelly
set
team_implied_p=
(case when team_moneyline::float < 0 then
        -(team_moneyline::float)/(-(team_moneyline::float)+100.0)
      when team_moneyline::float > 0 then
        100.0/(team_moneyline::float+100.0)
end),
opponent_implied_p=
(case when opponent_moneyline::float < 0 then
        -(opponent_moneyline::float)/(-(opponent_moneyline::float)+100.0)
      when opponent_moneyline::float > 0 then
        100.0/(opponent_moneyline::float+100.0)
end);

update kelly
set team_kelly=team_predicted_p-(team_implied_p/(1-team_implied_p))*(1-team_predicted_p),
    opponent_kelly=opponent_predicted_p-(opponent_implied_p/(1-opponent_implied_p))*(1-opponent_predicted_p);

copy (
select
team_name,
team_predicted_p::numeric(4,3),
team_moneyline,
team_implied_p::numeric(4,3),
team_kelly::numeric(6,5),
opponent_name,
opponent_predicted_p::numeric(4,3),
opponent_moneyline,
opponent_implied_p::numeric(4,3),
opponent_kelly::numeric(6,5)
from kelly)
to '/tmp/daily.csv' csv header;

commit;


