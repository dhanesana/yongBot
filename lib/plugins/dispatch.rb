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
        title = page.css('div.content-wrapper article')[1].text.strip
        url = "http://www.dispatch.co.kr" + page.css('div.content-wrapper a')[1].values.first
        m.reply "#{title}: #{url}"
      end

      def help(m)
        m.reply 'returns most recent dispatch.co.kr post'
      end

    end
  end
end
