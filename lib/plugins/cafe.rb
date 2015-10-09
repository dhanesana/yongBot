require 'unirest'
require 'open-uri'

class Cafe
  include Cinch::Plugin

  match /(cafe) (.+)/, prefix: /^(\.)/
  match /(help cafe)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, cafe, text)
    query = text.split(/[[:space:]]/).join(' ').downcase
    response = Unirest.post "https://apis.daum.net/search/cafe?apikey=#{ENV['DAUM_KEY']}&q=#{URI.encode(query)}&result=20&output=json"
    cafe_hash = {}
    return m.reply 'no results bru' if response.body['channel']['result'] == '0'
    response.body['channel']['item'].each do |cafe|
      if cafe_hash[cafe['cafeUrl']].nil?
        cafe_hash[cafe['cafeUrl']] = 1
      else
        cafe_hash[cafe['cafeUrl']] += 1
      end
    end
    m.reply cafe_hash.max_by {|k,v| v}.first
  end

  def help(m)
    m.reply 'searches daumcafe posts and returns cafe url for most frequent '
  end

end
