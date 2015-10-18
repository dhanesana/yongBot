module Cinch
  module Plugins
    class Roll
      include Cinch::Plugin

      match /(roll)$/, prefix: /^(\.)/
      match /(help roll)$/, method: :help, prefix: /^(\.)/

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
          return m.reply "u alrdy rolled stupee" if game[@rolls].keys.include? m.user.nick
          if game[@tie] == 0
            die_1 = rand(1..6)
            die_2 = rand(1..6)
            @all_games[channel]
            game[@rolls][m.user.nick] = die_1 + die_2
            m.reply "#{m.user.nick}: [ #{die_1} ] [ #{die_2} ]"
          else
            return m.reply "u alrdy rolled stupee" if game[@rolls].keys.include? m.user.nick
            if game[@winners].keys.include? m.user.nick
              die_1 = rand(1..6)
              die_2 = rand(1..6)
              game[@rolls][m.user.nick] = die_1 + die_2
              m.reply "#{m.user.nick}: [ #{die_1} ] [ #{die_2} ]"
            else
              m.reply "u not in the tiebreak stupee"
            end
          end
        else
          @all_games[channel] = [{}, {}, 0]
          die_1 = rand(1..6)
          die_2 = rand(1..6)
          @all_games[channel][@rolls] = { m.user.nick => die_1 + die_2 }
          m.reply "15 Seconds! #{m.user.nick}: [ #{die_1} ] [ #{die_2} ]"
          game_start(m)
        end
      end

      def game_start(m)
        Timer(15, options = { shots: 1 }) do |x|
          game = @all_games[m.channel.name]
          game[@winners] = game[@rolls].select { |k, v| v == game[@rolls].values.max }
          if game[@winners].size == 1
            m.reply "Winner: #{game[@winners].keys.join}!"
            @all_games.delete(m.channel.name)
          else
            game[@tie] = 1
            game[@rolls] = {}
            m.reply "Tiebreak! 15 seconds! GO #{game[@winners].keys.join(', ')}!"
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
            return m.reply 'times up: u all lose'
          end
          if game[@winners].size < 2
            m.reply "Winner: #{game[@winners].keys.join}!"
            @all_games.delete(m.channel.name)
          else
            game[@tie] = 1
            game[@rolls] = {}
            m.reply "Another Tie! 15 seconds! GO #{game[@winners].keys.join(', ')}!"
            tie_break(m)
          end
        end
      end

      def help(m)
        m.reply "simple 15-second dice rolling game with tiebreak rounds"
      end

    end
  end
end
