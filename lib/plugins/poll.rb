module Cinch
  module Plugins
    class Poll
      include Cinch::Plugin

      match /(poll) (.+)/, prefix: /^(\.)/
      match /(vote) (.+)/, method: :vote, prefix: /^(\.)/
      match /(help poll)$/, method: :help_poll, prefix: /^(\.)/
      match /(help vote)$/, method: :help_vote, prefix: /^(\.)/

      def initialize(*args)
        super
        @all_games = {}
      end

      def execute(m, prefix, poll, question)
        channel = m.channel.name
        if @all_games.keys.include? channel
          m.reply "there's already a poll stupee"
        else
          m.reply "90 Second Poll: #{question}"
          m.reply 'type .vote [choice] to cast your vote!'
          @all_games[channel] = {}
          Timer(75, options = {shots: 1}) do |x|
            m.reply '15 seconds remaining!'
          end
          Timer(90, options = {shots: 1}) do |x|
            game = @all_games[channel]
            m.reply "no one voted..." if game.size < 1
            return @all_games.delete(channel) if game.size < 1
            m.reply "TIME'S UP"
            results = []
            num = game.values.max { |a, b| a.size <=> b.size }.size
            game.each { |k, v| results << k if v.size == num }
            @all_games.delete(channel)
            return m.reply "Winner: #{results.first}!" if results.size < 2
            m.reply "We have a tie: #{results.join(', ')}"
          end
        end
      end

      def vote(m, prefix, vote, choice)
        # get user address
        user_address = m.prefix.match(/@(.+)/)[1]
        channel = m.channel.name
        choice_array = choice.split(/[[:space:]]/)
        selection = choice_array.join(' ').downcase
        if @all_games.keys.include? channel
          game = @all_games[channel]
          game.values.each { |v| return m.reply "u alrdy voted #{m.user.nick.downcase}!" if v.include? user_address }
          if game[selection].nil?
            game[selection] = [user_address]
          else
            game[selection] << user_address
          end
          m.reply "#{m.user.nick} voted!"
        else
          m.reply "no active poll stupee"
        end
      end

      def help_poll(m)
        m.reply "creates a new 90 second poll"
      end

      def help_vote(m)
        m.reply "allows you to vote on an active poll"
      end

    end
  end
end
