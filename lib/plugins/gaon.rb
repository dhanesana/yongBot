require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Gaon
      include Cinch::Plugin

      match /(gaon)$/
      match /(gaon) (.+)/, method: :with_num
      match /(help gaon)$/, method: :help

      def execute(m)
        with_num(m, '.', 'gaon', 1)
      end

      def with_num(m, prefix, gaon, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        page = Nokogiri::HTML(open('http://gaonchart.co.kr/main/section/chart/online.gaon?nationGbn=T&serviceGbn=ALL'))
        rank = num.to_i - 1
        title = page.css('td.subject')[rank].css('p').first.text
        artist = page.css('td.subject')[rank].css('p')[1].text
        artist = artist.slice(0..(artist.index('|') - 1))
        m.reply "Gaon Rank #{num}: #{title} by #{artist}"
      end

      def help(m)
        m.reply 'returns song at specified weekly gaon digital chart rank'
      end

    end
  end
end
