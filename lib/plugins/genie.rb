require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Genie
      include Cinch::Plugin

      match /(genie)$/
      match /(genie) (.+)/, method: :with_num
      match /(help genie)$/, method: :help

      def execute(m)
        with_num(m, '.', 'genie', 1)
      end

      def with_num(m, prefix, genie, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 21 bru' if num.to_i > 50
        page = Nokogiri::HTML(open("http://www.genie.co.kr/chart/f_top_100.asp"))
        title  = page.css('span.music_area a.title')[num.to_i].text
        artist = page.css('span.music_area a.artist')[num.to_i].text
        date   = page.css('div.chart-date input#curDateComma').first.values.last
        hour   = page.css('div.chart-date input#strHH').first.values.last
        m.reply "Genie Rank #{num}: #{artist} - #{title} | #{date} #{hour}:00KST"
      end

      def help(m)
        m.reply 'returns current song at specified genie rank'
      end

    end
  end
end
