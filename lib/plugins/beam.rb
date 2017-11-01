require 'unirest'
require 'open-uri'
require 'pg'
require 'pastebin-api'

module Cinch
  module Plugins
    class Beam
      include Cinch::Plugin

      timer 120, method: :check_live
      match /(beam)$/
      match /(beam) (.+)/, method: :check_user
      match /(beam) (list)$/, method: :list
      match /(addbeam) (.+)/, method: :add_streamer
      match /(delbeam) (.+)/, method: :del_streamer
      match /(help beam)$/, method: :help

      def initialize(*args)
        super
        @online = []
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        create_table(conn)
      end

      def create_table(conn)
        # beam db
        begin
          res = conn.exec_params("create table beam (prefix varchar, streamer varchar);")
          conn.exec(
            "INSERT INTO beam (prefix, streamer) VALUES ('user/master', '1');"
          )
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Beam Table creation failed: #{pg_error.message}"
        end
        beam_streamers = conn.exec("SELECT * FROM beam;")
        @streamers = []
        beam_streamers.each do |row|
          @streamers << row['streamer'].downcase
        end
      end

      def add_streamer(m, prefix, addbeam, streamer)
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        return m.reply "#{streamer} already in db" if @streamers.include? streamer
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        conn.exec("INSERT INTO beam (prefix, streamer) VALUES ('#{m.user.host}', '#{conn.escape(streamer)}');")
        beam_streamers = conn.exec("SELECT * FROM beam")
        @streamers = []
        beam_streamers.each do |row|
          @streamers << row['streamer'].downcase
        end
        m.reply "#{streamer} added to beam db"
      end

      def del_streamer(m, prefix, delbeam, streamer)
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM beam WHERE streamer='#{conn.escape(streamer)}';")
        return m.reply "streamer doesn't exist in database bru" if search.ntuples < 1
        return del_streamer_db(m, conn, streamer) if m.is_admin?
        return del_streamer_db(m, conn, streamer) if m.is_op?
        return del_streamer_db(m, conn, streamer) if m.user.host == search.field_values('prefix').first
        m.isunauthorized
      end

      def del_streamer_db(m, conn, streamer)
        conn.exec("DELETE FROM beam WHERE streamer='#{conn.escape(streamer)}';")
        beam_streamers = conn.exec("SELECT * FROM beam;")
        @streamers = []
        beam_streamers.each do |row|
          @streamers << row['streamer'].downcase
        end
        m.reply "#{streamer} is removed from database"
      end

      def list(m)
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        pastebin = Pastebin::Client.new(ENV['PASTEBIN_KEY'])
        string = ""
        if m.is_admin?
          get_all = conn.exec("SELECT * FROM beam ORDER BY prefix DESC;")
          get_all.each do |x|
            string += "'#{x['prefix']}' => 'https://beam.pro/#{x['streamer']}', "
            string += "\n"
          end
        else
          get_all = conn.exec("SELECT * FROM beam;")
          get_all.each do |x|
            string += "https://beam.pro/#{x['streamer']}, "
            string += "\n"
          end
        end
        # Unlisted paste titled '.gn list' expires in 10 minutes
        m.user.send(pastebin.newpaste(string.chomp.chomp(', '), api_paste_name: '.beam list', api_paste_private: 1, api_paste_expire_date: '10M'))
        m.reply "check ur pms for list of saved beam users"
      end

      def execute(m)
        counter = 0
        @streamers.each do |user|
          user_get = Unirest.get "https://beam.pro/api/v1/channels/#{URI.encode(user)}"
          counter += 1 if user_get.body['online'] == false
          return m.reply "no1 streaming" if counter == @users.size
          next if user_get.body['online'] == false
          name = user_get.body['user']['username']
          game = user_get.body['type']['name']
          title = user_get.body['name']
          viewers = user_get.body['viewersCurrent']
          url = "https://beam.pro/#{URI.encode(user)}"
          m.reply "LIVE: '#{title}' (#{name} playing #{game}) => #{url}"
        end
      end

      def check_live
        response = "LIVE:"
        @streamers.each do |user|
          user_get = Unirest.get "https://beam.pro/api/v1/channels/#{URI.encode(user)}"
          @online.delete(user) if user_get.body['online'] == false
          next if user_get.body['online'] == false
          next if @online.include? user
          @online << user
          game = user_get.body['type']['name']
          url = "https://beam.pro/#{URI.encode(user)}"
          name = user_get.body['user']['username']
          title = user_get.body['name']
          viewers = user_get.body['viewersCurrent']
          ENV["TWITCH_CHANNELS"].split(',').each do |channel|
            Channel(channel).send "LIVE: '#{title}' (#{name} playing #{game}) => #{url}"
          end
        end
      end

      def check_user(m, prefix, check_user, user)
        return if user == 'list'
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        query = user.split(/[[:space:]]/).join(' ')
        user_get = Unirest.get "https://beam.pro/api/v1/channels/#{URI.encode(query)}"
        return m.reply "#{user} is not live bru" if user_get.body['online'] == false
        game = user_get.body['type']['name']
        url = "https://beam.pro/#{URI.encode(query)}"
        name = user_get.body['user']['username']
        title = user_get.body['name']
        viewers = user_get.body['viewersCurrent']
        m.reply "'#{title}' (#{name} playing #{game}), Viewers: #{viewers} => #{url}"
      end

      def help(m)
        m.reply "checks every 5 minutes if specified beam broadcasts are live."
        m.reply "type .addbeam [user] to add and .delbeam [user] to delete from beam db"
        m.reply "type .beam [user] to check status of specific beam user"
      end

    end
  end
end
