require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Kpoppin
      include Cinch::Plugin

      match /(kpoppin)$/
      match /(help kpoppin)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open("http://www.arirang.com/Radio/Radio_Announce.asp?PROG_CODE=RADR0143&MENU_CODE=101536&code=Be4"))
        # lineup = []
        # page.css('table.annlistTbl').first.css('td').each do |td|
        #   next if td.text.include? 'PLAY MY STAR' # No guest appearance
        #   next unless td.text.include? '('
        #   lineup << td.text.strip
        # end
        air_time = page.css('div.airtime p').first.text.strip + 'KST'
        # m.reply "[#{lineup.reverse.join('], [')}] #{air_time}"
        href = "No upcoming guests announced"
        page.css('table.annlistTbl a').each do |topic|
          href = "http://www.arirang.com" + topic.values.first if topic.text.downcase.include? 'guest'
        end
        m.reply "[#{href}] #{air_time}"
      end

      def help(m)
        m.reply 'returns upcoming schedule for arirang k-poppin'
      end

    end
  end
end
