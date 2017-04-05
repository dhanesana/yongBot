require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class Itunes
      include Cinch::Plugin

      match /(itunes)$/
      match /(itunes) (.+)/, method: :with_num
      match /(help itunes)$/, method: :help

      def execute(m)
        with_num(m, '.', 'itunes', '1')
      end

      def with_num(m, prefix, melon, entry)
        return m.reply '1-100 only bru' if entry.to_i > 100
        return m.reply '1-100 only bru' if entry == '0'
        return m.reply 'invalid num bru' if entry.to_i < 0
        feed = open('https://itunes.apple.com/us/rss/topalbums/limit=100/explicit=true/json').read
        result = JSON.parse(feed)
        title_artist = result['feed']['entry'][entry.to_i - 1]['title']['label']
        genre = result['feed']['entry'][entry.to_i - 1]['category']['attributes']['label']
        price = result['feed']['entry'][entry.to_i - 1]['im:price']['attributes']['amount'].to_f.round(2)
        currency = result['feed']['entry'][entry.to_i - 1]['im:price']['attributes']['currency']
        m.reply "iTunes Album Rank #{entry}: #{title_artist} (#{genre}) | Price: #{price} #{currency}"
      end

      def help(m)
        m.reply 'returns current album at specified iTunes rank.'
      end

    end
  end
end
