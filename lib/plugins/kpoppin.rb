require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Kpoppin
      include Cinch::Plugin

      match /(kpoppin)$/
      match /(help kpoppin)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://www.arirang.co.kr/Radio/Radio_MessageBoard.asp?PROG_CODE=RADR0143&MENU_CODE=101862&code=Be6'))
        text = page.css('tr.ntce td.subjt')[2].text
        lineup = []
        page.css('tr.ntce td.subjt').each do |subject|
          lineup << subject.text if subject.text[0] == '0'
          lineup << subject.text if subject.text[0].to_i > 0
        end
        lineup = ['No guests have been announced'] if lineup.size == 0
        m.reply "[#{lineup.reverse.join('], [')}] 12:00 ~ 14:00KST"
      end

      def help(m)
        m.reply 'returns upcoming schedule for arirang k-poppin'
      end

    end
  end
end
