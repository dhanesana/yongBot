require 'httparty'
require 'open-uri'

class Ig
  include Cinch::Plugin

  match /(ig) (.+)/, prefix: /^(\.)/
  match /(help ig)$/, method: :help, prefix: /^(\.)/


  def execute(m, command, ig, tag)
    response = HTTParty.get("https://api.instagram.com/v1/tags/#{URI.encode(tag)}/media/recent?client_id=#{ENV['IG_ID']}")
    m.reply response["data"].first['link']
  end

  def help(m)
    m.reply 'returns most recent instagram pic related to specified hashtag'
  end

end
