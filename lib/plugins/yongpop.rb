require 'httparty'
require 'open-uri'

class Yongpop
  include Cinch::Plugin

  match /(yongpop)$/, prefix: /^(\.)/
  match /(help yongpop)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    response = HTTParty.get("https://api.instagram.com/v1/tags/크레용팝/media/recent?client_id=#{ENV['IG_ID']}")
    m.reply response["data"][rand(0..19)]['link']
  end

  def help(m)
    m.reply "random instagram post tagged '크레용팝' from recent posts"
  end

end
