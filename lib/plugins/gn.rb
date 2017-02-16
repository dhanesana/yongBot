require 'pg'
require 'open-uri'
require 'pastebin-api'

module Cinch
  module Plugins
    class Gn
      include Cinch::Plugin

      match /(gn)$/
      match /(addgn) (.+)/, method: :add
      match /(delgn) (.+)/, method: :del
      match /(who) (.+)/, method: :who
      match /(gnban) (.+)/, method: :ban_unban
      match /(gnban) (list)$/, method: :ban_list
      match /(gn) (list)$/, method: :list
      match /(help gn)$/, method: :help
      match /(help who)$/, method: :help_who
      match /(help addgn)$/, method: :help_add
      match /(help delgn)$/, method: :help_del
      match /(help gnban)$/, method: :help_ban
      match /(help gn list)$/, method: :help_list

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
        return m.reply "u get wat u deserve: #{@gn_pairs[m.user.host]}" if @gn_pairs.keys.include? m.user.host
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        entries = conn.exec("SELECT * FROM gn")
        @gn_pairs[m.user.host] = entries.field_values('link').sample
        m.reply @gn_pairs[m.user.host]
        Timer(3600, options = { shots: 1 }) do |x|
          @gn_pairs.delete(m.user.host)
        end
      end

      def add(m, prefix, addgn, url)
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM gnbanned WHERE prefix='#{m.user.host}'")
        return m.reply 'ur banned from adding images bru' if search.ntuples > 0
        entry_array = url.split(' ')
        return m.reply "no spaces in name or url. only space between name and url bru" if entry_array.size > 2
        return m.reply "missing name or url" if entry_array.size < 2
        return m.reply 'url must be hosted on imgur' unless entry_array[1].include? 'imgur'
        return m.reply 'url must contain https://' unless entry_array[1].include? 'http'
        return add_url(m, conn, entry_array) if entry_array[1].include? 'https'
        entry_array[1].sub!('http','https')
        add_url(m, conn, entry_array)
      end

      def add_url(m, conn, entry_array)
        return m.reply 'name before url' if (entry_array.first =~ URI::regexp).nil? == false
        search = conn.exec("SELECT * FROM gn WHERE link='#{conn.escape_string(conn.escape_string(entry_array[1]))}'")
        return m.reply 'url already exists in database bru' if search.ntuples > 0
        conn.exec("INSERT INTO gn (prefix, who, link) VALUES ('#{m.user.host}', '#{conn.escape_string(entry_array.first)}', '#{conn.escape_string(entry_array[1])}');")
        return m.reply "#{entry_array[1]} is added to database"
      end

      def del(m, prefix, delgn, url)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM gn WHERE link='#{conn.escape_string(url)}';")
        return m.reply "url doesn't exist in database bru" if search.ntuples < 1
        return del_url(m, conn, url) if m.is_admin?
        return del_url(m, conn, url) if m.is_op?
        return del_url(m, conn, url) if m.user.host == search.field_values('prefix').first
        m.is_unauthorized
      end

      def del_url(m, conn, url)
        conn.exec("DELETE FROM gn WHERE link='#{conn.escape_string(url)}';")
        m.reply "#{url} is removed from database"
      end

      def who(m, prefix, who, url)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        search = conn.exec("SELECT * FROM gn WHERE link='#{conn.escape_string(url)}';")
        return m.reply "link not found bru" if search.field_values('who').first.nil?
        m.reply "#{search.field_values('who').first}"
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
        search = conn.exec("SELECT * FROM gnbanned WHERE prefix='#{conn.escape_string(user_prefix)}';")
        if search.ntuples > 0
          conn.exec("DELETE FROM gnbanned WHERE prefix='#{conn.escape_string(user_prefix)}';")
          return User(m.user.nick).notice("#{conn.escape_string(user_prefix)} is UNbanned from adding gn urls")
        else
          conn.exec("INSERT INTO gnbanned (prefix) VALUES ('#{conn.escape_string(user_prefix)}');")
          return User(m.user.nick).notice("#{conn.escape_string(user_prefix)} is banned from adding gn urls")
        end
      end

      def ban_list(m)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        pastebin = Pastebin::Client.new(ENV['PASTEBIN_KEY'])
        string = ""
        if m.is_admin?
          get_all = conn.exec("SELECT * FROM gnbanned;")
          get_all.each do |x|
            string += "#{x['prefix']}"
            string += "\n"
          end
        else
          m.is_unauthorized
        end
        # Unlisted paste titled '.gnban list' expires in 10 minutes
        m.user.msg(pastebin.newpaste(string, api_paste_name: '.gnban list', api_paste_private: 1, api_paste_expire_date: '10M'))
        m.reply "check ur pms for list of gnbanned prefixes"
      end

      def list(m)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        pastebin = Pastebin::Client.new(ENV['PASTEBIN_KEY'])
        string = ""
        if m.is_admin?
          get_all = conn.exec("SELECT * FROM gn ORDER BY prefix DESC;")
          get_all.each do |x|
            string += "#{x['prefix']} => #{x['who']} => #{x['link']}"
            string += "\n"
          end
        else
          get_all = conn.exec("SELECT * FROM gn;")
          get_all.each do |x|
            string += "#{x['who']} => #{x['link']}"
            string += "\n"
          end
        end
        # Unlisted paste titled '.gn list' expires in 10 minutes
        m.user.msg(pastebin.newpaste(string, api_paste_name: '.gn list', api_paste_private: 1, api_paste_expire_date: '10M'))
        m.reply "check ur pms for list of saved gn urls"
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

      def help_list(m)
        m.reply 'returns pastebin url of saved gn urls'
      end

    end
  end
end
