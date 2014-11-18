begin;

alter table ncaa_pbp.play_by_play drop column if exists id;
alter table ncaa_pbp.play_by_play add column id serial;

commit;
