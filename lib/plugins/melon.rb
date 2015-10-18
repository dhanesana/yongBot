require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class Melon
      include Cinch::Plugin

      match /(melon)$/, prefix: /^(\.)/
      match /(melon) (.+)/, method: :with_num, prefix: /^(\.)/
      match /(help melon)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        link = open("http://www.melon.com/chart/index.htm.json").read
        result = JSON.parse(link)
        rank = result['songList'][0]['curRank']
        artist = result['songList'][0]['artistNameBasket']
        song = result['songList'][0]['songName']
        m.reply "Melon Rank #{rank}: #{artist} - #{song}"
      end

      def with_num(m, prefix, melon, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        link = open("http://www.melon.com/chart/index.htm.json").read
        result = JSON.parse(link)
        rank = result['songList'][num.to_i - 1]['curRank']
        artist = result['songList'][num.to_i - 1]['artistNameBasket']
        song = result['songList'][num.to_i - 1]['songName']
        m.reply "Melon Rank #{rank}: #{artist} - #{song}"
      end

      def help(m)
        m.reply 'returns current song at specified melon rank'
      end

    end
  end
end
