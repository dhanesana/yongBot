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
              guests = []
              groups = [""]
              counter = 0
              row.css('td')[1].children.each do |person|
                next if person.text == ""
                next if person.text == ","
                next if person.text == "\n"
                next if person.text.to_i > 0
                next if person.text[0] == "["
                # if the guest isn't a group
                if person.children.size < 2
                  counter += 1 if person.text == " ("
                  next if counter == 1
                  next if person.text == " ("
                  counter = 0 if person.text == "),"
                  counter = 0 if person.text == ")"
                  next if person.text == "),"
                  next if person.text == ")"
                  guests << person.text
                end
                # if the guest is a group
                if person.children.size > 2
                  person.children.each do |child|
                    next if child.text == ""
                    next if child.text == ","
                    next if child.text == "\n"
                    next if child.text.include? "\n"
                    group_name = child.text
                    group_name[-1] = ""
                    groups << group_name
                  end
                end
              end
              lineup << "[#{date} => #{guests.join(', ')}#{groups.join(', ')}]"
            end
          end
        end
        m.reply lineup.join(", ") + " 18:25KST"
      end

      def help(m)
        m.reply "returns current month's schedule for sbs running man"
      end

    end
  end
end
