require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Sh
      include Cinch::Plugin

      match /(sh)$/, prefix: /^(\.)/
      match /(help sh)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        html = open('http://www.speedhunters.com/category/content/')
        page = Nokogiri::HTML(html.read)
        page.encoding = 'utf-8'
        articles_num = page.css('h2 a').size
        num = rand(0..articles_num - 1)
        title = page.css('h2 a')[num].text
        link = page.css('h2 a')[num]['href']
        m.reply "#{title} | #{link}"
      end

      def help(m)
        m.reply "returns random recent speedhunters article"
      end

    end
  end
end
