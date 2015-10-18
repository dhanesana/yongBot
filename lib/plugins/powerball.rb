require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Powerball
      include Cinch::Plugin

      match /(powerball)$/
      match /(jackpot)$/, method: :jackpot
      match /(quickpick)$/, method: :quickpick
      match /(help powerball)$/, method: :help

      def initialize(*args)
        super
        @page = Nokogiri::HTML(open('http://powerball.com/'))
        @draw_date = @page.css('font').first.text
        @jackpot = @page.css('strong')[6].text
      end

      def execute(m)
        m.reply "#{@draw_date} => #{draw(1)}, #{draw(2)}, #{draw(3)}, #{draw(4)}, #{draw(5)}, [#{draw(6)}]"
      end

      def jackpot(m)
        m.reply "Current Estimated Powerball Jackpot: #{@jackpot}"
      end

      def quickpick(m)
        m.reply "Quick Pick => #{rand(1..59)}, #{rand(1..59)}, #{rand(1..59)}, #{rand(1..59)}, #{rand(1..59)}, [#{rand(1..35)}]"
      end

      def draw(num)
        @page.css('strong')[num - 1].text
      end

      def help(m)
        m.reply ".powerball => latest winning numbers, .jackpot => current estimated jackpot, .quickpick => random generated quick pick"
      end

    end
  end
end
