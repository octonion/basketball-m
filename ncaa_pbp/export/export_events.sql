
--.TS files
--all events
--one row per event
--header: GameID, EventType, EventNumber, WallClock, Period, GameClock, ShotX, ShotY, OffenseTeamType, OffenseTeamID, PrimaryType, PrimaryID, SecondaryType, SecondaryID, OtherType, OtherID, ActionType, Option1, Option2, MemoText
--example: 23011412,"MADE_SHOT",15,"12:00:15.0",1,"17:34.0",,,"HT",23,"HP",19401,"",0,"",0,"Jump Shot","2","NO_FAST_BREAK",""
--EventTypes are: MADE_SHOT, MISSED_SHOT, FREE_THROW, REBOUND, TURNOVER, FOUL, VIOLATION, SUBSTITUTION, TIMEOUT, JUMP_BALL, EJECTION, START_PERIOD, END_PERIOD
--for wall clock, in the past we just used “12:00:01.0” where the underlined portion is the event order, so “12:01:15.0” would be the 115th event
--Primary ID is for shooter, rebounder, turnoverer, fouler, sub OUT
--Secondary ID is for assister, stealer, foul drawer (if applicable), sub IN
--Other ID is for shot blocker or the player that secured the jump ball (if applicable)
--ActionType is any detail like shot type, turnover type, timeout type, etc. For example “Jump Shot” or “Lay-Up” or “Lost Ball Turnover”
--Option1 is: 2 or 3 for made/missed shots; FT_MADE or FT_MISSED for free throws; NO_STEAL or STEAL for turnovers
--Option2 you can put “NO_FAST_BREAK” or “FAST_BREAK” if applicable; we can also use this perhaps for shot distances or any other info you find in the play by play

