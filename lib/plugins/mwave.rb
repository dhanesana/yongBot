require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class Mwave
      include Cinch::Plugin

      match /(mwave)$/
      match /(mwave) (.+)/, method: :with_num
      match /(help mwave)$/, method: :help

      def execute(m)
        with_num(m, '.', 'mwave', 1)
      end

      def with_num(m, prefix, mwave, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 51 bru' if num.to_i > 50
        link = open("http://mwave.interest.me/mcountdown/vote/mcdChart.json").read
        result = JSON.parse(link)
        if num.to_i <= 3
          rank   = result['top3McountdownCharts'][num.to_i - 1]['RANKING']
          song   = result['top3McountdownCharts'][num.to_i - 1]['SONG_NM']
          artist = result['top3McountdownCharts'][num.to_i - 1]['artistInfos'].first['ARTIST_NM']
          date   = result['mcountdownChartPrevNextDate']['votePeriod']
        else
          rank   = result['othersMcountdownCharts'][num.to_i - 4]['RANKING']
          song   = result['othersMcountdownCharts'][num.to_i - 4]['SONG_NM']
          artist = result['othersMcountdownCharts'][num.to_i - 4]['artistInfos'].first['ARTIST_NM']
          date   = result['mcountdownChartPrevNextDate']['votePeriod']
        end
          m.reply "Mwave Rank #{rank}: #{artist} - #{song} | #{date}"
      end

      def help(m)
        m.reply 'returns current song at specified mcountdown rank'
      end

    end
  end
end
