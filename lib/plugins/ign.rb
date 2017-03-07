require 'unirest'

module Cinch
  module Plugins
    class Ign
      include Cinch::Plugin

      match /(ign) (.+)/
      match /(help ign)$/, method: :help

      def execute(m, prefix, ign, game)
        game_uri = URI.encode(game.split(/[[:space:]]/).join(' ').downcase)
        response = Unirest.get "https://videogamesrating.p.mashape.com/get.php?count=5&game=#{game_uri}",
          headers:{
            "X-Mashape-Key" => "#{ENV['MASHAPE_KEY']}",
            "Accept" => "application/json"
          }
        title = response.body.first['title']
        score = response.body.first['score']
        m.reply "#{title} | Score: #{score}/10"
      end

      def help(m)
        m.reply 'returns IGN score for specified game'
      end

    end
  end
end
