begin;

create temporary table type (
	game_id		      integer,
	period		      integer,
	time		      interval,
        player_id      	      integer,
	min_event_id	      integer,
	max_event_id	      integer,
	enter		      integer,
	other		      integer,
	leave		      integer
);

insert into type
(game_id,period,time,player_id,min_event_id,max_event_id,enter,other,leave)
(
select
game_id,
period,
time,
coalesce(team_player_id,opponent_player_id) as player_id,
min(event_id) as min_event_id,
max(event_id) as max_event_id,
sum(
case when coalesce(team_event,opponent_event)='Enters Game' then 1
     else 0 end
) as enter,
sum(
case when coalesce(team_event,opponent_event) not in ('Enters Game','Leaves Game') then 1
     else 0 end
) as other,
sum(
case when coalesce(team_event,opponent_event)='Leaves Game' then 1
     else 0 end
) as leave

from ncaa_pbp.pbp_clean
group by game_id,period,time,player_id
);

create temporary table reorder (
       	game_id		      integer,
	period		      integer,
	event_id	      integer,
	id		      integer
);

insert into reorder
(game_id,period,event_id,id)
(
select t.game_id,t.period,p.event_id,rank()
over
(partition by t.game_id
  order by
    t.period asc,t.time desc,(t.enter-t.leave) asc,t.min_event_id asc,
    p.event_id asc)
from ncaa_pbp.pbp_clean p
join type t
 on (t.game_id,t.period,t.time,coalesce(t.player_id,-1))
   =(p.game_id,p.period,p.time,coalesce(coalesce(p.team_player_id,p.opponent_player_id),-1))
);

--alter table ncaa_pbp.pbp_clean add column id integer;

update ncaa_pbp.pbp_clean
set id=r.id
from reorder r
where (r.game_id,r.period,r.event_id)=
      (pbp_clean.game_id,pbp_clean.period,pbp_clean.event_id);

create index on ncaa_pbp.pbp_clean (id);

--alter table ncaa.games add column game_id serial primary key;

--update ncaa.games
--set game_length = trim(both ' -' from game_length);

commit;
