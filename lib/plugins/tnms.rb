require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Tnms
      include Cinch::Plugin

      match /(tnms)$/
      match /(tnms) (.+)/, method: :with_num
      match /(help tnms)$/, method: :help

      def execute(m)
        with_num(m, '.', 'tnms', 1)
      end

      def with_num(m, prefix, tnms, num)
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 21 bru' if num.to_i > 20
        rank = num.to_i - 1
        page = Nokogiri::HTML(open('http://www.tnms.tv/rating/default.asp'))
        station = page.css('tr.margin2')[rank].css('td')[2].text.strip
        title = page.css('tr.margin2')[rank].css('td')[1].text.strip
        rating = page.css('tr.margin2')[rank].css('td')[3].text.gsub(/\A\p{Space}*/, '')
        m.reply "TNmS Rank #{num}: #{station} - #{title}, Rating: #{rating}"
      end

      def help(m)
        m.reply 'returns tv show at specified daily TNmS rank'
      end

    end
  end
end
