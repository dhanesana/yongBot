require 'httparty'
require 'open-uri'

module Cinch
  module Plugins
    class Yongpop
      include Cinch::Plugin

      match /(yongpop)$/
      match /(help yongpop)$/, method: :help

      def execute(m)
        tag = URI.encode('크레용팝')
        response = HTTParty.get("https://api.instagram.com/v1/tags/#{tag}/media/recent?client_id=#{ENV['IG_ID']}")
        m.reply response["data"][rand(0..19)]['link']
      end

      def help(m)
        m.reply "random instagram post tagged '크레용팝' from recent posts"
      end

    end
  end
end
