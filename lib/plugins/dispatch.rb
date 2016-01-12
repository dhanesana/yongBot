require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Dispatch
      include Cinch::Plugin

      match /(dispatch)$/
      match /(help dispatch)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://www.dispatch.co.kr/today'))
        title = page.css('div.col h6').first.text
        url = "http://www.dispatch.co.kr" + page.css('div.container-fluid a').first.first[1]
        m.reply "#{title}: #{url}"
      end

      def help(m)
        m.reply 'returns most recent dispatch.co.kr post'
      end

    end
  end
end
