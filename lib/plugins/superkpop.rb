require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Superkpop
      include Cinch::Plugin

      match /(superkpop)$/
      match /(help superkpop)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open("http://www.arirang.com/Radio/Radio_MessageBoard.asp?PROG_CODE=RADR0155&MENU_CODE=102122&code=Be6"))
        response = ""
        page.css('tr.ntce td.subjt').each do |subject|
          break if subject.text.include? "Winner"
          response += "[#{subject.text}] "
        end
        airtime = page.css('div.airtime p').first.text + "KST"
        m.reply response += airtime
      end

      def help(m)
        m.reply 'returns upcoming schedule for arirang super k-pop'
      end

    end
  end
end
