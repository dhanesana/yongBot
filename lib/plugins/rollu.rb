# korean translations by hg4wee
module Cinch
  module Plugins
    class Rollu
      include Cinch::Plugin

      match /(rollu)$/, prefix: /^(\.)/
      match /(help rollu)$/, method: :help, prefix: /^(\.)/

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
          return m.reply "이미 주사위 굴렸어 멍충아!" if game[@rolls].keys.include? m.user.nick
          if game[@tie] == 0
            die_1 = rand(1..6)
            die_2 = rand(1..6)
            @all_games[channel]
            game[@rolls][m.user.nick] = die_1 + die_2
            m.reply "#{m.user.nick}: [ #{tr(die_1)} ] [ #{tr(die_2)} ]"
          else
            return m.reply "이미 주사위 굴렸어 멍충아!" if game[@rolls].keys.include? m.user.nick
            if game[@winners].keys.include? m.user.nick
              die_1 = rand(1..6)
              die_2 = rand(1..6)
              game[@rolls][m.user.nick] = die_1 + die_2
              m.reply "#{m.user.nick}: [ #{tr(die_1)} ] [ #{tr(die_2)} ]"
            else
              m.reply "연장전에 끼어들지마 멍충아"
            end
          end
        else
          @all_games[channel] = [{}, {}, 0]
          die_1 = rand(1..6)
          die_2 = rand(1..6)
          @all_games[channel][@rolls] = { m.user.nick => die_1 + die_2 }
          m.reply "15초! #{m.user.nick}: [ #{tr(die_1)} ] [ #{tr(die_2)} ]"
          game_start(m)
        end
      end

      def game_start(m)
        Timer(15, options = { shots: 1 }) do |x|
          game = @all_games[m.channel.name]
          game[@winners] = game[@rolls].select { |k, v| v == game[@rolls].values.max }
          if game[@winners].size == 1
            m.reply "승자: #{game[@winners].keys.join}!"
            @all_games.delete(m.channel.name)
          else
            game[@tie] = 1
            game[@rolls] = {}
            m.reply "연장전! 15초! GO #{game[@winners].keys.join(', ')}!"
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
            return m.reply '시간초과: 모두 망'
          end
          if game[@winners].size < 2
            m.reply "승자: #{game[@winners].keys.join}!"
            @all_games.delete(m.channel.name)
          else
            game[@tie] = 1
            game[@rolls] = {}
            m.reply "다시 연장전! 15초! GO #{game[@winners].keys.join(', ')}!"
            tie_break(m)
          end
        end
      end

      def tr(num)
        return '하나' if num == 1
        return '둘' if num == 2
        return '셋' if num == 3
        return '넷' if num == 4
        return '다섯' if num == 5
        return '여섯' if num == 6
      end

      def help(m)
        m.reply "simple 15-second dice rolling game with tiebreak rounds (for those learning korean)"
      end

    end
  end
end
