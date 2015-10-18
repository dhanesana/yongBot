require 'nokogiri'
require 'json'
require 'open-uri'

module Cinch
  module Plugins
    class Csgo
      include Cinch::Plugin

      match /(csgo) (.+)/, prefix: /^(\.)/
      match /(help csgo)$/, method: :help, prefix: /^(\.)/

      def execute(m, prefix, csgo, user)
        page = Nokogiri::XML(open("http://steamcommunity.com/id/#{user}/?xml=1"))
        return m.reply "invalid user bru" if page.text == "The specified profile could not be found."
        steamID64 = page.xpath("//steamID64").text
        steamGet = open("http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002/?appid=730&key=#{ENV['STEAM_KEY']}&steamid=#{steamID64}").read
        result = JSON.parse(steamGet)

        total_k, total_d, hs, hit, fired, wins, rounds = 0, 0, 0, 0, 0, 0, 0
        result['playerstats']['stats'].each do |item|
          total_k += item['value'].to_f if item['name'] == 'total_kills'
          total_d += item['value'].to_f if item['name'] == 'total_deaths'
          hs      += item['value'].to_f if item['name'] == 'total_kills_headshot'
          hit     += item['value'].to_f if item['name'] == 'total_shots_hit'
          fired   += item['value'].to_f if item['name'] == 'total_shots_fired'
          wins    += item['value'].to_f if item['name'] == 'total_wins'
          rounds  += item['value'].to_f if item['name'] == 'total_rounds_played'
        end

        kd_ratio = (total_k / total_d).round(2)
        hs_ratio = ((hs / total_k) * 100).round(0)
        accuracy = ((hit / fired) * 100).round(0)
        win_ratio = ((wins / rounds) * 100).round(0)

        m.reply "K/D: #{kd_ratio} | HS: #{hs_ratio}% | ACC: #{accuracy}% | WIN: #{win_ratio}%"
      end

      def help(m)
        m.reply 'Returns K/D ratio, hs percentage, accuracy, and win percentage for specified public Steam username'
      end

    end
  end
end
