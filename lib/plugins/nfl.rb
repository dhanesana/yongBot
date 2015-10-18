require 'open-uri'
require 'time'
require 'json'

module Cinch
  module Plugins
    class Nfl
      include Cinch::Plugin

      match /(nfl)$/
      match /(help nfl)$/, method: :help

      def execute(m)
        utc = Time.now.utc
        date = (utc + Time.zone_offset('PDT')).strftime("%Y%m%d")
        game = "00"
        games = "|"
        games_2 = "|"
        while game.to_i < 100
          begin
            feed = JSON.parse(open("http://www.nfl.com/liveupdate/game-center/#{date}#{game}/#{date}#{game}_gtd.json").read)

            quarter = feed["#{date}#{game}"]['qtr']
            home_team = feed["#{date}#{game}"]['home']['abbr']
            home_score = feed["#{date}#{game}"]['home']['score']['T']
            away_team = feed["#{date}#{game}"]['away']['abbr']
            away_score = feed["#{date}#{game}"]['away']['score']['T']
            the_game = " #{home_team}: #{home_score}, #{away_team}: #{away_score} [ #{quarter} ] |"
            if game.to_i < 6
              games += the_game
            else
              games_2 += the_game
            end
            game_num = game.to_i
            game = game_num += 1
            game = "0" + game.to_s if game < 10
            rescue OpenURI::HTTPError => e
              if e.message == '404 Not Found'
                # break loop if 404 error
                break
              else
                m.reply e.message
              end
          end
        end
        games = "no live or completed games rn" if games == "|"
        m.reply games
        m.reply games_2 unless games_2 == "|"
      end

      def help(m)
        m.reply 'daily nfl feed. go chargers'
      end

    end
  end
end
