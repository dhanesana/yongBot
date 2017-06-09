require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Powerball
      include Cinch::Plugin

      match /(powerball)$/
      match /(jackpot)$/, method: :jackpot
      match /(quickpick)$/, method: :quickpick
      match /(help powerball)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://www.powerball.com/pb_home.asp'))
        draw_date = page.css('font').first.text
        m.reply "#{draw_date} => #{draw(page, 1)}, #{draw(page, 2)}, #{draw(page, 3)}, #{draw(page, 4)}, #{draw(page, 5)}, [#{draw(page, 6)}]"
      end

      def draw(page, num)
        page.css('strong')[num - 1].text
      end

      def jackpot(m)
        page = Nokogiri::HTML(open('http://www.powerball.com/pb_home.asp'))
        jackpot = page.css('strong')[6].text
        cash_val = page.css('font')[10].text
        m.reply "Current Estimated Powerball Jackpot: #{jackpot} (#{cash_val})"
      end

      def quickpick(m)
        other_nums = []
        loop do
          num = rand(1..69)
          other_nums << num unless other_nums.include? num
          break if other_nums.size > 4
        end
        m.reply "Quick Pick => #{other_nums.join(', ')}, [#{rand(1..26)}]"
      end

      def help(m)
        m.reply ".powerball => latest winning numbers, .jackpot => current estimated jackpot, .quickpick => random generated quick pick"
      end

    end
  end
end
