require 'rss'

module Cinch
  module Plugins
    class Dp
      include Cinch::Plugin

      match /(dp)$/
      match /(dp news)$/
      match /(dp reviews)$/, method: :reviews
      match /(dp review)$/, method: :reviews
      match /(help dp)$/, method: :help

      def execute(m)
        get_post(m, 'http://www.dpreview.com/feeds/news.xml')
      end

      def reviews(m)
        get_post(m, 'http://www.dpreview.com/feeds/reviews.xml')
      end

      def get_post(m, url)
        open(url) do |rss|
          feed = RSS::Parser.parse(rss, false)
          m.reply "#{feed.items.first.title}: #{feed.items.first.link}"
        end
      end

      def help(m)
        m.reply 'returns most recent dpreview post'
      end

    end
  end
end
