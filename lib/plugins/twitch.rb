require 'unirest'
require 'open-uri'
require 'pg'
require 'pastebin-api'

module Cinch
  module Plugins
    class Twitch
      include Cinch::Plugin

      timer 120, method: :check_live
      match /(twitch)$/
      match /(twitch) (.+)/, method: :check_user
      match /(twitch) (list)$/, method: :list
      match /(addtwitch) (.+)/, method: :add_streamer
      match /(deltwitch) (.+)/, method: :del_streamer
      match /(twitchban) (.+)/, method: :ban_unban
      match /(twitchban) (list)$/, method: :ban_list
      match /(help twitch)$/, method: :help

      def initialize(*args)
        super
        @online = []
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        banned_table(conn)
        create_table(conn)
      end

      def create_table(conn)
        # twitch db
        begin
          res = conn.exec_params("create table twitch (prefix varchar, streamer varchar);")
          conn.exec(
            "INSERT INTO twitch (prefix, streamer) VALUES ('user/master', '1');"
          )
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Twitch Table creation failed: #{pg_error.message}"
        end
        twitch_streamers = conn.exec("SELECT * FROM twitch;")
        @streamers = []
        twitch_streamers.each do |row|
          @streamers << row['streamer'].downcase
        end
      end

      def banned_table(conn)
        # banned users db
        begin
          res = conn.exec_params("CREATE TABLE twitchbanned (prefix varchar);")
          conn.exec("INSERT INTO twitchbanned (prefix) VALUES ('user/testban');")
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Table creation failed: #{pg_error.message}"
        end
        banned_users = conn.exec("SELECT * FROM twitchbanned;")
        @banned = []
        banned_users.each do |row|
          @banned << row['prefix'].downcase
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
        search = conn.exec("SELECT * FROM twitchbanned WHERE prefix='#{conn.escape_string(user_prefix)}';")
        if search.ntuples > 0
          conn.exec("DELETE FROM twitchbanned WHERE prefix='#{conn.escape_string(user_prefix)}';")
          return User(m.user.nick).notice("#{conn.escape_string(user_prefix)} is UNbanned from adding gn urls")
        else
          conn.exec("INSERT INTO twitchbanned (prefix) VALUES ('#{conn.escape_string(user_prefix)}');")
          return User(m.user.nick).notice("#{conn.escape_string(user_prefix)} is banned from adding gn urls")
        end
        banned_users = conn.exec("SELECT * FROM twitchbanned;")
        @banned = []
        banned_users.each do |row|
          @banned << row['prefix'].downcase
        end
      end

      def ban_list(m)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        pastebin = Pastebin::Client.new(ENV['PASTEBIN_KEY'])
        string = ""
        if m.is_admin?
          get_all = conn.exec("SELECT * FROM twitchbanned;")
          get_all.each do |x|
            string += "#{x['prefix']}"
            string += "\n"
          end
        else
          m.is_unauthorized
        end
        # Unlisted paste titled '.twitchban list' expires in 10 minutes
        m.user.msg(pastebin.newpaste(string, api_paste_name: '.twitchban list', api_paste_private: 1, api_paste_expire_date: '10M'))
        m.reply "check ur pms for list of twitchbanned prefixes"
      end

      def add_streamer(m, prefix, addtwitch, streamer)
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        return m.is_unauthorized if @banned.include? m.user.host
        return m.reply "#{streamer} already in db" if @streamers.include? streamer
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        conn.exec("INSERT INTO twitch (prefix, streamer) VALUES ('#{m.user.host}', '#{conn.escape(streamer)}');")
        twitch_streamers = conn.exec("SELECT * FROM twitch")
        @streamers = []
        twitch_streamers.each do |row|
          @streamers << row['streamer'].downcase
        end
        m.reply "#{streamer} added to twitch db"
      end

      def del_streamer(m, prefix, deltwitch, streamer)
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM twitch WHERE streamer='#{conn.escape(streamer)}';")
        return m.reply "streamer doesn't exist in database bru" if search.ntuples < 1
        return del_streamer_db(m, conn, streamer) if m.is_admin?
        return del_streamer_db(m, conn, streamer) if m.is_op?
        return del_streamer_db(m, conn, streamer) if m.user.host == search.field_values('prefix').first
        m.isunauthorized
      end

      def del_streamer_db(m, conn, streamer)
        conn.exec("DELETE FROM twitch WHERE streamer='#{conn.escape(streamer)}';")
        twitch_streamers = conn.exec("SELECT * FROM twitch;")
        @streamers = []
        twitch_streamers.each do |row|
          @streamers << row['streamer'].downcase
        end
        m.reply "#{streamer} is removed from database"
      end

      def list(m)
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        return m.is_unauthorized if @banned.include? m.user.host
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        pastebin = Pastebin::Client.new(ENV['PASTEBIN_KEY'])
        string = ""
        if m.is_admin?
          get_all = conn.exec("SELECT * FROM twitch ORDER BY prefix DESC;")
          get_all.each do |x|
            string += "'#{x['prefix']}' => 'https://www.twitch.tv/#{x['streamer']}'"
            string += "\n"
          end
        else
          get_all = conn.exec("SELECT * FROM twitch;")
          get_all.each do |x|
            string += "https://www.twitch.tv/#{x['streamer']}"
            string += "\n"
          end
        end
        # Unlisted paste titled '.gn list' expires in 10 minutes
        m.user.msg(pastebin.newpaste(string, api_paste_name: '.twitch list', api_paste_private: 1, api_paste_expire_date: '10M'))
        m.reply "check ur pms for list of saved twitch users"
      end

      def execute(m)
        counter = 0
        @streamers.each do |user|
          user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(user)}",
            headers: { "Accept" => "application/json" },
            parameters: { :client_id => ENV['TWITCH_ID'] }
          counter += 1 if user_get.body['stream'].nil?
          return m.reply "no1 streaming" if counter == @streamers.size
          next if user_get.body['stream'].nil?
          game = user_get.body['stream']['game']
          url = user_get.body['stream']['channel']['url']
          name = user_get.body['stream']['channel']['display_name']
          title = user_get.body['stream']['channel']['status']
          title = 'No Title' if title == ''
          viewers = user_get.body['stream']['viewers']
          m.reply "LIVE: '#{title}' (#{name} playing #{game}) => #{url}"
        end
      end

      def check_live
        response = "LIVE:"
        @streamers.each do |user|
          user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(user)}",
            headers: { "Accept" => "application/json" },
            parameters: { :client_id => ENV['TWITCH_ID'] }
          @online.delete(user) if user_get.body['stream'].nil?
          next if user_get.body['stream'].nil?
          next if @online.include? user
          @online << user
          game = user_get.body['stream']['game']
          url = user_get.body['stream']['channel']['url']
          name = user_get.body['stream']['channel']['display_name']
          title = user_get.body['stream']['channel']['status']
          title = 'No Title' if title == ''
          viewers = user_get.body['stream']['viewers']
          ENV["TWITCH_CHANNELS"].split(',').each do |channel|
            Channel(channel).send "LIVE: '#{title}' (#{name} playing #{game}) => #{url}"
          end
        end
      end

      def check_user(m, prefix, check_user, user)
        return if user == 'list'
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        return m.is_unauthorized if @banned.include? m.user.host
        query = user.split(/[[:space:]]/).join(' ')
        user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(query)}",
          headers: { "Accept" => "application/json" },
          parameters: { :client_id => ENV['TWITCH_ID'] }
        return m.reply "#{user} is not live bru" if user_get.body['stream'].nil?
        game = user_get.body['stream']['game']
        url = user_get.body['stream']['channel']['url']
        name = user_get.body['stream']['channel']['display_name']
        title = user_get.body['stream']['channel']['status']
        title = 'No Title' if title == ''
        viewers = user_get.body['stream']['viewers']
        m.reply "'#{title}' (#{name} playing #{game}), Viewers: #{viewers} => #{url}"
      end

      def help(m)
        m.reply "checks every 5 minutes if specified twitch broadcasts are live."
        m.reply "type .twitch [user] to check status of specific twitch user"
      end

    end
  end
end
