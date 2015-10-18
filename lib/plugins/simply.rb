require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Simply
      include Cinch::Plugin

      match /(simply)$/, prefix: /^(\.)/
      match /(help simply)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        page = Nokogiri::HTML(open('http://www.arirang.co.kr/Tv2/Tv_PlusHomepage_Full.asp?PROG_CODE=TVCR0636&MENU_CODE=101505&sys_lang=Eng'))
        date = page.css('h4.h4date').text
        episode = page.css('div.ahtml_h0').text
        time = '9:00KST'
        artists = []
        page.css('div.ahtml_h1').each do |artist|
          artists << artist.text.slice(0..(artist.text.index('-') - 2))
        end
        m.reply "#{episode} - #{artists.join(', ')} | #{date} #{time}"
      end

      def help(m)
        m.reply 'returns upcoming lineup for arirang simply k-pop'
      end

    end
  end
end
