require 'pg'

module Cinch
  module Plugins
    class Lineup
      include Cinch::Plugin

      match /(lineup)/
      match /(help lineup)$/, method: :help
      match /(newlineup) (.+)/, method: :update_lineup
      match /(approved)$/, method: :list_approved
      match /(approved) (.+)/, method: :add_approved
      match /(delete approved) (.+)/, method: :delete_approved

      def initialize(*args)
        super
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        # lineup db
        begin
          res = conn.exec_params("create table lineup (current varchar);")
          conn.exec(
            "INSERT INTO lineup (current) VALUES ('iono');"
          )
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Lineup Table creation failed: #{pg_error.message}"
        end
        lineup_db = conn.exec("SELECT current FROM lineup")
        @lineup = "#{lineup_db[0]['current']}"
        # approved db
        begin
          res = conn.exec_params("CREATE TABLE approved (username varchar);")
          conn.exec(
            "INSERT INTO approved (username) VALUES ('777');"
          )
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Approved Table creation failed: #{pg_error.message}"
        end
        pg_users = conn.exec("SELECT * FROM approved")
        @approved = []
        pg_users.each do |row|
          @approved << row['username'].downcase
        end
      end

      def execute(m)
        m.reply @lineup
      end

      def is_approved?(m)
        return true if m.is_op?
        @approved.include?(m.user.host.downcase)
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

      def update_lineup(m, prefix, update_lineup, new_lineup)
        if m.is_admin? || is_approved?(m)
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          lineup_db = conn.exec("SELECT current FROM lineup;")
          if new_lineup.to_s.size > 0
            conn.exec(
              "update lineup set current = '#{conn.escape_string(new_lineup)}' where current = '#{conn.escape_string(lineup_db[0]['current'])}';"
            )
            get_lineup = conn.exec("SELECT current FROM lineup;")
            @lineup = "#{get_lineup[0]['current']}"
            m.reply "donezo"
          else
            m.reply "can't be blank bru"
          end
        else
          m.is_unauthorized
        end
      end

      def list_approved(m)
        if m.is_admin?
          message = "#{m.user.nick} #{@approved.join(', ')}"
          notice_nick(m, '.', 'notice', message)
          m.reply "check ur notices bru"
        else
          m.is_unauthorized
        end
      end

      def add_approved(m, prefix, add_approved, user)
        if m.is_admin?
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          conn.exec("INSERT INTO approved (username) VALUES ('#{user}');")
          pg_users = conn.exec("SELECT * FROM approved")
          @approved = []
          pg_users.each do |row|
            @approved << row['username'].downcase
          end
          m.reply "donezo"
        else
          m.is_unauthorized
        end
      end

      def delete_approved(m, prefix, delete_approved, user)
        if m.is_admin?
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          conn.exec("DELETE FROM approved WHERE username = '#{user}'")
          pg_users = conn.exec("SELECT * FROM approved")
          @approved = []
          pg_users.each do |row|
            @approved << row['username'].downcase
          end
          m.reply "donezo"
        else
          m.is_unauthorized
        end
      end

      def help(m)
        m.reply "returns upcoming music show lineup (manually updated)"
      end

    end
  end
end
