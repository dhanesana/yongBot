require 'pg'
require 'pastebin-api'

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
      match /(ban) (.+)/, method: :ban_unban
      match /(ban) (list)$/, method: :ban_list
      match /(drop) (.+)/, method: :drop

      def initialize(*args)
        super
        # Set nick to first choice if available after 3 minutes
        Timer(180, options = { shots: 1 }) do |x|
          @bot.nick = ENV['NICKS'].split(',').first
        end
        # Establish DB connection && Create banned table
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        banned_table(conn)
      end

      def banned_table(conn)
        # banned users db
        begin
          res = conn.exec_params("CREATE TABLE banned (prefix varchar);")
          conn.exec("INSERT INTO banned (prefix) VALUES ('user/banneduser');")
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Table creation failed: #{pg_error.message}"
        end
        banned_users = conn.exec("SELECT * FROM banned;")
        banned_users.each do |row|
          $banned << row['prefix'].downcase
        end
      end

      def ban_unban(m, prefix, gnban, user_prefix)
        return if user_prefix == 'list'
        # can't ban $master
        return m.is_unauthorized if user_prefix == $master
        return ban_toggle(m, user_prefix) if m.is_admin?
        return ban_toggle(m, user_prefix) if m.is_op?
        m.is_unauthorized
      end

      def ban_toggle(m, user_prefix)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM banned WHERE prefix='#{conn.escape_string(user_prefix)}';")
        if search.ntuples > 0
          conn.exec("DELETE FROM banned WHERE prefix='#{conn.escape_string(user_prefix)}';")
          return User(m.user.nick).notice("#{conn.escape_string(user_prefix)} is UNbanned")
        else
          conn.exec("INSERT INTO banned (prefix) VALUES ('#{conn.escape_string(user_prefix)}');")
          return User(m.user.nick).notice("#{conn.escape_string(user_prefix)} is banned!")
        end
        banned_users = conn.exec("SELECT * FROM banned;")
        $banned = []
        banned_users.each do |row|
          $banned << row['prefix'].downcase
        end
      end

      def ban_list(m)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        pastebin = Pastebin::Client.new(ENV['PASTEBIN_KEY'])
        string = ""
        if m.is_admin?
          get_all = conn.exec("SELECT * FROM banned;")
          get_all.each do |x|
            string += "#{x['prefix']}"
            string += "\n"
          end
        else
          m.is_unauthorized
        end
        # Unlisted paste titled '.banned list' expires in 10 minutes
        m.user.msg(pastebin.newpaste(string, api_paste_name: '.ban list', api_paste_private: 1, api_paste_expire_date: '10M'))
        m.reply "check ur pms for list of banned prefixes"
      end

      def drop(m, prefix, drop, table_name)
        if m.is_admin?
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          conn.exec("DROP TABLE #{table_name};")
          m.reply 'donezo'
        else
          return m.is_unauthorized
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
