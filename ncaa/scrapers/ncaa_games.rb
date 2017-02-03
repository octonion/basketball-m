#!/usr/bin/env ruby

# encoding: UTF-8

require 'csv'
require 'mechanize'

bad = '%'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

search_url = "http://web1.ncaa.org/stats/exec/records"
schools = CSV.read("csv/ncaa_schools.csv")

first_year = ARGV[0].to_i
last_year = ARGV[1].to_i

games_header = ["year","team_name","team_id","opponent_name","opponent_id",
                "game_date","team_score","opponent_score","location",
                "neutral_site_location","game_length","attendance"]

records_header = ["year","team_id","team_name","wins","losses","ties",
                  "total_games"]

game_xpath = "//table/tr[3]/td/form/table[2]/tr"
record_xpath = "//table/tr[3]/td/form/table[1]/tr[2]"

(first_year..last_year).each do |year|

  games = CSV.open("csv/ncaa_games_#{year}.csv","w")
  records = CSV.open("csv/ncaa_records_#{year}.csv","w")

  team_count = 0
  game_count = 0

  games << games_header
  records << records_header

  schools.each do |school|
    school_id = school[0]
    school_name = school[1]
    print "#{year}/#{school_name} (#{team_count}/#{game_count})\n"
    begin
      page = agent.post(search_url, {"academicYear" => "#{year}",
                                     "orgId" => school_id,
                                     "sportCode" => "MBB"})
    rescue
      print "  -> error, retrying\n"
      retry
    end

    begin
      page.parser.xpath(record_xpath).each do |tr|
        row = [year,school_id]
        tr.xpath("td").each do |d|
          row += [d.text.strip]
        end
        team_count += 1
        records << row
      end
      records.flush
    end

    page.parser.xpath(game_xpath).each do |tr|
      
      row = []
      
      tr.xpath("td").each do |td|
        
        #in `strip': invalid byte sequence in UTF-8 (ArgumentError)

        a = td.xpath("a").first
        if not(a==nil)
          text = a.inner_text.encode('UTF-8',
                                     :invalid => :replace, :undef => :replace)
          clean_text = text.gsub(bad,"").strip
          
          href = a.attributes["href"].value
          url = href.encode('UTF-8',
                            :invalid => :replace, :undef => :replace)
          clean_url = url.strip
        else
          text = td.text.encode('UTF-8',
                                :invalid => :replace, :undef => :replace)
          clean_text = text.gsub(bad,"").strip
          clean_url = nil
        end
        row += [clean_text, clean_url]

      end
        
#

#r += [text,html]

      if (row[0]=="Opponent")
        next
      end
      if not(row[1]==nil)
        opponent_id = row[1][/(\d+)/]
      else
        opponent_id=nil
      end
      
      game_count += 1

      rr = [year, school_name, school_id, row[0], opponent_id,
            row[2],row[4],row[6],row[8],row[10],row[12],row[14]]
      
      rr.map!{ |e| e=='' ? nil : e }
      
      games << rr
    end
    games.flush
  end
  records.close
  games.close
end
