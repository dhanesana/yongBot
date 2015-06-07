require 'httparty'
require 'open-uri'

class Lovelyz
  include Cinch::Plugin

  match /(lovelyz)$/, prefix: /^(\.)/
  match /(help lovelyz)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    encoded = URI.encode("https://api.instagram.com/v1/tags/러블리즈/media/recent?client_id=#{ENV['IG_ID']}")
    response = HTTParty.get(URI.parse(encoded))
    m.reply response["data"][rand(0..19)]['link']
  end

  def help(m)
    m.reply "random instagram post tagged '러블리즈' from recent posts"
  end

end
