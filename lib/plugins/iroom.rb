require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Iroom
      include Cinch::Plugin

      match /(iroom)$/
      match /(idol room)$/
      match /(help iroom)$/, method: :help
      match /(help idol room)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('https://en.wikipedia.org/wiki/Idol_Room'))
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
            if row.css('td')[0].text.strip.include? month
              years.each do |year|
                if row.css('td')[0].text.include? year
                  date = row.css('td')[0].text.strip
                  lineup << "[#{date.slice(0..(date.index('(') - 1))} => #{row.css('td')[1].text.strip}]" unless row.css('td')[1].nil?
                end
              end
            end
          end
        end
        return m.reply "Idol Room: [No guests or a continuation of previous episode]" if lineup == []
        m.reply "Idol Room: #{lineup.join(', ')}"
      end

      def help(m)
        m.reply "returns current month's and next week's schedule for jtbc idol room"
      end

    end
  end
end
