require 'pg'

module Cinch
  module Plugins
    class Master
      include Cinch::Plugin

      match /(thyme)$/, method: :thyme
      match /(join) (.+)/, method: :join
      match /(part)$/, method: :part
      match /(part) (.+)/, method: :part_specified
      match /(setnick) (.+)/, method: :set_nick
      match /(ping)$/, method: :ping
      match /(echo) (.+)/, method: :echo
      match /(notice)$/, method: :notice
      match /(notice) (.+)/, method: :notice_nick

      def initialize(*args)
        super
        # Set nick to first choice if available after 3 minutes
        Timer(180, options = { shots: 1 }) do |x|
          @bot.nick = ENV['NICKS'].split(',').first
        end
      end

      def thyme(m)
        m.reply Time.now.strftime("%Y-%m-%d %H:%M %Z")
      end

      def join(m, prefix, join, channel)
        return @bot.join(channel) if m.is_admin?
        m.is_unauthorized
      end

      def part(m)
        return @bot.part(m.channel.name) if m.is_admin?
        m.is_unauthorized
      end

      def part_specified(m, prefix, part, channel)
        return @bot.part(channel) if m.is_admin?
        m.is_unauthorized
      end

      def set_nick(m, prefix, setnick, new_nick)
        return @bot.nick = new_nick if m.is_admin?
        m.is_unauthorized
      end

      def ping(m)
        return m.reply "too many ppls bru" if Channel(m.channel.name).users.size > 30
        users = []
        if m.is_admin?
          Channel(m.channel.name).users.each do |user|
            users << user.first.nick
          end
          users.delete(@bot.nick)
          return m.reply users.join(' ')
        end
        if m.is_op?
          Channel(m.channel.name).users.each do |user|
            users << user.first.nick
          end
          users.delete(@bot.nick)
          m.reply users.join(' ')
        else
          m.reply 'master or ops only bru'
        end
      end

      def echo(m, prefix, echo, words)
        if m.is_admin?
          channels = @bot.channels.map { |x| x.name }
          if m.channel.nil?
            if words[0] == '#'
              ray = words.split(' ')
              channel = ray.first
              ray.delete_at(0)
              sentence = ray.join(' ')
            else
              return m.reply "please specify #channel (with # prefix)"
            end
          else
            if words[0] == '#'
              ray = words.split(' ')
              channel = ray.first
              ray.delete_at(0)
              sentence = ray.join(' ')
            else
              channel = m.channel.name
              sentence = words
            end
          end
          return Channel(channel).send sentence if channels.include? channel
          m.reply 'no external msgs bru'
        else
          m.is_unauthorized
        end
      end

      def notice(m)
        return User(m.user.nick).notice('I NOTICE U') if m.is_admin?
        m.is_unauthorized
      end

      def notice_nick(m, prefix, notice, nick_msg)
        if m.is_admin?
          nick = nick_msg.split(' ').first
          msg = nick_msg.split(' ')[1..-1].join(' ')
          msg = 'I NOTICE U' if nick_msg.split(' ').size == 1
          User(nick).notice(msg)
        else
          m.is_unauthorized
        end
      end

    end
  end
end
