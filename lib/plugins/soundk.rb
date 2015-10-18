require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Soundk
      include Cinch::Plugin

      match /(soundk)$/
      match /(help soundk)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://www.arirang.co.kr/Radio/Radio_MessageBoard.asp?PROG_CODE=RADR0147&MENU_CODE=101865&code=Be6'))
        lineup = []
        i = 0
        while i < page.css('tr.ntce td.subjt').size
          lineup << page.css('tr.ntce td.subjt')[i].text unless page.css('tr.ntce td.subjt')[i].text[0].to_i == 0
          i += 1
        end
        m.reply "[#{lineup.join('], [')}] 20:00 ~ 22:00KST"
      end

      def help(m)
        m.reply 'returns upcoming schedule for arirang sound k'
      end

    end
  end
end
