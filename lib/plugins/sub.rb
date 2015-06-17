gem 'httparty', '=0.13.5'
require 'httparty'
require 'open-uri'

class Sub
  include Cinch::Plugin

  match /(sub) (.+)/, prefix: /^(\.)/
  match /(help sub)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, sub, tag)
    encoded = URI.encode("http://www.reddit.com/r/#{tag.downcase}/new.json")
    response = HTTParty.get(URI.parse(encoded))
    link = response['data']['children'].first['data']['url']
    title = url = response['data']['children'].first['data']['title']
    m.reply "r/#{tag}: #{title} #{link}"
  end

  def help(m)
    m.reply 'returns most recent reddit post from specified subreddit'
  end

end
