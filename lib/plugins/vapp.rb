require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Vapp
      include Cinch::Plugin

      match /(vapp)$/
      match /(vlive)$/
      match /(help vapp)$/, method: :help
      match /(help vlive)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open("http://www.vlive.tv/upcoming"))
        return m.reply 'no live vapp streams bru' if page.css('li.on').size < 2
        live = {}
        page.css('li.on').each do |artist|
          next if artist.css('em.title').text == ''
          live[artist.css('em.title').text] = "http://www.vlive.tv#{artist.css('a').first['href']}"
        end
        live.to_a.each do |pair|
          m.reply "#{pair[0]} => #{pair[1]}"
        end
      end

      def help(m)
        m.reply 'returns live vapp streams their urls'
      end

    end
  end
end
