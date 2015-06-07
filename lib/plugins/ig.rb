require 'httparty'
require 'open-uri'

class Ig
  include Cinch::Plugin

  match /(ig) (.+)/, prefix: /^(\.)/
  match /(help ig)$/, method: :help, prefix: /^(\.)/


  def execute(m, command, ig, tag)
    encoded = URI.encode("https://api.instagram.com/v1/tags/#{tag}/media/recent?client_id=#{ENV['IG_ID']}")
    response = HTTParty.get(URI.parse(encoded))
    m.reply response["data"].first['link']
  end

  def help(m)
    m.reply 'returns most recent instagram pic related to specified hashtag'
  end

end
