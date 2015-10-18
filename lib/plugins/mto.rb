require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Mto
      include Cinch::Plugin

      match /(mto)$/, prefix: /^(\.)/
      match /(help mto)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        num = rand(0..19)
        page = Nokogiri::HTML(open('http://mediatakeout.com/'))
        title = page.css('a.article')[num].text
        url = page.css('a.article')[num].first[1]
        m.reply "#{title}: #{url}"
      end

      def help(m)
        m.reply 'returns random recent mediatakeout post'
      end

    end
  end
end
