require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Ow
      include Cinch::Plugin

      match /(ow) (.+)/
      match /(help ow)$/, method: :help

      def execute(m, prefix, ow, nick)
        input = nick.split(" ")
        country = ''
        if input.size > 1
          country = input[1]
        else
          country = 'us'
        end
        battlenet_id = input.first
        encoded_id = URI.encode(battlenet_id.split("#").join("-"))
        request = Unirest.get("https://owapi.net/api/v3/u/#{encoded_id}/stats")
        return m.reply "player or country not found" if request.body["#{country}"].nil?
        return m.reply "this player hasnt ranked" if request.body["#{country}"]['stats']['competitive']['overall_stats'].nil?
        level = request.body["#{country}"]['stats']['competitive']['overall_stats']['level']
        rank = request.body["#{country}"]['stats']['competitive']['overall_stats']['comprank']
        prestige = request.body["#{country}"]['stats']['competitive']['overall_stats']['prestige']
        win_rate = request.body["#{country}"]['stats']['competitive']['overall_stats']['win_rate']
        wins = request.body["#{country}"]['stats']['competitive']['overall_stats']['wins']
        losses = request.body["#{country}"]['stats']['competitive']['overall_stats']['losses']
        ties = request.body["#{country}"]['stats']['competitive']['overall_stats']['ties']
        total = wins + losses + ties
        m.reply "#{battlenet_id} => Level: #{level}, Rank: #{rank}, Prestige: #{prestige}, Win Rate: #{win_rate}% (#{total} games)"
      end

      def help(m)
        m.reply 'returns stats of specified ranked overwatch player'
      end

    end
  end
end
