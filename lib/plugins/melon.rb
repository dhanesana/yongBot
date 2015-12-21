require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class Melon
      include Cinch::Plugin

      match /(melon)$/
      match /(melon) (.+)/, method: :with_num
      match /(melon trend)$/, method: :trend
      match /(melon trend) (.+)/, method: :trend_num
      match /(help melon)$/, method: :help

      def execute(m)
        link = open("http://www.melon.com/chart/index.htm.json").read
        result = JSON.parse(link)
        rank = result['songList'][0]['curRank']
        artist = result['songList'][0]['artistNameBasket']
        song = result['songList'][0]['songName']
        m.reply "Melon Rank #{rank}: #{artist} - #{song}"
      end

      def with_num(m, prefix, melon, num)
        return if num.include? 'trend'
        return m.reply '1-100 only bru' if num.to_i > 100
        return m.reply 'invalid num bru' if num.to_i < 1
        link = open("http://www.melon.com/chart/index.htm.json").read
        result = JSON.parse(link)
        rank = result['songList'][num.to_i - 1]['curRank']
        artist = result['songList'][num.to_i - 1]['artistNameBasket']
        song = result['songList'][num.to_i - 1]['songName']
        m.reply "Melon Rank #{rank}: #{artist} - #{song}"
      end

      def trend(m)
        trend_num(m, '.', 'melon trend', 1)
      end

      def trend_num(m, prefix, melon_trend, num)
        return m.reply '1-10 only bru' if num.to_i > 10
        return m.reply 'invalid num bru' if num.to_i < 1
        link = open("http://www.melon.com/search/trend/index.htm.json").read
        result = JSON.parse(link)
        rank = result['keywordRealList'][num.to_i - 1]['ranking']
        keyword = result['keywordRealList'][num.to_i - 1]['keyword']
        m.reply "Melon Trending #{rank}: #{keyword}"
      end

      def help(m)
        m.reply 'returns current song at specified melon rank.'
        m.reply '.melon trend [num] to return keyword(s) at specified melon trending search rank'
      end

    end
  end
end
