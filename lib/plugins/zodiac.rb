require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Zodiac
      include Cinch::Plugin

      match /(zodiac)$/
      match /(zodiac) (.+)/, method: :with_sign
      match /(help zodiac)$/, method: :help

      def execute(m)
        m.reply "specify ur sign bru (ex. .zodiac sheep)"
      end

      def with_sign(m, prefix, zodiac, sign)
        page = Nokogiri::HTML(open("http://www.astrology.com/horoscope/daily-chinese/#{sign}.html"))
        text = page.css('div.page-horoscope-text').first.text
        date = page.css('span.page-horoscope-date-font').first.text
        m.reply "[#{date}] #{text}"
      end

      def help(m)
        m.reply 'returns ur daily chinese horoscope for those that are into that kinda thing'
      end

    end
  end
end
