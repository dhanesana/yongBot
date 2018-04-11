require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class Powerball
      include Cinch::Plugin

      match /(powerball)$/
      match /(jackpot)$/, method: :jackpot
      match /(quickpick)$/, method: :quickpick
      match /(help powerball)$/, method: :help

      def execute(m)
       feed = open('https://www.powerball.com/api/v1/numbers/powerball/recent10?_format=json').read
       result = JSON.parse(feed)
       draw_date = result.first['field_draw_date']
       win_nums = result.first['field_winning_numbers']
       power_play = result.first['field_multiplier']
       m.reply "Winning Numbers #{draw_date} => #{win_nums} [Power Play #{power_play}X]"
      end

      def jackpot(m)
        feed = open('https://www.powerball.com/api/v1/estimates/powerball?_format=json').read
        result = JSON.parse(feed)
        m.reply "#{result.first['title']}: #{result.first['field_prize_amount']} (#{result.first['field_prize_amount_cash']} Cash)"
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
