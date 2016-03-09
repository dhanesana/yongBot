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
      match /(newlineup) (.+)/, method: :update_lineup
      match /(approved)$/, method: :list_approved
      match /(approved) (.+)/, method: :add_approved
      match /(delete approved) (.+)/, method: :delete_approved

      def initialize(*args)
        super
        # Set nick to first choice if available after 3 minutes
        Timer(180, options = { shots: 1 }) do |x|
          @bot.nick = ENV['NICKS'].split(',').first
        end
        @unauthorized = "https://youtu.be/OBWpzvJGTz4"
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        begin
          res = conn.exec_params("CREATE TABLE approved (username varchar);")
          conn.exec(
            "INSERT INTO approved (username) VALUES ('777');"
          )
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Approved Table creation failed: #{pg_error.message}"
        end
      end

      def is_admin?(user)
        user.prefix.match(/@(.+)/)[1] == $master
      end

      def is_approved?(user)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        pg_users = conn.exec("SELECT * FROM approved")
        users = []
        pg_users.each do |row|
          users << row['username']
        end
        users.include?(user.prefix.match(/@(.+)/)[1])
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

      def echo(m, prefix, echo, words)
        if is_admin?(m)
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
          m.reply @unauthorized
        end
      end

      def notice(m)
        return User(m.user.nick).notice('I NOTICE U') if is_admin?(m)
        m.reply @unauthorized
      end

      def notice_nick(m, prefix, notice, nick_msg)
        if is_admin?(m)
          nick = nick_msg.split(' ').first
          msg = nick_msg.split(' ')[1..-1].join(' ')
          msg = 'I NOTICE U' if nick_msg.split(' ').size == 1
          User(nick).notice(msg)
        else
          m.reply @unauthorized
        end
      end

      def update_lineup(m, prefix, update_lineup, new_lineup)
        if is_admin?(m) || is_approved?(m)
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          lineup_db = conn.exec("SELECT current FROM lineup")
          if new_lineup.to_s.size > 0
            conn.exec(
              "update lineup set current = '#{new_lineup}' where current = '#{lineup_db[0]['current']}'"
            )
            m.reply "donezo"
          else
            m.reply "can't be blank bru"
          end
        else
          m.reply @unauthorized
        end
      end

      def list_approved(m)
        if is_admin?(m)
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          pg_users = conn.exec("SELECT * FROM approved")
          users = []
          pg_users.each do |row|
            users << row['username']
          end
          message = "#{m.user.nick} #{users.join(', ')}"
          notice_nick(m, '.', 'notice', message)
          m.reply "check ur notices bru"
        else
          m.reply @unauthorized
        end
      end

      def add_approved(m, prefix, add_approved, user)
        if is_admin?(m)
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          conn.exec("INSERT INTO approved (username) VALUES ('#{user}');")
          m.reply "donezo"
        else
          m.reply @unauthorized
        end
      end

      def delete_approved(m, prefix, delete_approved, user)
        if is_admin?(m)
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          conn.exec("DELETE FROM approved WHERE username = '#{user}'")
          m.reply "donezo"
        else
          m.reply @unauthorized
        end
      end

    end
  end
end
