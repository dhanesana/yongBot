require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class P101
      include Cinch::Plugin

      match /(p101)$/
      match /(p101) (.+)/, method: :with_num
      match /(help p101)$/, method: :help

      def execute(m)
        with_num(m, '.', 'p101', 1)
      end

      def with_num(m, prefix, p101, rank)
        return m.reply 'invalid rank bru' if rank == "0"
        return with_name(m, '.', 'p101', rank) if rank.to_i < 1
        return m.reply "there's only 101 bru" if rank.to_i > 101
        page = Nokogiri::HTML(open('http://mnettv.interest.me/produce101/rank.dbp'))
        name = page.css('p.name')[rank.to_i - 1].text
        agency = page.css('p.agency')[rank.to_i - 1].text
        votes = page.css('p.voteCount')[rank.to_i - 1].text
        href = page.css('div.thumb a')[rank.to_i - 1].first[1]
        m.reply "Rank #{rank} - #{name}, Agency: #{agency}, Vote Count: #{votes} http://mnettv.interest.me/#{href}"
      end

      def with_name(m, prefix, p101, name)
        input_array = name.split(/[[:space:]]/)
        input = input_array.join(' ').downcase
        page = Nokogiri::HTML(open('http://mnettv.interest.me/produce101/rank.dbp'))
        count = 0
        page.css('p.name').each do |contestant|
          count += 1 if contestant.text != input
          break if contestant.text == input
        end
        rank = count + 1
        return m.reply "#{name} not found bru" if rank == 102
        with_num(m, '.', 'p101', rank)
      end

      def help(m)
        m.reply 'returns produce101 contestant at specified voting rank or name'
      end

    end
  end
end
