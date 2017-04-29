require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Daum
      include Cinch::Plugin

      match /(daum)$/
      match /(daum) (.+)/, method: :with_num
      match /(help daum)$/, method: :help

      def execute(m)
        with_num(m, '.', 'daum', 1)
      end

      def with_num(m, prefix, daum, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 11 bru' if num.to_i > 10
        page = Nokogiri::HTML(open('http://www.daum.net/'))
        result = page.css('.hot_issue a.link_issue')[num.to_i]
        term = result.text.strip
        url = result.first[1]
        m.reply "Daum Trending [#{num}]: #{term} #{url}"
      end

      def help(m)
        m.reply 'returns trending daum search result at specified rank'
      end

    end
  end
end
