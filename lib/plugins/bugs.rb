require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Bugs
      include Cinch::Plugin

      match /(bugs)$/
      match /(bugs) (.+)/, method: :with_num
      match /(help bugs)$/, method: :help

      def execute(m)
        with_num(m, '.', 'bugs', 1)
      end

      def with_num(m, prefix, bugs, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 11 bru' if num.to_i > 10
        page = Nokogiri::HTML(open("http://www.bugs.co.kr/"))
        date_time = page.css('time').first.text + "KST"
        num = 1
        title = page.css('div.chartContainer p.title')[num - 1].text.strip
        artist = page.css('div.chartContainer p.artist')[num - 1].text.strip
        m.reply "Bugs Rank #{num}: #{artist} - #{title} | #{date_time}"
      end

      def help(m)
        m.reply 'returns current song at specified bugs rank'
      end

    end
  end
end
