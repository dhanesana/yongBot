require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Agb
      include Cinch::Plugin

      match /(agb)$/
      match /(agb) (.+)/, method: :with_num
      match /(help agb)$/, method: :help

      def execute(m)
        with_num(m, '.', 'agb', 1)
      end

      def with_num(m, prefix, agb, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 21 bru' if num.to_i > 20
        rank = num.to_i
        page = Nokogiri::HTML(open('http://www.nielsenkorea.co.kr/tv_terrestrial_day.asp?menu=Tit_1&sub_menu=1_1&area=00'))
        date = page.css('td.ranking_date').text.strip
        station = page.css('table.ranking_tb tr td.tb_txt_center')[rank * 2 - 1].text.strip
        title = page.css('table.ranking_tb').first.css('td.tb_txt')[rank - 1].text.strip
        rating = page.css('table.ranking_tb').first.css('td.percent')[rank - 1].text.strip if rank <= 10
        rating = page.css('table.ranking_tb td.percent_g')[rank - 11].text.strip if rank > 10
        m.reply "#{date} AGB Nielson Rank #{rank}: #{station} - #{title}, Rating: #{rating}"
      end

      def help(m)
        m.reply 'returns tv show at specified daily agb nielson rank'
      end

    end
  end
end
