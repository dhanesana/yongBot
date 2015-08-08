require 'date'
require 'time'
require 'json'

class Nba
  include Cinch::Plugin

  match /(nba)$/, prefix: /^(\.)/
  match /(help nba)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    begin
      utc = Time.now.utc
      today_pdt = utc + Time.zone_offset('PDT')
      today = today_pdt.strftime("%Y%m%d")
      feed = open("http://data.nba.com/5s/json/cms/noseason/scoreboard/#{today}/games.json").read
    rescue
      return m.reply 'no games today bru' if feed.nil?
    end
    result = JSON.parse(feed)
    num_of_games = result['sports_content']['games']['game'].size
    string = "| "
    i = 0
    while i < num_of_games
      string += result['sports_content']['games']['game'][i]['home']['nickname']
      string += ": "
      string += result['sports_content']['games']['game'][i]['home']['score']
      string += ", "
      string += result['sports_content']['games']['game'][i]['visitor']['nickname']
      string += ": "
      string += result['sports_content']['games']['game'][i]['visitor']['score']
      string += " ["
      string += result['sports_content']['games']['game'][i]['period_time']['period_status']
      string += " #{result['sports_content']['games']['game'][i]['period_time']['game_clock']}"
      string += "] | "
      i += 1
    end
    m.reply string
  end

  def help(m)
    m.reply 'daily nba feed. ball is life'
  end

end
