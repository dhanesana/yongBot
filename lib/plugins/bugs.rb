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
        return m.reply 'less than 11 bru' if num.to_i > 100
        page = Nokogiri::HTML(open("http://music.bugs.co.kr/chart/track/realtime/total"))
        date = page.css('time').first.children.first.text.strip
        time = page.css('time em').first.text
        title = page.css('div#CHARTrealtime p.title')[num.to_i - 1].text.strip
        artist = page.css('div#CHARTrealtime p.artist')[num.to_i - 1].text.strip
        m.reply "Bugs Rank #{num}: #{artist} - #{title} | #{date} #{time}KST"
      end

      def help(m)
        m.reply 'returns current song at specified bugs realtime rank'
      end

    end
  end
end
