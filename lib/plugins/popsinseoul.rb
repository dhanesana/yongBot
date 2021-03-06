require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Popsinseoul
      include Cinch::Plugin

      match /(pops)$/
      match /(popsinseoul)$/
      match /(help popsinseoul)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://www.arirang.com/Tv/Tv_Pagego.asp?sys_lang=Eng&PROG_CODE=TVCR0102'))
        sched_time = page.css('p.ment').first.text.strip
        day = page.css('li.current').children.first.text
        date = page.css('li.current').children[2].text
        response_string = ""
        num_of_feats = page.css('div.ahtml_h1').size
        i = 0
        while i < num_of_feats
          response_string += "#{page.css('div.ahtml_h1')[i].text} => "
          response_string += "#{page.css('div.ahtml_h2')[i].text}, "
          i += 1
        end
        response_string.slice!(-2..-1)
        m.reply "[#{day} #{date}] #{response_string}| #{sched_time}"
      end

      def help(m)
        m.reply 'returns current/upcoming schedule for arirang pops in seoul'
      end

    end
  end
end
