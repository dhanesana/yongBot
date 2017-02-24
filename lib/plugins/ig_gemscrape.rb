require 'ruby-instagram-scraper'

module Cinch
  module Plugins
    class Ig
      include Cinch::Plugin

      match /(ig) (.+)/
      match /(help ig)$/, method: :help

      def execute(m, prefix, ig, text)
        query = text.split(/[[:space:]]/).join(' ').downcase
        return m.reply 'no spaces bru' if query.include? " "
        return get_post(m, '.', 'ig', query.slice(1..-1)) if query[0] == '#'
        get_userpost(m, '.', 'ig', query)
      end

      def get_post(m, prefix, ig, tag)
        nodes = RubyInstagramScraper.get_tag_media_nodes(URI.encode(tag))
        return m.reply 'no posts found bru' if nodes == []
        m.reply "https://www.instagram.com/p/#{nodes.first['code']}/"
      end

      def get_userpost(m, prefix, ig, usr)
        begin
          nodes = RubyInstagramScraper.get_user_media_nodes(URI.encode(usr))
          return m.reply 'no posts found bru' if nodes == []
          m.reply "https://www.instagram.com/p/#{nodes.first['code']}/"
        rescue
          m.reply "User '#{user}' not found bru"
        end
      end

      def help(m)
        m.reply 'searches for most recent Instagram post of specified user or #hashtag'
      end

    end
  end
end
