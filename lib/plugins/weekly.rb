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
        kst = Time.now.utc + (9 * 3600) # 3600 seconds in an hour
        next_week = kst + 604800 # 604800 seconds in a week
        months = []
        years = []
        months << kst.strftime("%B")
        months << next_week.strftime("%B") unless months.include? next_week.strftime("%B")
        years << kst.strftime("%Y")
        years << next_week.strftime("%Y") unless years.include? next_week.strftime("%Y")
        lineup = []
        months.each do |month|
          page.css('tr').each do |row|
            next if row.css('td')[1].nil?
            if row.css('td')[1].text.include? month
              years.each do |year|
                if row.css('td')[1].text.include? year
                  lineup << "[#{row.css('td')[1].text} => #{row.css('td')[2].text}]" unless row.css('td')[2].nil?
                end
              end
            end
          end
        end
        m.reply lineup.join(", ") + " 18:00KST"
      end

      def help(m)
        m.reply "returns current month's and next week's schedule for mbc weekly idol"
      end

    end
  end
end
