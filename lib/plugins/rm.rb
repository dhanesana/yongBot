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
              date = row.css('td')[0].text.strip
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
                  counter = 0 if person.text == "),"
                  counter = 0 if person.text == ")"
                  counter += 1 if person.text == " ("
                  next if counter == 1
                  next if person.text == " ("
                  next if person.text == ""
                  next if person.text == "),"
                  next if person.text == ")"
                  guests[-1] += person.text if person.text[0] == "'"
                  next if person.text[0] == "'"
                  guests << person.text.chomp(',').strip
                end
                # if the guest is a group
                if person.children.size > 2
                  person.children.each do |child|
                    next if child.text == ""
                    next if child.text == ","
                    next if child.text == "\n"
                    next if child.text.include? "\n"
                    groups[-1] += child.text.strip if child.text.strip == '('
                    groups[-1] += child.text.strip if child.text.strip == ')'
                    groups[-1] += "#{child.text.strip} " if child.text.strip == ','
                    next if child.text.strip == "("
                    next if child.text.strip == ")"
                    next if child.text.strip == ","
                    group_name = child.text
                    group_name.chomp!(',')
                    groups << group_name.strip
                  end
                end
              end
              # if a guest has a description within parenthesis
              guests.each do |guest|
                if guest[-1] == "("
                  init_index = guests.index(guest)
                  guests[init_index + 1].insert(0, guest)
                  guests[init_index + 1].insert(0, "(")
                  guests[init_index + 1].chomp!(',')
                  guests.delete_at(init_index)
                end
              end
              lineup << "[#{date} => #{guests.join(', ')}#{groups.join}]"
            end
          end
        end
        m.reply lineup.join(", ")
      end

      def help(m)
        m.reply "returns current month's schedule for sbs running man"
      end

    end
  end
end
