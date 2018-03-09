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
        page = Nokogiri::HTML(open("http://www.vlive.tv/upcoming", "User-Agent" => "Ruby/#{RUBY_VERSION}"))
        return m.reply 'no live vapp streams bru' if page.css('li.on').size < 2
        live = {}
        page.css('li.on').each do |artist|
          next if artist.css('em.title').text.strip == ''
          live[artist.css('em.title').text.strip] = "http://www.vlive.tv#{artist.css('a').first['href']}"
        end
        if live.to_a.size < 4
          live.to_a.each do |pair|
            m.reply "#{pair[0]} => #{pair[1]}"
          end
        else
          response = ""
          live.to_a.each do |pair|
            response += "[#{pair[0]} => #{pair[1]}], "
          end
          m.reply response.chomp(', ')
        end
      end

      def help(m)
        m.reply 'returns live vapp streams their urls'
      end

    end
  end
end
