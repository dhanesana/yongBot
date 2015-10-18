require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Asc
      include Cinch::Plugin

      match /(asc)$/, prefix: /^(\.)/
      match /(help asc)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        page = Nokogiri::HTML(open('http://www.arirang.co.kr/Tv2/Tv_PlusHomepage_Full.asp?PROG_CODE=TVCR0688&MENU_CODE=101717&sys_lang=Eng'))
        date = page.css('div.ahtml_h2').text
        guest = page.css('div.ahtml_h1').text
        m.reply "After School Club - #{guest} | #{date}"
      end

      def help(m)
        m.reply 'returns summary for upcoming arirang after school club episode'
      end

    end
  end
end