copy
(

select

pbp.game_id,

(case

-- MADE_SHOT
when coalesce(pbp.team_event,pbp.opponent_event) in
('made','made Dunk','made Layup',
'made Three Point Jumper','made Tip In',
'made Two Point Jumper')
then 'MADE_SHOT'

-- MISSED_SHOT
when coalesce(pbp.team_event,pbp.opponent_event) in
('missed','missed Deadball','missed Dunk',
'missed Layup','missed Three Point Jumper','missed Tip In',
'missed Two Point Jumper','missing')
then 'MISSED_SHOT'

-- FREE_THROW
when coalesce(pbp.team_event,pbp.opponent_event) in
('made Free Throw','missed Free Throw')
then 'FREE_THROW'

-- REBOUND
when coalesce(pbp.team_event,pbp.opponent_event) in
('Deadball Rebound','Defensive Rebound','Offensive Rebound')
then 'REBOUND'

-- TURNOVER
when coalesce(pbp.team_event,pbp.opponent_event) in
('Steal','Turnover')
then 'TURNOVER'

-- FOUL
when coalesce(pbp.team_event,pbp.opponent_event) in
('Commits Foul')
then 'FOUL'

-- VIOLATION

-- SUBSTITUTION
when coalesce(pbp.team_event,pbp.opponent_event) in
('Enters Game','Leaves Game')
then 'SUBSTITUTION'

-- TIMEOUT
when coalesce(pbp.team_event,pbp.opponent_event) in
('20 Second Timeout','30 Second Timeout','Media Timeout','Team Timeout',
'Timeout')
then 'TIMEOUT'

-- ASSIST
when coalesce(pbp.team_event,pbp.opponent_event) in
('Assist')
then 'ASSIST'

-- BLOCKED_SHOT
when coalesce(pbp.team_event,pbp.opponent_event) in
('Blocked Shot')
then 'BLOCKED_SHOT'

-- JUMP_BALL
-- EJECTION
-- START_PERIOD
-- END_PERIOD

else NULL end) as event_type,

--pbp.event_id as event_number,
pbp.id as event_number,

-- for wall clock, in the past we just used “12:00:01.0” where the
-- underlined portion is the event order, so “12:01:15.0” would be
-- the 115th event

split_part(pbp.time::text,':',1)||':'||split_part(pbp.time::text,':',2)||'.'||split_part(pbp.time::text,':',3) as wall_clock,

pbp.period_id as period,

split_part(pbp.time::text,':',1)||':'||split_part(pbp.time::text,':',2)||'.'||split_part(pbp.time::text,':',3) as game_clock,

NULL as shot_x,
NULL as shot_y,

-- "HT","AT"

(
case when coalesce(pbp.team_event,pbp.opponent_event) in
     ('Defensive Rebound') then
  (case when pbp.team_event is null then g.team_type
        else g.opponent_type end)
else (case when pbp.team_event is null then g.opponent_type
           else g.team_type end)
end) as offense_team_type,

(
case when coalesce(pbp.team_event,pbp.opponent_event) in
     ('Defensive Rebound') then
  (case when pbp.team_event is null then g.pbp_team_id
        else g.pbp_opponent_id end)
else (case when pbp.team_event is null then g.pbp_opponent_id
           else g.pbp_team_id end)
end) as offense_team_id,

--Primary ID is for shooter, rebounder, turnoverer, fouler, sub OUT
-- "HP","AP"

(
case when coalesce(pbp.team_event,pbp.opponent_event) in 
     ('made','made Dunk','made Layup','made Three Point Jumper','made Tip In',
      'made Two Point Jumper',
      'missed','missed Deadball','missed Dunk','missed Layup',
      'missed Three Point Jumper','missed Tip In','missed Two Point Jumper',
      'missing',
      'made Free Throw','missed Free Throw',
      'Deadball Rebound','Defensive Rebound','Offensive Rebound',
      'Steal','Turnover',
      'Commits Foul',
      'Leaves Game')
     then (case when pbp.team_event is null then replace(g.opponent_type,'T','P')
                else replace(g.team_type,'T','P') end)
else NULL end)
as primary_type,

(case when coalesce(pbp.team_event,pbp.opponent_event) in 
('made','made Dunk','made Layup','made Three Point Jumper','made Tip In',
'made Two Point Jumper',
'missed','missed Deadball','missed Dunk','missed Layup',
'missed Three Point Jumper','missed Tip In','missed Two Point Jumper',
'missing',
'made Free Throw','missed Free Throw',
'Deadball Rebound','Defensive Rebound','Offensive Rebound',
'Steal','Turnover',
'Commits Foul',
'Leaves Game')
then coalesce(pbp.team_player_id,pbp.opponent_player_id)
else NULL end)
as primary_id,

-- Foul drawer?

--Secondary ID is for assister, stealer, foul drawer (if applicable), sub IN

(case when (coalesce(pbp.team_event,pbp.opponent_event) in ('Enters Game')
      	   or coalesce(pbp_a.team_event,pbp_a.opponent_event)='Assist')
      then (case when pbp.team_event is null then replace(g.opponent_type,'T','P')
                 else replace(g.team_type,'T','P') end)
      when coalesce(pbp_s.team_event,pbp_s.opponent_event)='Steal'
      then (case when pbp.team_event is null then replace(g.team_type,'T','P')
                 else replace(g.opponent_type,'T','P') end)
else NULL end) as secondary_type,

(case when coalesce(pbp.team_event,pbp.opponent_event) in 
             ('Steal','Enters Game')
      then coalesce(pbp.team_player_id,pbp.opponent_player_id)
      when coalesce(pbp_a.team_event,pbp_a.opponent_event) is not null
      then coalesce(pbp_a.team_player_id,pbp_a.opponent_player_id)
      when coalesce(pbp_s.team_event,pbp_s.opponent_event) is not null
      then coalesce(pbp_s.team_player_id,pbp_s.opponent_player_id)
else NULL end)
as secondary_id,

--Other ID is for shot blocker or the player that secured the jump ball (if applicable)

(case when coalesce(pbp_b.team_event,pbp_b.opponent_event)='Blocked Shot'
      then (case when pbp.team_event is null then replace(g.team_type,'T','P')
                 else replace(g.opponent_type,'T','P') end)
else NULL end) as other_type,

(case when coalesce(pbp_b.team_event,pbp_b.opponent_event)='Blocked Shot'
      then coalesce(pbp_b.team_player_id,pbp_b.opponent_player_id)
      else NULL end)
as other_id,

--ActionType is any detail like shot type, turnover type, timeout type, etc. For example “Jump Shot” or “Lay-Up” or “Lost Ball Turnover”
coalesce(pbp.team_event,pbp.opponent_event) as action_type,

--Option1 is: 2 or 3 for made/missed shots; FT_MADE or FT_MISSED for free throws; NO_STEAL or STEAL for turnovers
--Option2 you can put “NO_FAST_BREAK” or “FAST_BREAK” if applicable; we can also use this perhaps for shot distances or any other info you find in the play by play

(
case when coalesce(pbp.team_event,pbp.opponent_event) in
       ('made','made Dunk','made Layup','made Tip In',
        'made Two Point Jumper',
        'missed','missed Deadball','missed Dunk','missed Layup',
        'missed Tip In','missed Two Point Jumper',
        'missing')
     then '2'
     when coalesce(pbp.team_event,pbp.opponent_event) in
       ('made Three Point Jumper','missed Three Point Jumper')
     then '3'
     when coalesce(pbp.team_event,pbp.opponent_event) in
     ('made Free Throw')
     then 'FT_MADE'
     when coalesce(pbp.team_event,pbp.opponent_event) in
     ('missed Free Throw')
     then 'FT_MISSED'

-- Need to pair up steal and turnover

     when coalesce(pbp.team_event,pbp.opponent_event) in ('Turnover')
          and coalesce(pbp_s.team_event,pbp_s.opponent_event) is not null
     then 'STEAL'
     when coalesce(pbp.team_event,pbp.opponent_event) in ('Turnover')
          and coalesce(pbp_s.team_event,pbp_s.opponent_event) is null
     then 'NO_STEAL'
else NULL end) as option_1,

NULL as option_2,

NULL as memo_text

from ncaa_pbp.play_by_play_clean pbp

left join ncaa_pbp.play_by_play_clean pbp_b
  on ((pbp_b.game_id,pbp_b.id)=(pbp.game_id,pbp.id+1)
      and coalesce(pbp.team_event,pbp.opponent_event) in
        ('missed Layup','missed Two Point Jumper','missed Three Point Jumper',
	 'missed Dunk','missed Tip In')
      and coalesce(pbp_b.team_event,pbp_b.opponent_event)='Blocked Shot'
      and coalesce(pbp.team_event,pbp_b.team_event) is not null
      and coalesce(pbp.opponent_event,pbp_b.opponent_event) is not null
     )

left join ncaa_pbp.play_by_play_clean pbp_s
  on ((pbp_s.game_id,pbp_s.id)=(pbp.game_id,pbp.id+1)
      and coalesce(pbp.team_event,pbp.opponent_event) in
        ('Turnover')
      and coalesce(pbp_s.team_event,pbp_s.opponent_event)='Steal'
      and coalesce(pbp.team_event,pbp_s.team_event) is not null
      and coalesce(pbp.opponent_event,pbp_s.opponent_event) is not null
     )

left join ncaa_pbp.play_by_play_clean pbp_a
  on ((pbp_a.game_id,pbp_a.id)=(pbp.game_id,pbp.id+1)
      and coalesce(pbp.team_event,pbp.opponent_event) in
        ('made Three Point Jumper','made Layup','made Two Point Jumper',
	 'made Dunk','made Tip In')
      and coalesce(pbp_a.team_event,pbp_a.opponent_event)='Assist'
      and (coalesce(pbp.team_event,pbp_a.team_event) is not null
           or coalesce(pbp.opponent_event,pbp_a.opponent_event) is not null)
     )

join ncaa_pbp.team_schedules g
 on (g.game_id)=(pbp.game_id)

join ncaa.schools_divisions sdt
 on (sdt.school_id,sdt.year)=(g.team_id,2015)

join ncaa.schools_divisions sdo
 on (sdo.school_id,sdo.year)=(g.opponent_id,2015)

where TRUE

and sdt.div_id=1
and sdo.div_id=1

-- exclude these lines to include ASSIST/BLOCKED_SHOT events separately
and coalesce(pbp.team_event,pbp.opponent_event) not in
  ('Assist','Blocked Shot','Steal')

and g.team_id < g.opponent_id
order by pbp.game_id,pbp.period_id,pbp.id
--order by pbp.game_id,pbp.period,pbp.event_id
)

to '/tmp/ncaa_events.csv' csv;
