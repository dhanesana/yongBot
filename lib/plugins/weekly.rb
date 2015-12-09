require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Weekly
      include Cinch::Plugin

      match /(weekly)$/
      match /(help weekly)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('https://en.wikipedia.org/wiki/Weekly_Idol'))
        kst = Time.now.utc + (9 * 3600)
        month = kst.strftime("%B")
        year = kst.strftime("%Y")
        lineup = []
        page.css('tr').each do |row|
          next if row.css('td')[1].nil?
          if row.css('td')[1].text.include? month
            if row.css('td')[1].text.include? year
              lineup << "[#{row.css('td')[1].text} => #{row.css('td')[2].text}]"
            end
          end
        end
        m.reply lineup.join(", ") + " 18:00KST"
      end

      def help(m)
        m.reply "returns current month's schedule for mbc weekly idol"
      end

    end
  end
end
