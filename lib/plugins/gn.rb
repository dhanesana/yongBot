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
      match /(gn) (list)$/, method: :list
      match /(help gn)$/, method: :help
      match /(help who)$/, method: :help_who
      match /(help addgn)$/, method: :help_add
      match /(help delgn)$/, method: :help_del
      match /(help gn list)$/, method: :help_list

      def initialize(*args)
        super
        @gn_pairs = {}
        create_table
      end

      def create_table
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        begin
          res = conn.exec_params("CREATE TABLE gn (prefix varchar, who varchar, link varchar);")
          conn.exec("INSERT INTO gn (prefix, who, link) VALUES ('#{$master}', 'yein', 'https://i.imgur.com/zseA3sP.jpg');")
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Table creation failed: #{pg_error.message}"
        end
        gn_hash(conn)
      end

      def gn_hash(conn)
        @gn_db = {}
        get_all = conn.exec("SELECT * FROM gn;")
        get_all.each do |x|
          @gn_db[x['link']] = [x['who'], x['prefix']]
        end
      end

      def execute(m)
        return m.reply "u get wat u deserve: #{@gn_pairs[m.user.host]}" if @gn_pairs.keys.include? m.user.host
        @gn_pairs[m.user.host] = @gn_db.keys.sample
        m.reply @gn_pairs[m.user.host]
        Timer(3600, options = { shots: 1 }) do |x|
          @gn_pairs.delete(m.user.host)
        end
      end

      def add(m, prefix, addgn, url)
        return m.reply 'registered users only bru' if m.user.host.include? 'Snoonet'
        entry_array = url.split(' ')
        return m.reply "no spaces in name or url. only space between name and url bru" if entry_array.size > 2
        return m.reply "missing name or url" if entry_array.size < 2
        return m.reply 'url must be hosted on imgur' unless entry_array[1].include? 'imgur'
        return m.reply 'url must contain https://' unless entry_array[1].include? 'http'
        return add_url(m, entry_array) if entry_array[1].include? 'https'
        entry_array[1].sub!('http','https')
        add_url(m, entry_array)
      end

      def add_url(m, entry_array)
        return m.reply 'name before url' if (entry_array.first =~ URI::regexp).nil? == false
        return 'url already exists in database bru' if @gn_db.keys.include? entry_array[1]
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        conn.exec("INSERT INTO gn (prefix, who, link) VALUES ('#{m.user.host}', '#{conn.escape_string(entry_array.first)}', '#{conn.escape_string(entry_array[1])}');")
        gn_hash(conn)
        m.reply "#{entry_array[1]} is added to database"
      end

      def del(m, prefix, delgn, url)
        return "url doesn't exist in database bru" if @gn_db[conn.escape(url)].nil?
        return del_url(m, url) if m.is_admin?
        return del_url(m, url) if m.is_op?
        return del_url(m, url) if @gn_db[conn.escape(url)][1] == m.user.host
        m.is_unauthorized
      end

      def del_url(m, url)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        conn.exec("DELETE FROM gn WHERE link='#{conn.escape_string(url)}';")
        gn_hash(conn)
        m.reply "#{url} is removed from database"
      end

      def who(m, prefix, who, url)
        return m.reply "link not found bru" if @gn_db[conn.escape_string(url)].nil?
        m.reply "#{@gn_db[conn.escape_string(url)].first}"
      end

      def list(m)
        pastebin = Pastebin::Client.new(ENV['PASTEBIN_KEY'])
        string = ""
        if m.is_admin?
          @gn_db.each do |k, v|
            string += "#{v[1]} => #{v[0]} => #{k}"
            string += "\n"
          end
        else
          @gn_db.each do |k, v|
            string += "#{v[0]} => #{k}"
          end
        end
        # Unlisted paste titled '.gn list' expires in 10 minutes
        m.user.send(pastebin.newpaste(string, api_paste_name: '.gn list', api_paste_private: 1, api_paste_expire_date: '10M'))
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

      def help_list(m)
        m.reply 'returns pastebin url of saved gn urls'
      end

    end
  end
end
