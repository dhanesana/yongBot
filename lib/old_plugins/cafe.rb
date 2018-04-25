require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Cafe
      include Cinch::Plugin

      match /(cafe) (.+)/
      match /(help cafe)$/, method: :help

      def execute(m, prefix, cafe, text)
        query = text.split(/[[:space:]]/).join(' ').downcase
        response = Unirest.post "https://apis.daum.net/search/cafe?apikey=#{ENV['DAUM_KEY']}&q=#{URI.encode(query)}&result=20&output=json"
        cafe_hash = {}
        return m.reply 'no results bru' if response.body['channel']['result'] == '0'
        response.body['channel']['item'].each do |cafe|
          cafe_hash[cafe['cafeUrl']] += 1
          cafe_hash[cafe['cafeUrl']] = 1 if cafe_hash[cafe['cafeUrl']].nil?
          m.reply cafe_hash.max_by { |k,v| v }.first.strip
        end
      end

      def help(m)
        m.reply 'searches daumcafe posts and returns cafe url for cafe most posted in'
      end

    end
  end
end
