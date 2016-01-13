require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Rm
      include Cinch::Plugin

      match /(rm)$/
      match /(help rm)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('https://en.wikipedia.org/wiki/List_of_Running_Man_episodes'))
        kst = Time.now.utc + (9 * 3600)
        month = kst.strftime("%B")
        year = kst.strftime("%Y")
        lineup = []
        page.css('tr').each do |row|
          next if row.css('td')[2].nil?
          if row.css('td')[0].text.include? month
            if row.css('td')[0].text.include? year
              date = row.css('td')[0].text
              # Slice broadcast date and omit filming date
              date = date.slice(0..(date.index("\n") - 1)) if date.include? "\n"
              guests = row.css('td')[1].text.split(",\n").join(', ')
              guests = guests.slice(0..(guests.index('[') - 1)) if guests.include? '['
              lineup << "[#{date} => #{guests}]"
            end
          end
        end
        m.reply lineup.join(", ") + " 16:50KST"
      end

      def help(m)
        m.reply "returns current month's schedule for sbs running man"
      end

    end
  end
end
