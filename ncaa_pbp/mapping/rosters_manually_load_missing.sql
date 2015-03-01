begin;

create temporary table missing (
       team_id	       integer,
       player_name     text
);

copy missing from '/tmp/team_rosters_missing.csv' with delimiter as E'\t' csv header;

insert into ncaa_pbp.team_rosters
(team_id,player_name)
(select team_id,player_name
 from missing);

commit;
