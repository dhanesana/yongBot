require 'nokogiri'
require 'open-uri'
require 'cgi'

module Cinch
  module Plugins
    class Lineup
      include Cinch::Plugin

      match /(lineup)/
      match /(help lineup)$/, method: :help

      def execute(m)
        html = open('http://yongchicken.herokuapp.com/lineup')
        doc = Nokogiri::HTML(html.read)
        doc.encoding = 'utf-8'
        text = doc.css('body').text
        escaped_text = CGI.unescape_html(text).gsub(/"/, '').gsub(/\s+/, ' ')
        m.reply escaped_text
      end

      def help(m)
        m.reply "returns today/tonight's music show lineup (manually updated)"
      end

    end
  end
end
