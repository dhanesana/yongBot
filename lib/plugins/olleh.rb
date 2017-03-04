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
        return m.reply 'less than 11 bru' if num.to_i > 50
        page = Nokogiri::HTML(open("https://www.ollehmusic.com/Ranking/f_RealTimeRankingList.asp"))
        date = page.css('div.cur_date div.time_1').first.text.strip
        time = page.css('div.cur_time').first.text.strip
        artist = page.css('table.realtimechart p.artist a')[num - 1].text
        title = page.css('table.realtimechart p.title a.titletxt')[num - 1].text
        m.reply "Olleh Rank #{num}: #{artist} - #{title} | #{date} #{time}KST"
      end

      def help(m)
        m.reply 'returns current song at specified olleh realtime rank'
      end

    end
  end
end
