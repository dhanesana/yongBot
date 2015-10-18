require 'rss'

module Cinch
  module Plugins
    class Cpme
      include Cinch::Plugin

      match /(cpme)$/
      match /(help cpme)$/, method: :help

      def execute(m)
        url = 'https://crayonpop.me/feed/'
        open(url) do |rss|
          feed = RSS::Parser.parse(rss)
          m.reply "#{feed.items.first.title}: #{feed.items.first.link}"
        end
      end

      def help(m)
        m.reply 'returns most recent crayonpop.me post'
      end

    end
  end
end
