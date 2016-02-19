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

base_url = 'http://stats.ncaa.org'

box_scores_xpath = '//*[@id="contentarea"]/table[position()>4]/tr[position()>2]'

year = ARGV[0].to_i
division = ARGV[1].to_i

ncaa_team_schedules = CSV.open("tsv/ncaa_team_schedules_mt_#{year}_#{division}.tsv",
                               "r",
                               {:col_sep => "\t", :headers => TRUE})
ncaa_box_scores = CSV.open("tsv/ncaa_games_box_scores_mt_#{year}_#{division}.tsv",
                           "w",
                           {:col_sep => "\t"})

# Headers

ncaa_box_scores << ["game_id","section_id","player_id","player_name","player_url","position","minutes_played","field_goals_made","field_goals_attempted","three_point_field_goals","three_point_field_goals_attempted","free_throws","free_throws_attempted","points","offensive_rebounds","defensive_rebounds","total_rebounds","assists","turnovers","steals","blocks","fouls"]

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

      game_url = 'http://stats.ncaa.org/game/box_score/%d' % [game_id]

#      print "Thread #{thread_id}, sleep #{sleep_time} ... "
#      sleep sleep_time

      tries = 0
      begin
        page = Nokogiri::HTML(agent.get(game_url).body)
      rescue
        sleep_time += sleep_increment
#        print "sleep #{sleep_time} ... "
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

      page.xpath(box_scores_xpath).each do |row|

        table = row.parent
        section_id = table.parent.xpath('table[position()>1 and @class="mytable"]').index(table)

        player_id = nil
        player_name = nil
        player_url = nil

        field_values = []
        row.xpath('td').each_with_index do |element,k|
          case k
          when 0
            player_name = element.text.strip rescue nil
            link = element.search("a").first

            if not(link.nil?)
              link_url = link.attributes["href"].text
              player_url = base_url+link_url
              parameters = link_url.split("/")[-1]
              player_id = parameters.split("=")[2]
            end
          else
            field_values += [element.text.strip.to_i]
          end
        end

        ncaa_box_scores << [game_id,section_id,player_id,player_name,player_url]+field_values

      end

    end

  end

end

threads.each(&:join)

ncaa_box_scores.close
