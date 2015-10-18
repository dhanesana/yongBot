require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Buzz
      include Cinch::Plugin

      match /(buzz)$/, prefix: /^(\.)/
      match /(help buzz)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        page = Nokogiri::HTML(open('http://netizenbuzz.blogspot.com/'))
        title = page.css('h3.post-title a').first.text
        url = page.css('h3.post-title a').first.attributes.first[1].value
        m.reply "#{title}: #{url}"
      end

      def help(m)
        m.reply 'returns most recent netizenbuzz post'
      end

    end
  end
end
