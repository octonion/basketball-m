#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_url = "http://www.espn.com/mens-college-basketball/bpi/_/view/predictions/group/100/date/"
#20170316
                                 
table_xpath = '//*[@id="bpi-wrap"]/div[1]/div[5]/div/table'

predictions = CSV.open("csv/predictions.csv","w")

predictions << ["game_date","date_time",
                "away_name","away_abbr","away_score",
                "away_pred_diff","away_win_prob",
                "matchup_quality",
                "away_game_score",
                "home_name","home_abbr","home_score",
                "home_pred_diff","home_win_prob",
                "home_game_score"]

start_date = Date.new(2017,3,14)
end_date = Date.new(2017,3,27)

(start_date..end_date).each do |pull_date|
  
  year = pull_date.year
  month = pull_date.month
  day = pull_date.day

  key = "%d%02d%02d" % [year,month,day]

  url = base_url+key

  begin
    page = agent.get(url)
  rescue
    print "  -> error, retrying\n"
    retry
  end

  path = '//*[@id="bpi-wrap"]/div[1]/div[5]/div/table/tr'

  row = [pull_date]
  page.search(path).each_with_index do |tr,i|
  
    if ((i%2)==0)
      row = [pull_date]
    end
  
    tr.search("td").each do |td|
      type = td.attributes["class"].value
    
      case type
      when "u-hidden"
        next
      when "network-info"
        date_time = nil
        td.search("div[@class='date']").each do |date|
          date_time = date.attributes["data-date"].value
        end
        row += [date_time]
      when "team-scores team away","team-scores team home"
        td.search("span").each do |span|
          text = span.text.gsub("--","")
          if (text=="")
            text=nil
          end
          row += [text]
        end
      when "win-prob"
        text = td.text.gsub("--","")
        if (text=="")
          text=nil
        else
          text = text.gsub("%","")
        end
        row += [text]
      else
        text = td.text.gsub("--","")
        if (text=="")
          text=nil
        end
        row += [text]
      end
    end
    if ((i%2)==1)
      predictions << row
    end
  end
end

predictions.close
