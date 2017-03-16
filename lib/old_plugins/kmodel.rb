require 'httparty'
require 'open-uri'

module Cinch
  module Plugins
    class Kmodel
      include Cinch::Plugin

      match /(kmodel)$/
      match /(help kmodel)$/, method: :help

      def execute(m)
        resp = HTTParty.get('http://www.reddit.com/r/KoreanModel/new.json')
        num = resp['data']['children'].size
        m.reply "r/KoreanModel: #{resp['data']['children'][rand(0..num - 1)]['data']['url']}"
      end

      def help(m)
        m.reply 'returns most recent r/KoreanModel post'
      end

    end
  end
end
