require 'nokogiri'
require 'unirest'

class Ign
  include Cinch::Plugin

  match /(ign) (.+)/, prefix: /^(\.)/
  match /(help ign)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, ign, game)
    game_uri = URI.encode(game.downcase)
    response = Unirest.get "https://videogamesrating.p.mashape.com/get.php?count=5&game=#{game_uri}",
      headers:{
        "X-Mashape-Key" => "#{ENV['IGN_MASHAPE']}",
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
