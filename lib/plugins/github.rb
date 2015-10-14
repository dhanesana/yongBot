require 'unirest'
require 'open-uri'

class Github
  include Cinch::Plugin

  match /(github) (.+)/, prefix: /^(\.)/
  match /(help github)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, github, user)
    response = Unirest.get("https://api.github.com/users/#{URI.encode(user)}/repos?&sort=pushed&client_id=#{ENV['GITHUB_ID']}&client_secret=#{ENV['GITHUB_SECRET']}").body
    return m.reply "user not found bru" if response.first[1] == 'Not Found'
    i = 0
    while i < 100
      repo = response[i]['name']
      response_2 = Unirest.get("https://api.github.com/repos/#{user}/#{repo}/commits?&client_id=#{ENV['GITHUB_ID']}&client_secret=#{ENV['GITHUB_SECRET']}").body
      if response_2.first[1].nil?
        message = response_2.first['commit']['message']
        message = message.slice(0..(message.index("\n") - 1)) if message.include? "\n"
        commit_url = response_2.first['html_url']
        break
      else
        i += 1
      end
    end
    m.reply "Last Commit: '#{message}' #{commit_url}"
  end

  def help(m)
    m.reply 'returns most recently pushed commit message from specified github user'
  end

end
