require 'httparty'
require 'open-uri'

module Cinch
  module Plugins
    class Ig
      include Cinch::Plugin

      match /(ig) (.+)/
      match /(help ig)$/, method: :help

      def execute(m, prefix, ig, tag)
        response = HTTParty.get("https://api.instagram.com/v1/tags/#{URI.encode(tag)}/media/recent?client_id=#{ENV['IG_ID']}")
        m.reply response["data"].first['link']
      end

      def help(m)
        m.reply 'returns most recent instagram pic related to specified hashtag'
      end

    end
  end
end
