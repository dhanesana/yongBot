require 'httparty'
require 'open-uri'

module Cinch
  module Plugins
    class Omg
      include Cinch::Plugin

      match /(omg)$/
      match /(help omg)$/, method: :help

      def execute(m)
        tag = URI.encode('오마이걸')
        response = HTTParty.get("https://api.instagram.com/v1/tags/#{tag}/media/recent?client_id=#{ENV['IG_ID']}")
        m.reply response["data"][rand(0..19)]['link']
      end

      def help(m)
        m.reply "random instagram post tagged '오마이걸' from recent posts"
      end

    end
  end
end
