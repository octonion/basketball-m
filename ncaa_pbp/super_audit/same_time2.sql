begin;

-- compress

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

from rails.pbp_clean
where game_id=1366153
group by game_id,period,time,player_id
);

select p.game_id,p.period,p.event_id,rank()
over
(partition by p.game_id
  order by
    t.period asc,t.time desc,(t.enter-t.leave) asc,t.min_event_id asc,
    p.event_id asc)
from rails.pbp_clean p
join type t
 on (t.game_id,t.period,t.time,coalesce(t.player_id,-1))
   =(p.game_id,p.period,p.time,coalesce(coalesce(p.team_player_id,p.opponent_player_id),-1));

commit;
