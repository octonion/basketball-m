select *
from ncaa_pbp.name_mappings
where length(player_name)<=2
or player_name is null;

