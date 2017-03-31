require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class World
      include Cinch::Plugin

      match /(world)$/
      match /(world) (.+)/, method: :with_num
      match /(help world)$/, method: :help

      def execute(m)
        with_num(m, '.', 'world', 1)
      end

      def with_num(m, prefix, world, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 16 bru' if num.to_i > 15
        page = Nokogiri::HTML(open("http://www.billboard.com/charts/world-albums"))
        title = page.css('.chart-row__song')[num - 1].text.strip
        artist = page.css('.chart-row__artist')[num - 1].text.strip
        date = page.css('time').first.text.strip
        m.reply "Billboard World Albums Rank #{num}: #{title} by #{artist} | Week of #{date}"
      end

      def help(m)
        m.reply 'returns current song at specified billboard world albums rank'
      end

    end
  end
end
