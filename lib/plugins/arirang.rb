require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Arirang
      include Cinch::Plugin

      match /(arirang)$/
      match /(help arirang)$/, method: :help

      def execute(m)
        feed = "http://www.arirang.com/player/onair_tv.asp"
        begin
          page = Nokogiri::HTML(open(feed))
          time = page.css('li.on strong').text.strip + "KST"
          title = page.css('li.on a').children[1].text.strip
          next_time = page.css('div.aOA_schedule_wrap strong')[1].text.strip + "KST"
          next_title = page.css('div.aOA_schedule_wrap a')[1].children[1].text.strip
          m.reply "Live (#{time}): #{title} || Next (#{next_time}): #{next_title} #{feed}"
        rescue Exception => e
          return m.reply "Error: #{e}"
        end
      end

      def help(m)
        m.reply 'returns live schedule of arirang live feed'
      end

    end
  end
end
