require 'open-uri'
require 'json'
require 'cgi'

module Cinch
  module Plugins
    class Kwikia
      include Cinch::Plugin

      match /(kwikia) (.+)/, prefix: /^(\.)/
      match /(help kwikia)$/, method: :help, prefix: /^(\.)/

      def execute(m, prefix, kwikia, term)
        begin
          term_array = term.split(/[[:space:]]/)
          search_terms = term_array.join(' ').downcase
          feed = open("http://kpop.wikia.com/api/v1/Search/List/?query=#{URI.encode(search_terms)}&limit=25").read
        rescue
          return m.reply 'nothing found bru' if feed.nil?
        end
        result = JSON.parse(feed)
        url = result['items'].first['url']
        kpop_id = result['items'].first['id']
        feed_2 = open("http://kpop.wikia.com/api/v1/Articles/Details/?ids=#{kpop_id}&abstract=350").read
        result_2 = JSON.parse(feed_2)
        result_ab = result_2['items'].first[1]['abstract']
        abstract = CGI.unescape_html(result_ab).gsub(/"/, '').gsub(/\s+/, ' ')
        m.reply "#{abstract}.. | #{url}"
      end

      def help(m)
        m.reply 'Searches kpop wikia and returns a short abstract related to the search term'
      end

    end
  end
end
