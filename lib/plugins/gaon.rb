require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Gaon
      include Cinch::Plugin

      match /(gaon)$/, prefix: /^(\.)/
      match /(gaon) (.+)/, method: :with_num, prefix: /^(\.)/
      match /(help gaon)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        page = Nokogiri::HTML(open('http://gaonchart.co.kr/main/section/chart/online.gaon?serviceGbn=ALL&termGbn=week&hitYear=2015&targetTime=&nationGbn=K'))
        title = page.css('td.subject')[0].css('p').first.text
        artist = page.css('td.subject')[0].css('p')[1].text
        artist = artist.slice(0..(artist.index('|') - 1))
        m.reply "Gaon Rank 1: #{title} by #{artist}"
      end

      def with_num(m, prefix, gaon, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        page = Nokogiri::HTML(open('http://gaonchart.co.kr/main/section/chart/online.gaon?serviceGbn=ALL&termGbn=week&hitYear=2015&targetTime=&nationGbn=K'))
        rank = num.to_i - 1
        title = page.css('td.subject')[rank].css('p').first.text
        artist = page.css('td.subject')[rank].css('p')[1].text
        artist = artist.slice(0..(artist.index('|') - 1))
        m.reply "Gaon Rank #{num}: #{title} by #{artist}"
      end

      def help(m)
        m.reply 'returns song at specified weekly gaon rank'
      end

    end
  end
end
