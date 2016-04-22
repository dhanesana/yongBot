require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Kcon
      include Cinch::Plugin

      match /(kcon)$/
      match /(kcon) (.+)/, method: :with_city
      match /(help kcon)$/, method: :help

      def execute(m)
        m.reply "pls specify city (ie. LA or NY)"
      end

      def with_city(m, prefix, kcon, city)
        begin
        city_abbrev = city.split(/[[:space:]]/).join(' ').downcase
        page = Nokogiri::HTML(open("http://www.kconusa.com/kcon-#{city_abbrev}-artists/"))
        rescue OpenURI::HTTPError => e
          return m.reply '404: no page found for specified city bru'
        end
        lineup = []
        page.css('div.wpb_wrapper h3 a').each do |act|
          next if act.text == ""
          lineup << act.text
        end
        m.reply "KCON #{city_abbrev.upcase}: #{lineup.join(', ')}"
      end

      def help(m)
        m.reply 'returns recent/upcoming lineup for kcon usa'
      end

    end
  end
end
