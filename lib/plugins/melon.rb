require 'open-uri'
require 'json'
require 'fuzzystringmatch'

module Cinch
  module Plugins
    class Melon
      include Cinch::Plugin

      match /(melon)$/
      match /(melon) (.+)/, method: :with_entry
      match /(melon trend)$/, method: :trend
      match /(melon trend) (.+)/, method: :trend_num
      match /(help melon)$/, method: :help

      def execute(m)
        with_entry(m, '.', 'melon', '1')
      end

      def with_entry(m, prefix, melon, entry)
        return if entry.include? 'trend'
        return m.reply '1-100 only bru' if entry.to_i > 100
        return m.reply '1-100 only bru' if entry == '0'
        return m.reply 'invalid num bru' if entry.to_i < 0
        link = open("http://www.melon.com/chart/index.htm.json").read
        result = JSON.parse(link)
        if !/\A\d+\z/.match(entry)
          all_songs = Hash.new
          jarow_matches = Hash.new
          result['songList'].each do |song|
            all_songs[song['curRank']] = song['songName']
            jarow = FuzzyStringMatch::JaroWinkler.create( :pure )
            all_songs.keys.each do |key|
              jarow_matches[key] = jarow.getDistance(entry.downcase, all_songs[key].downcase)
            end
          end
            match = jarow_matches.max_by{ |k, v| v }
            rank = result['songList'][match.first.to_i - 1]['curRank']
            artist = result['songList'][match.first.to_i - 1]['artistNameBasket']
            title = result['songList'][match.first.to_i - 1]['songName']
            return m.reply "Melon Rank #{rank}: #{artist} - #{title}"
        else
          rank = result['songList'][entry.to_i - 1]['curRank']
          artist = result['songList'][entry.to_i - 1]['artistNameBasket']
          title = result['songList'][entry.to_i - 1]['songName']
          return m.reply "Melon Rank #{rank}: #{artist} - #{title}"
        end
        m.reply 'no results in top 100 bru'
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
