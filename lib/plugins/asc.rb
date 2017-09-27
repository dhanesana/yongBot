require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Asc
      include Cinch::Plugin

      match /(asc)$/
      match /(help asc)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://www.arirang.co.kr/Tv2/Tv_PlusHomepage_Full.asp?PROG_CODE=TVCR0688&MENU_CODE=101717&sys_lang=Eng'))
        sched_time = page.css('p.ment').first.text.strip
        guest = page.css('div.ahtml_h1').text
        date = page.css('.h4date').first.text.strip
        m.reply "After School Club - #{guest} | #{sched_time}, #{date}"
      end

      def help(m)
        m.reply 'returns summary for upcoming arirang after school club episode'
      end

    end
  end
end
