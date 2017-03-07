require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Olleh
      include Cinch::Plugin

      match /(olleh)$/
      match /(olleh) (.+)/, method: :with_num
      match /(help olleh)$/, method: :help

      def execute(m)
        with_num(m, '.', 'olleh', 1)
      end

      def with_num(m, prefix, olleh, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 101 bru' if num.to_i > 100
        chart_url = "https://www.ollehmusic.com/Ranking/f_RealTimeRankingList.asp"
        chart_url += "?pageno=2" if num.to_i > 50
        subtrahend = 1
        subtrahend += 50 if num.to_i > 50
        page = Nokogiri::HTML(open(chart_url))
        date = page.css('div.cur_date div.time_1').first.text.strip
        time = page.css('div.cur_time').first.text.strip
        artist = page.css('table.realtimechart p.artist a')[num.to_i - subtrahend].text
        title = page.css('table.realtimechart p.title a.titletxt')[num.to_i - subtrahend].text
        m.reply "Olleh Rank #{num}: #{artist} - #{title} | #{date} #{time}KST"
      end

      def help(m)
        m.reply 'returns current song at specified olleh realtime rank'
      end

    end
  end
end
