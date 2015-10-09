require 'httparty'
require 'open-uri'

class Github
  include Cinch::Plugin

  match /(github) (.+)/, prefix: /^(\.)/
  match /(help github)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, github, user)
    resp = HTTParty.get("https://api.github.com/users/#{user}/events")
    m.reply resp.first['payload']
    message = resp.first['payload']['commits'].first['message']
    url = resp.first['payload']['commits'].first['url']
    resp_2 = HTTParty.get(url)
    commit_url = resp_2['html_url']
    m.reply "Last commit: #{message} | #{commit_url}"
  end

  def help(m)
    m.reply 'returns most recent commit from specified github user'
  end

end
