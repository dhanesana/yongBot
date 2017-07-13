require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Soundk
      include Cinch::Plugin

      match /(soundk)$/
      match /(help soundk)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://www.arirang.com/Radio/Radio_Announce.asp?PROG_CODE=RADR0147&MENU_CODE=101562&code=Be4'))
        lineup = []
        page.css('table.annlistTbl').first.css('td').each do |td|
          next if td.text[0].to_i == 0
          lineup << td.text if td.text.include? '/'
        end
        air_time = page.css('div.airtime p').first.text + 'KST'
        m.reply "[#{lineup.join('], [')}] #{air_time}"
      end

      def help(m)
        m.reply 'returns upcoming schedule for arirang sound k'
      end

    end
  end
end
