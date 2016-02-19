#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

nthreads = 1

base_sleep = 0
sleep_increment = 3
retries = 4

#require 'awesome_print'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

#http://stats.ncaa.org/game/period_stats/3664453

base_url = 'http://stats.ncaa.org'
#base_url = 'http://anonymouse.org/cgi-bin/anon-www.cgi/stats.ncaa.org'

# Table 1: scores by period
# Table 2: empty
# Table 3: game info
# Table 4: game officials
# Table 5: start of summaries

#//*[@id="contentArea"]/table[position()>4]

#play_xpath = '//table[position()>1 and @class="mytable"]/tr[position()>1]'
#periods_xpath = '//table[position()=1 and @class="mytable"]/tr[position()>1]'

period_xpath = '//*[@id="contentarea"]/table[position()>4]'

year = ARGV[0].to_i
division = ARGV[1].to_i

team_schedules = CSV.open("tsv/ncaa_team_schedules_mt_#{year}_#{division}.tsv",
                          "r",
                          {:col_sep => "\t", :headers => TRUE})

periods_stats = CSV.open("tsv/ncaa_games_periods_stats_#{year}_#{division}.tsv",
                         "w",
                         {:col_sep => "\t"})

periods_cats = CSV.open("tsv/ncaa_games_periods_cats_#{year}_#{division}.tsv",
                        "w",
                        {:col_sep => "\t"})

# Headers

stats_header = ["game_id", "period_id", "section_id", "team_name",
                "fgm", "fga", "tpfg", "tpfga", "ft", "fta", "pts",
                "orebs", "drebs", "tot", "reb", "ast", "to", "stl",
                "blk", "fouls", "dq"]

cats_header = ["game_id", "period_id", "category",
               "team_value", "opponent_value"]

periods_stats << stats_header
periods_cats << cats_header

# Get game IDs

game_ids = []
team_schedules.each do |game|
  game_ids << game["game_id"]
end

# Pull each game only once
# Modify in-place, so don't chain

game_ids.compact!
game_ids.sort!
game_ids.uniq!

#game_ids = game_ids[0..199]

n = game_ids.size

gpt = (n.to_f/nthreads.to_f).ceil

threads = []

# One agent for each thread?

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

game_ids.each_slice(gpt).with_index do |ids,i|

  threads << Thread.new(ids) do |t_ids|

    found = 0
    n_t = t_ids.size

    t_ids.each_with_index do |game_id,j|

      sleep_time = base_sleep

      game_url = 'http://stats.ncaa.org/game/period_stats/%d' % [game_id]

      tries = 0
      begin
        page = Nokogiri::HTML(agent.get(game_url).body)
      rescue
        sleep_time += sleep_increment
        sleep sleep_time
        tries += 1
        if (tries > retries)
          next
        else
          retry
        end
      end

      sleep_time = base_sleep

      found += 1

      print "#{i}, #{game_id} : #{j+1}/#{n_t}; found #{found}/#{n_t}\n"

      page.xpath(period_xpath).each_with_index do |table|

        period_id = nil

        table.xpath("tr").each_with_index do |tr,i|

          case i
          when 0
            period_id = tr.xpath("td").first.text.strip
          when 1
            stat_header = ["game_id", "period_id", "section_id"]
            tr.xpath("td").each do |td|
              stat_header << td.text.strip
            end
            #periods_stats << stat_header
          when 2
            team_line = [game_id, period_id, 0]
            tr.xpath("td").each do |td|
              team_line << td.text.strip
            end
            periods_stats << team_line
          when 3
            opponent_line = [game_id, period_id, 1]
            tr.xpath("td").each do |td|
              opponent_line << td.text.strip
            end
            periods_stats << opponent_line
          when 4
            tr.xpath("td/table/tr").each_with_index do |tr2,j|
              case j
              when 0
                cat_header = ["game_id", "period_id"]
                tr2.xpath("td").each do |td2|
                  cat_header << td2.text.strip
                end
                cat_header[2] = "Category"
                #periods_cats << cat_header
              else
                cat_line = [game_id, period_id]
                tr2.xpath("td").each do |td2|
                  cat_line << td2.text.strip
                end

                if (cat_line.size==3)
                  cat_line += [nil, nil]
                end

                if (cat_line.size==4)
                  cat_line += [nil]
                end

                periods_cats << cat_line
              end
            end
          end

        end

      end

    end

  end

end

threads.each(&:join)

periods_cats.close

periods_stats.close
