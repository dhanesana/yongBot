require 'pg'
require 'open-uri'

module Cinch
  module Plugins
    class Gn
      include Cinch::Plugin

      match /(gn)$/
      match /(addgn) (.+)/, method: :add
      match /(delgn) (.+)/, method: :del
      match /(who) (.+)/, method: :who
      match /(gnban) (.+)/, method: :ban_status
      match /(help gn)$/, method: :help
      match /(help who)$/, method: :help_who
      match /(help addgn)$/, method: :help_add
      match /(help delgn)$/, method: :help_del
      match /(help gnban)$/, method: :help_ban

      def initialize(*args)
        super
        @gn_pairs = {}
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        begin
          res = conn.exec_params("CREATE TABLE gn (prefix varchar, who varchar, link varchar);")
          conn.exec("INSERT INTO gn (prefix, who, link) VALUES ('#{$master}', 'yein', 'https://i.imgur.com/zseA3sP.jpg');")
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Table creation failed: #{pg_error.message}"
        end
        # banned users
        begin
          res = conn.exec_params("CREATE TABLE gnbanned (prefix varchar);")
          conn.exec("INSERT INTO gnbanned (prefix) VALUES ('user/testban');")
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Table creation failed: #{pg_error.message}"
        end
      end

      def execute(m)
        if @gn_pairs.keys.include? m.prefix.match(/@(.+)/)[1]
          m.reply "u get wat u deserve: #{@gn_pairs[m.prefix.match(/@(.+)/)[1]]}"
        else
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          entries = conn.exec("SELECT * FROM gn")
          @gn_pairs[m.prefix.match(/@(.+)/)[1]] = entries.field_values('link').sample
          m.reply @gn_pairs[m.prefix.match(/@(.+)/)[1]]
          Timer(3600, options = { shots: 1 }) do |x|
            @gn_pairs.delete(m.prefix.match(/@(.+)/)[1])
          end
        end
      end

      def add(m, prefix, addgn, url)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM gnbanned WHERE prefix='#{m.prefix.match(/@(.+)/)[1]}'")
        if search.ntuples > 0
          return m.reply 'ur banned from adding images bru'
        else
          entry_array = url.split(' ')
          if entry_array.size > 2
            return m.reply "no spaces in name or url. only space between name and url bru"
          elsif entry_array.size < 2
            return m.reply "missing name or url"
          else
            if entry_array[1].include? 'imgur'
              if entry_array[1].include? 'http'
                if entry_array[1].include? 'https'
                  return m.reply 'name before url' if (entry_array.first =~ URI::regexp).nil? == false
                  search = conn.exec("SELECT * FROM gn WHERE link='#{conn.escape_string(conn.escape_string(entry_array[1]))}'")
                  return m.reply 'url already exists in database bru' if search.ntuples > 0
                  conn.exec("INSERT INTO gn (prefix, who, link) VALUES ('#{m.prefix.match(/@(.+)/)[1]}', '#{conn.escape_string(entry_array.first)}', '#{conn.escape_string(entry_array[1])}');")
                  return m.reply "#{entry_array[1]} is added to database"
                else
                  entry_array[1].sub!('http','https')
                  return m.reply 'name before url' if (entry_array.first =~ URI::regexp).nil? == false
                  search = conn.exec("SELECT * FROM gn WHERE link='#{conn.escape_string(conn.escape_string(entry_array[1]))}'")
                  return m.reply 'url already exists in database bru' if search.ntuples > 0
                  conn.exec("INSERT INTO gn (prefix, who, link) VALUES ('#{m.prefix.match(/@(.+)/)[1]}', '#{conn.escape_string(entry_array.first)}', '#{conn.escape_string(entry_array[1])}');")
                  return m.reply "#{entry_array[1]} is added to database"
                end
              else
                return m.reply "url must contain https://"
              end
            else
              return m.reply 'url must be hosted on imgur'
            end
          end
        end
      end

      def del(m, prefix, delgn, url)
        ops = Channel(m.channel.name).ops.map { |x| x.nick }
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM gn WHERE link='#{conn.escape_string(url)}';")
        if m.prefix.match(/@(.+)/)[1] == $master
          return m.reply "url doesn't exist in database bru" if search.ntuples < 1
          conn.exec("DELETE FROM gn WHERE link='#{conn.escape_string(url)}';")
          return User(m.user.nick).notice("#{url} is removed from database")
        elsif m.prefix.match(/@(.+)/)[1] == search.field_values('prefix').first
          return m.reply "url doesn't exist in database bru" if search.ntuples < 1
          conn.exec("DELETE FROM gn WHERE link='#{conn.escape_string(url)}';")
          return User(m.user.nick).notice("#{url} is removed from database")
        elsif ops.include? m.user.nick
          return m.reply "url doesn't exist in database bru" if search.ntuples < 1
          conn.exec("DELETE FROM gn WHERE link='#{conn.escape_string(url)}';")
          return User(m.user.nick).notice("#{url} is removed from database")
        else
          m.reply 'https://youtu.be/OBWpzvJGTz4'
        end
      end

      def who(m, prefix, who, url)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM gn WHERE link='#{conn.escape_string(url)}';")
        return m.reply "link not found bru" if search.field_values('who').first.nil?
        m.reply "#{search.field_values('who').first}"
      end

      def ban_status(m, prefix, gnban, user_prefix)
        return m.reply "https://youtu.be/OBWpzvJGTz4" if user_prefix == $master
        ops = Channel(m.channel.name).ops.map { |x| x.nick }
        if m.prefix.match(/@(.+)/)[1] == $master
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          search = conn.exec("SELECT * FROM gnbanned WHERE prefix='#{conn.escape_string(user_prefix)}';")
          if search.ntuples > 0
            conn.exec("DELETE FROM gnbanned WHERE prefix='#{conn.escape_string(user_prefix)}';")
            return User(m.user.nick).notice("#{user_prefix} is UNbanned from adding gn urls")
          else
            conn.exec("INSERT INTO gnbanned (prefix) VALUES ('#{conn.escape_string(user_prefix)}');")
            return User(m.user.nick).notice("#{user_prefix} is banned from adding gn urls")
          end
        end
        if ops.include? m.user.nick
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          search = conn.exec("SELECT * FROM gnbanned WHERE prefix='#{conn.escape_string(user_prefix)}';")
          if search.ntuples > 0
            conn.exec("DELETE FROM gnbanned WHERE prefix='#{conn.escape_string(user_prefix)}';")
            return User(m.user.nick).notice("#{conn.escape_string(user_prefix)} is UNbanned from adding gn urls")
          else
            conn.exec("INSERT INTO gnbanned (prefix) VALUES ('#{conn.escape_string(user_prefix)}');")
            return User(m.user.nick).notice("#{conn.escape_string(user_prefix)} is banned from adding gn urls")
          end
        else
          m.reply 'https://youtu.be/OBWpzvJGTz4'
        end
      end

      def help(m)
        m.reply "returns random gn pic via destiny"
      end

      def help_who(m)
        m.reply 'finds and returns name associated with gn url'
      end

      def help_add(m)
        m.reply 'adds image to gn database'
        m.reply '.addgn [name] [url]'
      end

      def help_del(m)
        m.reply 'deletes image from gn database (uploader, master, or op only)'
      end

      def help_ban(m)
        m.reply 'master or op can ban or unban users by prefix'
        m.reply '.gnban user/BANNEDUSER'
      end

    end
  end
end
