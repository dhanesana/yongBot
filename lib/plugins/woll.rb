# chinese translations by fiveseven_
module Cinch
  module Plugins
    class Woll
      include Cinch::Plugin

      match /(woll)$/
      match /(help woll)$/, method: :help

      def initialize(*args)
        super
        @rolls   = 0
        @winners = 1
        @tie     = 2
        @all_games = {}
      end

      def execute(m)
        channel = m.channel.name
        if @all_games.keys.include? channel
          game = @all_games[channel]
          return m.reply "笨蛋，你已經擲了骰子!" if game[@rolls].keys.include? m.user.nick
          if game[@tie] == 0
            die_1 = rand(1..6)
            die_2 = rand(1..6)
            @all_games[channel]
            game[@rolls][m.user.nick] = die_1 + die_2
            m.reply "#{m.user.nick}: [ #{tr(die_1)} ] [ #{tr(die_2)} ]"
          else
            return m.reply "笨蛋，你已經擲了骰子!" if game[@rolls].keys.include? m.user.nick
            if game[@winners].keys.include? m.user.nick
              die_1 = rand(1..6)
              die_2 = rand(1..6)
              game[@rolls][m.user.nick] = die_1 + die_2
              m.reply "#{m.user.nick}: [ #{tr(die_1)} ] [ #{tr(die_2)} ]"
            else
              m.reply "你不在決勝局"
            end
          end
        else
          @all_games[channel] = [{}, {}, 0]
          die_1 = rand(1..6)
          die_2 = rand(1..6)
          @all_games[channel][@rolls] = { m.user.nick => die_1 + die_2 }
          m.reply "15秒! #{m.user.nick}: [ #{tr(die_1)} ] [ #{tr(die_2)} ]"
          game_start(m)
        end
      end

      def game_start(m)
        Timer(15, options = { shots: 1 }) do |x|
          game = @all_games[m.channel.name]
          game[@winners] = game[@rolls].select { |k, v| v == game[@rolls].values.max }
          if game[@winners].size == 1
            m.reply "冠軍: #{game[@winners].keys.join}!"
            @all_games.delete(m.channel.name)
          else
            game[@tie] = 1
            game[@rolls] = {}
            m.reply "決勝局! 15秒! 開始 #{game[@winners].keys.join(', ')}!"
            tie_break(m)
          end
        end
      end

      def tie_break(m)
        Timer(15, options = { shots: 1 }) do |x|
          game = @all_games[m.channel.name]
          game[@winners] = game[@rolls].select { |k, v| v == game[@rolls].values.max }
          if game[@rolls].size == 0
            @all_games.delete(m.channel.name)
            return m.reply '時間到了： 大家輸掉了'
          end
          if game[@winners].size < 2
            m.reply "冠軍: #{game[@winners].keys.join}!"
            @all_games.delete(m.channel.name)
          else
            game[@tie] = 1
            game[@rolls] = {}
            m.reply "決勝局！ 15秒！ 開始 #{game[@winners].keys.join(', ')}!"
            tie_break(m)
          end
        end
      end

      def tr(num)
        return '一' if num == 1
        return '二' if num == 2
        return '三' if num == 3
        return '四' if num == 4
        return '五' if num == 5
        return '六' if num == 6
      end

      def help(m)
        m.reply "簡單骰子遊戲"
      end

    end
  end
end
