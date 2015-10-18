module Cinch
  module Plugins
    class Master
      include Cinch::Plugin

      match /(thyme)$/, method: :thyme, prefix: /^(\.)/
      match /(join) (.+)/, method: :join, prefix: /^(\.)/
      match /(part)$/, method: :part, prefix: /^(\.)/
      match /(part) (.+)/, method: :part_specified, prefix: /^(\.)/
      match /(setnick) (.+)/, method: :set_nick, prefix: /^(\.)/
      match /(ping)$/, method: :ping, prefix: /^(\.)/

      def initialize(*args)
        super
        # Set nick to first choice if available after 3 minutes
        Timer(180, options = { shots: 1 }) do |x|
          @bot.nick = ENV['NICKS'].split(',').first
        end
        @unauthorized = "https://youtu.be/OBWpzvJGTz4"
      end

      def is_admin?(user)
        user.prefix.match(/@(.+)/)[1] == $master
      end

      def thyme(m)
        m.reply Time.now.strftime("%Y-%m-%d %H:%M %Z")
      end

      def join(m, prefix, join, channel)
        return @bot.join(channel) if is_admin?(m)
        m.reply @unauthorized
      end

      def part(m)
        return @bot.part(m.channel.name) if is_admin?(m)
        m.reply @unauthorized
      end

      def part_specified(m, prefix, part, channel)
        return @bot.part(channel) if is_admin?(m)
        m.reply @unauthorized
      end

      def set_nick(m, prefix, setnick, new_nick)
        return @bot.nick = new_nick if is_admin?(m)
        m.reply @unauthorized
      end

      def ping(m)
        return m.reply "too many ppls bru" if Channel(m.channel.name).users.size > 30
        ops = Channel(m.channel.name).ops.map { |x| x.nick }
        users = []
        if is_admin?(m)
          Channel(m.channel.name).users.each do |user|
            users << user.first.nick
          end
          users.delete(@bot.nick)
          return m.reply users.join(' ')
        end
        if ops.include? m.user.nick
          Channel(m.channel.name).users.each do |user|
            users << user.first.nick
          end
          users.delete(@bot.nick)
          m.reply users.join(' ')
        else
          m.reply 'master or ops only bru'
        end
      end

    end
  end
end
