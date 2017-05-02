require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Naver
      include Cinch::Plugin

      match /(naver)$/
      match /(naver) (.+)/, method: :with_num
      match /(help naver)$/, method: :help

      def execute(m)
        with_num(m, '.', 'naver', 1)
      end

      def with_num(m, prefix, naver, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 21 bru' if num.to_i > 20
        page = Nokogiri::HTML(open('http://datalab.naver.com/keyword/realtimeList.naver?where=main'))
        term = page.css('div.keyword_rank')[4].css('span.title')[num.to_i - 1].text
        date_time = page.css('div.keyword_rank')[4].css('strong.v2').first.text
        m.reply "Naver Trending #{num.to_i}: #{term} https://search.naver.com/search.naver?query=#{term} | #{date_time}"
      end

      def help(m)
        m.reply 'returns trending naver search term at specified rank'
      end

    end
  end
end
