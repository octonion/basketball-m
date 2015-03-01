begin;

create temporary table bad_player_names (
       team_id	       integer,
       player_name     text
);

copy bad_player_names from '/tmp/bad_player_names.csv' with delimiter as E'\t' csv header;

create temporary table player_names (
       game_id	       integer,
       team_id	       integer,
       player_name     text
);

insert into player_names
(game_id, team_id, player_name)
(
select

g.game_id,
p.team_id,
pbp.team_player
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
 on (p.game_id,p.team_id,p.section_id)=(g.game_id,g.team_id,0)
join ncaa_pbp.play_by_play pbp
 on (pbp.game_id)=(g.game_id)
where
    pbp.team_player is not null
and not(pbp.team_player='TEAM')

union

select
g.game_id,
p.team_id,
pbp.team_player
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
 on (p.game_id,p.team_id,p.section_id)=(g.game_id,g.opponent_id,0)
join ncaa_pbp.play_by_play pbp
 on (pbp.game_id)=(g.game_id)
where
    pbp.team_player is not null
and not(pbp.team_player='TEAM')

union

select

g.game_id,
p.team_id,
pbp.opponent_player
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
 on (p.game_id,p.team_id,p.section_id)=(g.game_id,g.team_id,1)
join ncaa_pbp.play_by_play pbp
 on (pbp.game_id)=(g.game_id)
where
    pbp.opponent_player is not null
and not(pbp.opponent_player='TEAM')

union

select

g.game_id,
p.team_id,
pbp.opponent_player
from ncaa_pbp.team_schedules g
join ncaa_pbp.periods p
 on (p.game_id,p.team_id,p.section_id)=(g.game_id,g.opponent_id,1)
join ncaa_pbp.play_by_play pbp
 on (pbp.game_id)=(g.game_id)
where
    pbp.opponent_player is not null
and not(pbp.opponent_player='TEAM')

);

select pn.game_id
from player_names pn
join bad_player_names bpn
on (bpn.team_id,bpn.player_name)=(pn.team_id,pn.player_name);

commit;
