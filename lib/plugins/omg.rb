require 'httparty'
require 'open-uri'

class Omg
  include Cinch::Plugin

  match /(omg)$/, prefix: /^(\.)/
  match /(help omg)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    response = HTTParty.get("https://api.instagram.com/v1/tags/오마이걸/media/recent?client_id=#{ENV['IG_ID']}")
    m.reply response["data"][rand(0..19)]['link']
  end

  def help(m)
    m.reply "random instagram post tagged '오마이걸' from recent posts"
  end

end
