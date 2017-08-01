require 'date'
require 'time'
require 'json'

module Cinch
  module Plugins
    class Nba
      include Cinch::Plugin

      match /(nba)$/
      match /(help nba)$/, method: :help

      def execute(m)
        utc = Time.now.utc
        today_pdt = utc + Time.zone_offset('PDT')
        today = today_pdt.strftime("%Y%m%d")
        begin
          url = "http://data.nba.com/5s/json/cms/noseason/scoreboard/#{today}/games.json"
          feed = open(url).read
        rescue
          return m.reply "error: check http://data.nba.com/5s/json/cms/noseason/scoreboard/#{today}/games.json"
        end
        result = JSON.parse(feed)
        return m.reply "no games today bru" if result['sports_content']['games'] == ""
        num_of_games = result['sports_content']['games']['game'].size
        games = "|"
        games_2 = "|"
        i = 0
        while i < num_of_games
          home = result['sports_content']['games']['game'][i]['home']['nickname']
          home_score = result['sports_content']['games']['game'][i]['home']['score']
          visitor = result['sports_content']['games']['game'][i]['visitor']['nickname']
          visitor_score = result['sports_content']['games']['game'][i]['visitor']['score']
          period = result['sports_content']['games']['game'][i]['period_time']['period_status']
          clock = result['sports_content']['games']['game'][i]['period_time']['game_clock']
          period += " #{clock}" unless clock == ""
          if i < 5
            games += " #{home}: #{home_score}, #{visitor}: #{visitor_score} [#{period}] |"
          else
            games_2 += " #{home}: #{home_score}, #{visitor}: #{visitor_score} [#{period}] |"
          end
          i += 1
        end
        m.reply games
        m.reply games_2 unless games_2 == "|"
      end

      def help(m)
        m.reply 'daily nba feed. ball is life'
      end

    end
  end
end
