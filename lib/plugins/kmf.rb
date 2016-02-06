require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Kmf
      include Cinch::Plugin

      match /(kmf)$/
      match /(help kmf)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://ktmf.koreatimes.com/?page_id=867'))
        lineup = []
        page.css('tr td').first.css('p').each do |act|
          next if act.text == ''
          lineup << act.text
        end
        m.reply "KMF Lineup: #{lineup.join(', ')}"
      end

      def help(m)
        m.reply 'returns upcoming lineup for korea times music festival'
      end

    end
  end
end
