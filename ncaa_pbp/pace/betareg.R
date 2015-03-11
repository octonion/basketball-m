sink("diagnostics/pace_betareg.txt")

library(RPostgreSQL)

library(betareg)
library(lmtest)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname="basketball-m")

query <- dbSendQuery(con, "
select
pc.game_id,
pt.team_id as team_id,
po.team_id as opponent_id,
pc.team_value::integer as team_time,
pc.opponent_value::integer as opponent_time,
(case when ts.neutral_site then 'neutral'
      when not(ts.neutral_site) and (ts.home_game) then 'home'
      when not(ts.neutral_site) and not(ts.home_game) then 'away'
end) as location
from ncaa_pbp.periods_cats pc
join ncaa_pbp.periods pt
  on (pt.game_id,pt.section_id)=(pc.game_id,0)
join ncaa_pbp.periods po
  on (po.game_id,po.section_id)=(pc.game_id,1)
join ncaa_pbp.team_schedules ts
  on (ts.team_id,ts.game_id)=(pt.team_id,pt.game_id)
join ncaa.schools_divisions sdt
  on (sdt.year,sdt.school_id)=(2015,pt.team_id)
join ncaa.schools_divisions sdo
  on (sdo.year,sdo.school_id)=(2015,po.team_id)
where pc.period_id='1st Half'
and pc.category='Time of Possession'
and pc.team_value::integer+pc.opponent_value::integer=1200
and sdt.div_id=1
and sdo.div_id=1

union

select
pc.game_id,
po.team_id as team_id,
pt.team_id as opponent_id,
pc.opponent_value::integer as team_time,
pc.team_value::integer as opponent_time,
(case when ts.neutral_site then 'neutral'
      when not(ts.neutral_site) and not(ts.home_game) then 'home'
      when not(ts.neutral_site) and (ts.home_game) then 'away'
end) as location
from ncaa_pbp.periods_cats pc
join ncaa_pbp.periods pt
  on (pt.game_id,pt.section_id)=(pc.game_id,0)
join ncaa_pbp.periods po
  on (po.game_id,po.section_id)=(pc.game_id,1)
join ncaa_pbp.team_schedules ts
  on (ts.team_id,ts.game_id)=(pt.team_id,pt.game_id)
join ncaa.schools_divisions sdt
  on (sdt.year,sdt.school_id)=(2015,pt.team_id)
join ncaa.schools_divisions sdo
  on (sdo.year,sdo.school_id)=(2015,po.team_id)
where pc.period_id='1st Half'
and pc.category='Time of Possession'
and pc.team_value::integer+pc.opponent_value::integer=1200
and sdt.div_id=1
and sdo.div_id=1


;")

games <- fetch(query,n=-1)

dim(games)

games$pf <- games$team_time/1200.0

games$team_id <- as.factor(games$team_id)
games$opponent_id <- as.factor(games$opponent_id)

head(games)

fit0 <- betareg(pf ~ team_id+opponent_id, link="logit", data=games)

fit <- betareg(pf ~ location+team_id+opponent_id, link="logit", data=games)

fit
summary(fit)
lrtest(fit0,fit)
waldtest(fit0,fit)
