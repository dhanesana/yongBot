require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Horo
      include Cinch::Plugin

      match /(horo)$/
      match /(horo) (.+)/, method: :with_sign
      match /(help horo)$/, method: :help

      def execute(m)
        m.reply "specify ur astrological sign bru (ex. .horo pisces)"
      end

      def with_sign(m, prefix, horo, sign)
        begin
          page = Nokogiri::HTML(open("http://new.theastrologer.com/#{sign}/"))
          text = page.css('div#today p').first.text
          date = page.css('div#today div.daily-horoscope-date').first.text
          m.reply "[#{date}] #{text}"
        rescue OpenURI::HTTPError => e
          m.reply "404 Error: Check spelling"
          p '*' * 50
          p '.horo error'
          p e.message
          p '*' * 50
        end
      end

      def help(m)
        m.reply 'returns ur daily horoscope for those that are into that kinda thing'
      end

    end
  end
end
