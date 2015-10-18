require 'json'
require 'open-uri'
require 'rss'

module Cinch
  module Plugins
    class Yomama
      include Cinch::Plugin

      match /(yomama)$/
      match /(help yomama)$/, method: :help

      def execute(m)
        link = open("http://api.yomomma.info/").read
        result = JSON.parse(link)
        m.reply result['joke']
      end

      def help(m)
        m.reply "yo mama so stupid, she couldn't figure out what .yomama does"
      end

    end
  end
end
