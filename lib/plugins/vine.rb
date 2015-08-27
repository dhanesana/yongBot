require 'unirest'

class Vine
  include Cinch::Plugin

  match /(vine)$/, prefix: /^(\.)/
  match /(help vine)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    response = Unirest.get "https://community-vineapp.p.mashape.com/timelines/popular",
      headers:{
        "X-Mashape-Key" => "#{ENV['MASHAPE_KEY']}",
        "Accept" => "application/json"
      }
    num = response.body['data']['records'].size
    url = response.body['data']['records'][num - 1]['shareUrl']
    user = response.body['data']['records'][num - 1]['username']
    desc = response.body['data']['records'][num - 1]['description']
    m.reply "#{user}: #{desc} #{url}"
  end

  def help(m)
    m.reply 'returns random popular vine post'
  end

end
