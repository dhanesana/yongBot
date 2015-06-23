require 'httparty'
require 'open-uri'

class Fresh
  include Cinch::Plugin

  match /(fresh)$/, prefix: /^(\.)/
  match /(help fresh)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    response = HTTParty.get("http://www.reddit.com/r/hiphopheads/.json")
    fresh = {}
    response['data']['children'].each do |post|
      fresh[post['data']['title']] = post['data']['url'] if post['data']['title'].include? '[FRESH'
    end
    fresh_array = fresh.to_a
    num = rand(0..fresh_array.size - 1)
    m.reply "#{fresh_array[num][0]}: #{fresh_array[num][1]}"
  end

  def help(m)
    m.reply 'returns random [FRESH] post from r/hiphopheads'
  end

end
