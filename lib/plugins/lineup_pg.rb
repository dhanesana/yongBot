require 'pg'

module Cinch
  module Plugins
    class Lineup
      include Cinch::Plugin

      match /(lineup)/
      match /(help lineup)$/, method: :help

      def initialize(*args)
        super
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        begin
          res = conn.exec_params("create table lineup (current varchar);")
          conn.exec(
            "INSERT INTO lineup (current) VALUES ('iono');"
          )
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Lineup Table creation failed: #{pg_error.message}"
        end
      end

      def execute(m)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        lineup = conn.exec("SELECT current FROM lineup")
        m.reply "#{lineup[0]['current']}"
      end

      def help(m)
        m.reply "returns upcoming music show lineup (manually updated)"
      end

    end
  end
end
