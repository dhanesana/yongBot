require 'httparty'
require 'open-uri'

class Viki
  include Cinch::Plugin

  match /(viki) (.+)/, prefix: /^(\.)/
  match /(help viki)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, viki, keywords)
    query = keywords.split(/[[:space:]]/).join(' ').downcase
    response = HTTParty.get("http://api.viki.io/v4/search.json?term=#{URI.encode(query)}&app=#{ENV['VIKI']}")
    return m.reply "no drama found bru" if response['response'] == []
    title = response['response'].first['titles']['en']
    rating = response['response'].first['rating']
    url = response['response'].first['url']['web']
    episodes_count = response['response'].first['episodes']['count']
    m.reply "#{title} | #{rating} | Episodes: #{episodes_count} | #{url}"
  end

  def help(m)
    m.reply 'returns first viki result for specified kdrama'
  end

end
