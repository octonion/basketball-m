#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

year = ARGV[0].to_i
division = ARGV[1].to_i

ncaa_teams = CSV.open("tsv/ncaa_teams_#{year}_#{division}.tsv", "w",
                      {:col_sep => "\t"})

# Header for team file

ncaa_teams << ["year", "year_id", "team_id", "team_name", "team_url"]

year_division_url = "http://stats.ncaa.org/team/inst_team_list?sport_code=MBB&academic_year=#{year}&division=#{division}&conf_id=-1&schedule_date="

print "\nRetrieving division #{division} teams for #{year} ... "

found_teams = 0

doc = Nokogiri::HTML(agent.get(year_division_url).body)

doc.search("a").each do |link|

  link_url = link.attributes["href"].text

  # Valid team URLs

  if (link_url =~ /^\/team\/\d/)

    # NCAA year_id

    parameters = link_url.split("/")
    year_id = parameters[-1]

    # NCAA team_id

    team_id = parameters[-2]

    # NCAA team name

    team_name = link.text()

    # NCAA team URL

    team_url = base_url+link_url

    ncaa_teams << [year, year_id, team_id, team_name, team_url]
    found_teams += 1

  end

  ncaa_teams.flush

end

ncaa_teams.close

print "found #{found_teams} teams\n\n"
