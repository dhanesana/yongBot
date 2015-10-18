require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Dispatch
      include Cinch::Plugin

      match /(dispatch)$/, prefix: /^(\.)/
      match /(help dispatch)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        page = Nokogiri::HTML(open('http://www.dispatch.co.kr/today'))
        num = page.css('div#article-container div h5').size
        title = page.css('div#article-container div h5').first.text
        url = page.css('div#article-container div h5 a').first.first[1]
        m.reply "#{title}: #{url}"
      end

      def help(m)
        m.reply 'returns most recent dispatch.co.kr post'
      end

    end
  end
end
