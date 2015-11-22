--.TL files
--starters by period
--one row per period (so usually just two rows, though there will be
--more for overtime games)
--header: GameID, Period, HomeFW1Type, HomeFW1, HomeFW2Type, HomeFW2,
--HomeCTType, HomeCT, HomeGD1Type, HomeGD1, HomeGD2Type, HomeGD2,
--AwayFW1Type, AwayFW1, AwayFW2Type, AwayFW2, AwayCTType, AwayCT,
--AwayGD1Type, AwayGD1, AwayGD2Type, AwayGD2
--example: 23011412,1,"HP",12036,"HP",9013,"HP",18174,"HP",19401,
--"HP",12044,"AP",12921,"AP",29594,"AP",29593,"AP",7978,"AP",19619
--“HP” for home team players and “AP” for away team players

begin;

create temporary table first (
       game_id	       	     integer,
       team_id		     integer,
       period		     integer,
       player_id	     integer,
       id		     integer,
       rank	     	     integer,
       unique (game_id,team_id,period,rank)
);

insert into first
(game_id,team_id,period,player_id,id,rank)
(
select
game,team,period,player,id,rank()
over (partition by game,period,team order by id asc)
from (
select
g.game_id as game,
(case when p.team_event is not null then g.team_id
      when p.opponent_event is not null then g.opponent_id
end) as team,
p.period as period,
coalesce(p.team_player_id,p.opponent_player_id) as player,
min(p.id) as id

from rails.games g
join rails.periods per
 on (per.game_id,per.team_id,per.section_id)=(g.game_id,g.team_id,1)
join rails.pbp_clean p
 on (p.game_id)=(g.game_id)

where
TRUE
and coalesce(p.team_player_id,p.opponent_player_id) is not null

and not((coalesce(p.team_event,p.opponent_event),p.time)=
         ('Enters Game','20:00'))
and not((coalesce(p.team_event,p.opponent_event),p.time)=
        ('Leaves Game','20:00'))
group by game,team,period,player
) s
);

--header: GameID, Period, HomeFW1Type, HomeFW1, HomeFW2Type, HomeFW2,
--HomeCTType, HomeCT, HomeGD1Type, HomeGD1, HomeGD2Type, HomeGD2,
--AwayFW1Type, AwayFW1, AwayFW2Type, AwayFW2, AwayCTType, AwayCT,
--AwayGD1Type, AwayGD1, AwayGD2Type, AwayGD2

copy
(
select
h1.game_id as game_id,h1.period as period,
'HP' as home_fw1_type,h1.player_id as home_fw1,
'HP' as home_fw2_type,h2.player_id as home_fw2,
'HP' as home_ct_type,h3.player_id as home_ct,
'HP' as home_gd1_type,h4.player_id as home_gd1,
'HP' as home_gd2_type,h5.player_id as home_gd2,
'AP' as away_fw1_type,a1.player_id as away_fw1,
'AP' as away_fw2_type,a2.player_id as away_fw2,
'AP' as away_ct_type,a3.player_id as away_ct,
'AP' as away_gd1_type,a4.player_id as away_gd1,
'AP' as away_gd2_type,a5.player_id as away_gd2
from rails.games g
join first h1 on
 (h1.game_id,h1.team_id,h1.rank)=(g.game_id,g.home_team_id,1)
join first h2 on
 (h2.game_id,h2.team_id,h2.period,h2.rank)=(h1.game_id,h1.team_id,h1.period,2)
join first h3 on
 (h3.game_id,h3.team_id,h3.period,h3.rank)=(h1.game_id,h1.team_id,h1.period,3)
join first h4 on
 (h4.game_id,h4.team_id,h4.period,h4.rank)=(h1.game_id,h1.team_id,h1.period,4)
join first h5 on
 (h5.game_id,h5.team_id,h5.period,h5.rank)=(h1.game_id,h1.team_id,h1.period,5)
join first a1 on
 (a1.game_id,a1.team_id,a1.period,a1.rank)=(g.game_id,g.away_team_id,h1.period,1)
join first a2 on
 (a2.game_id,a2.team_id,a2.period,a2.rank)=(a1.game_id,a1.team_id,a1.period,2)
join first a3 on
 (a3.game_id,a3.team_id,a3.period,a3.rank)=(a1.game_id,a1.team_id,a1.period,3)
join first a4 on
 (a4.game_id,a4.team_id,a4.period,a4.rank)=(a1.game_id,a1.team_id,a1.period,4)
join first a5 on
 (a5.game_id,a5.team_id,a5.period,a5.rank)=(a1.game_id,a1.team_id,a1.period,5)
where g.team_id<g.opponent_id
)
to '/tmp/ncaa_starters.csv' csv header;

commit;
