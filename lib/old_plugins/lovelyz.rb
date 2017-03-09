require 'httparty'
require 'open-uri'

module Cinch
  module Plugins
    class Lovelyz
      include Cinch::Plugin

      match /(lovelyz)$/
      match /(help lovelyz)$/, method: :help

      def execute(m)
        tag = URI.encode('러블리즈')
        response = HTTParty.get("https://api.instagram.com/v1/tags/#{tag}/media/recent?client_id=#{ENV['IG_ID']}")
        m.reply response["data"][rand(0..19)]['link']
      end

      def help(m)
        m.reply "random instagram post tagged '러블리즈' from recent posts"
      end

    end
  end
end
