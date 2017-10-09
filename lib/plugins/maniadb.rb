require 'rss'
require 'open-uri'

module Cinch
  module Plugins
    class Maniadb
      include Cinch::Plugin

      match /(maniadb) (.+)/
      match /(help maniadb)$/, method: :help

      def execute(m, prefix, maniadb, entry)
        query = entry.split(/[[:space:]]/).join(' ').downcase
        url = "http://dev.maniadb.com/index.php/api/search/#{URI.encode(query)}/?sr=artist&display=1&key=example&v=0.5"
        open(url) do |rss|
          feed = RSS::Parser.parse(rss, false)
          return m.reply '0 results' if feed.items == []
          m.reply "#{feed.items.first.title}: #{feed.items.first.link}"
        end
      end

      def help(m)
        m.reply 'searches maniadb for specified artist page'
      end

    end
  end
end
