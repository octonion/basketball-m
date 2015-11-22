begin;

create temporary table deleted_games (
       game_id	 integer,
       primary key (game_id)
);

copy deleted_games from '/tmp/deleted_games.csv' csv header;

delete from ncaa_pbp.periods
where game_id in
(select game_id from deleted_games);

delete from ncaa_pbp.play_by_play
where game_id in
(select game_id from deleted_games);

commit;
