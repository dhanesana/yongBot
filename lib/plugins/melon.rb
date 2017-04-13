require 'open-uri'
require 'json'
require 'fuzzy_match'

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
        with_num(m, '.', 'melon', '1')
      end

      def with_num(m, prefix, melon, entry)
        return if entry.include? 'trend'
        return m.reply '1-100 only bru' if entry.to_i > 100
        return m.reply '1-100 only bru' if entry == '0'
        return m.reply 'invalid num bru' if entry.to_i < 0
        link = open("http://www.melon.com/chart/index.htm.json").read
        result = JSON.parse(link)
        if !/\A\d+\z/.match(entry) # if entry is not a number
          with_entry(m, result, entry)
        else
          rank = result['songList'][entry.to_i - 1]['curRank']
          artist = result['songList'][entry.to_i - 1]['artistNameBasket']
          title = result['songList'][entry.to_i - 1]['songName']
          return m.reply "Melon Rank #{rank}: #{artist} - #{title}"
        end
      end

      def with_entry(m, result, entry)
        all_songs = Hash.new
        all_titles = Array.new
        result['songList'].each do |song|
          all_titles << song['songName'].downcase
          all_songs[song['curRank']] = song['songName'].downcase
        end
        match = FuzzyMatch.new(all_titles).find(entry.downcase)
        match_rank = all_songs.key(match).to_i
        rank = result['songList'][match_rank - 1]['curRank']
        artist = result['songList'][match_rank - 1]['artistNameBasket']
        title = result['songList'][match_rank - 1]['songName']
        m.reply "Melon Rank #{rank}: #{artist} - #{title}"
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
