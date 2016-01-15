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

      def initialize(*args)
        super
        begin
        @page = Nokogiri::HTML(open('http://www.powerball.com/pb_home.asp'))
        @draw_date = @page.css('font').first.text
        @jackpot = @page.css('strong')[6].text
        rescue Errno::ETIMEDOUT
          puts '*' * 50
          puts "Connection to http://powerball.com/ timed out"
          puts '*' * 50
        rescue Errno::ECONNRESET
          puts '*' * 50
          puts 'Connection reset by peer'
          puts '*' * 50
        rescue OpenURI::HTTPError => error
          response = error.io
          puts 'powerball.rb'
          puts '*' * 50
          puts response.status
            # => ["503", "Service Unavailable"]
        end
      end

      def execute(m)
        m.reply "#{@draw_date} => #{draw(1)}, #{draw(2)}, #{draw(3)}, #{draw(4)}, #{draw(5)}, [#{draw(6)}]"
      end

      def jackpot(m)
        m.reply "Current Estimated Powerball Jackpot: #{@jackpot}"
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

      def draw(num)
        @page.css('strong')[num - 1].text
      end

      def help(m)
        m.reply ".powerball => latest winning numbers, .jackpot => current estimated jackpot, .quickpick => random generated quick pick"
      end

    end
  end
end
