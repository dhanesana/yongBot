require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Wshh
      include Cinch::Plugin

      match /(wshh)$/
      match /(help wshh)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://www.worldstarhiphop.com/videos/'))
        num = rand(0..9)
        title = page.css('strong.title')[num].text
        link = page.css('strong.title a')[num]['href']
        m.reply "#{title}: http://www.worldstarhiphop.com#{link}"
      end

      def help(m)
        m.reply 'wooooorrrllddstarrrrrr (random recent post)'
      end

    end
  end
end
