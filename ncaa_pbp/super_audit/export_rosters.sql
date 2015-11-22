--TP files
--rosters for the game
--one row per player
--header: GameID, TeamIdType, TeamID, PersonIDType, PersonID,
--Jersey, ShortName, FirstName, LastName, Status

copy
(
select
game_id,
team_id,

from rails.rosters
)

to '/tmp/ncaa_game_rosters.csv' csv header;
