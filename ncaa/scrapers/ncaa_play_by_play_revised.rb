#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

require 'awesome_print'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

events = ["Leaves Game","Enters Game","Defensive Rebound","Commits Foul","made Free Throw","Assist","Turnover","missed Three Point Jumper","Offensive Rebound","missed Two Point Jumper","made Layup","missed Layup","Steal","made Two Point Jumper","made Three Point Jumper","missed Free Throw","Blocked Shot","Deadball Rebound","30 Second Timeout","Media Timeout","Team Timeout","made Dunk","20 Second Timeout","Timeout","made Tip In","missed Tip In","missed Dunk","made","missed","missed Deadball"]

base_url = 'http://stats.ncaa.org'

base_sleep = 0
sleep_increment = 3
retries = 4

ncaa_team_schedules = CSV.open("csv/ncaa_team_schedules.csv","r",{:col_sep => "\t", :headers => TRUE})
ncaa_play_by_play = CSV.open("csv/ncaa_games_play_by_play_revised.csv","w",{:col_sep => "\t"})
ncaa_periods = CSV.open("csv/ncaa_games_periods_revised.csv","w",{:col_sep => "\t"})

# Headers

ncaa_play_by_play << ["period_id","event_id","time","team_player","team_event","team_text","team_score","opponent_score","score","opponent_player","opponent_event","opponent_text"]

ncaa_periods << ["game_id", "section_id", "team_id", "team_name", "team_url", "period_scores"]

# Get game IDs

game_ids = []
ncaa_team_schedules.each do |game|
  game_ids << game["game_id"]
end

# Pull each game only once

# Modify in-place, so don't chain

game_ids.compact!
game_ids.sort!
game_ids.uniq!

n = game_ids.size

sleep_time = base_sleep

found_games = 0

game_ids.each_with_index do |game_id,i|

  game_url = 'http://stats.ncaa.org/game/play_by_play/%d' % [game_id]

  print "Sleep #{sleep_time} ... "
  sleep sleep_time

  tries = 0
  begin
    page = Nokogiri::HTML(open(game_url))
  rescue
    sleep_time += sleep_increment
    print "sleep #{sleep_time} ... "
    sleep sleep_time
    tries += 1
    if (tries > retries)
      next
    else
      retry
    end
  end

  sleep_time = base_sleep

  found_games += 1

  print "#{game_id} : #{i+1}/#{n}; found #{found_games}/#{n}\n"

  play_xpath = '//table[position()>1 and @class="mytable"]/tr[position()>1]'

  plays = []
  page.xpath(play_xpath).each_with_index do |row,event_id|

    table = row.parent
    period_id = table.parent.xpath('table[position()>1 and @class="mytable"]').index(table)

    time = row.at_xpath('td[1]').text.strip.to_nil rescue nil
    team_text = row.at_xpath('td[2]').text.strip.to_nil rescue nil
    score = row.at_xpath('td[3]').text.strip.to_nil rescue nil
    opponent_text = row.at_xpath('td[4]').text.strip.to_nil rescue nil

    team_event = nil
    if not(team_text.nil?)
      events.each do |e|
        if (team_text =~ /#{e}$/)
          team_event = e
          break
        end
      end
    end

    team_player = team_text.gsub(team_event,"").strip rescue nil

    opponent_event = nil
    if not(opponent_text.nil?)
      events.each do |e|
        if (opponent_text =~ /#{e}$/)
          opponent_event = e
          break
        end
      end
    end

    opponent_player = opponent_text.gsub(opponent_event,"").strip rescue nil

    scores = score.split('-') rescue nil
    team_score = scores[0].strip rescue nil
    opponent_score = scores[1].strip rescue nil

    plays << [period_id,event_id,time,team_player,team_event,team_text,team_score,opponent_score,score,opponent_player,opponent_event,opponent_text]

  end

  plays.each do |play|
    ncaa_play_by_play << play
  end

  ncaa_play_by_play.flush

  periods_xpath = '//table[position()=1 and @class="mytable"]/tr[position()>1]'

  team_lines = []
  page.xpath(periods_xpath).each_with_index do |row,section_id|
    section = [game_id,section_id]
    team_period_scores = []
    row.xpath('td').each_with_index do |element,i|
      case i
        when 0
        team_name = element.text.strip rescue nil
        link = element.search("a").first

        if (link==nil)
          link_url = nil
          team_url = nil
          team_id = nil
        else
          link_url = link.attributes["href"].text
          team_url = base_url+link_url

          parameters = link_url.split("/")[-1]

          team_id = parameters.split("=")[1]
        end
        section += [team_id, team_name, team_url]
      else
        team_period_scores += [element.text.strip.to_i]
      end
    end
    team_lines << section+[team_period_scores]
  end

  team_lines.each do |team_line|
    ncaa_periods << team_line
  end
  ncaa_periods.flush

end

ncaa_play_by_play.close
ncaa_periods.close
