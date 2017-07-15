require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Superkpop
      include Cinch::Plugin

      match /(superkpop)$/
      match /(help superkpop)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open("http://www.arirang.com/Radio/Radio_Announce.asp?PROG_CODE=RADR0155&MENU_CODE=101733&code=Be4"))
        lineup = []
        page.css('table.annlistTbl').first.css('td').each do |td|
          next unless td.text.include? '('
          lineup << td.text
        end
        air_time = page.css('div.airtime p').first.text + 'KST'
        m.reply "[#{lineup.join('], [')}] #{air_time}"
      end

      def help(m)
        m.reply 'returns upcoming schedule for arirang super k-pop'
      end

    end
  end
end
