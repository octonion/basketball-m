#!/usr/bin/env ruby

require 'csv'
require 'json'

json = ARGV[0]

csv = CSV.open("csv/lines.csv","w")

csv << ["league_id",
        "event_id",
        "date_time",
        "team_id","team_name","team_type",
        "team_price","team_min","team_max",
        "team_moneyline","team_totals","team_draw",
        "team_pitcher","team_red_cards","team_score",
        "opponent_id","opponent_name","opponent_type",
        "opponent_price","opponent_min","opponent_max",
        "opponent_moneyline","opponent_totals","opponent_draw",
        "opponent_pitcher","opponent_red_cards","opponent_score"]

lines = JSON.parse(File.read(json))

lines["Leagues"].each do |league|
  league["Events"].each do |event|
    if (event["IsMoneyLineEmpty"])
      next
    end
    event_id = event["EventId"]
    league_id = event["LeagueId"]
    date_time = event["DateAndTime"]
    row = [league_id,event_id,date_time]
    event["Participants"].each do |participant|
      participant.each do |pair|
        if (pair[0]=="Handicap")
          row += pair[1].values
        else
          row += [pair[1]]
        end
      end
    end
    csv << row
  end
  
end

