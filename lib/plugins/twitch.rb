require 'unirest'
require 'open-uri'

class Twitch
  include Cinch::Plugin

  timer 600, method: :check_live
  match /(twitch)$/, prefix: /^(\.)/
  match /(twitch) (.+)/, method: :check_user, prefix: /^(\.)/
  match /(help twitch)$/, method: :help, prefix: /^(\.)/

  def initialize(*args)
    super
    @users = ENV['TWITCH_USERS'].split(',')
  end

  def execute(m)
    response = "Live:"
    @users.each do |user|
      user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(user)}"
      next if user_get.body['stream'].nil?
      title = user_get.body['stream']['game']
      url = user_get.body['stream']['channel']['url']
      name = user_get.body['stream']['channel']['display_name']
      viewers = user_get.body['stream']['viewers']
      response += " #{url} |"
    end
    return m.reply "none of the twitch channels are live bru" if response.size < 6
    m.reply response
  end

  def check_live
    response = "Live:"
    @users.each do |user|
      user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(user)}"
      next if user_get.body['stream'].nil?
      title = user_get.body['stream']['game']
      url = user_get.body['stream']['channel']['url']
      name = user_get.body['stream']['channel']['display_name']
      viewers = user_get.body['stream']['viewers']
      response += " #{url} |"
    end
    return if response.size < 6
    ENV["CHANNELS"].split(',').each do |channel|
      Channel(channel).send response
    end
  end

  def check_user(m, command, check_user, user)
    query = user.split(/[[:space:]]/).join(' ')
    user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(query)}"
    return m.reply "#{user} is not live bru" if user_get.body['stream'].nil?
    title = user_get.body['stream']['game']
    url = user_get.body['stream']['channel']['url']
    name = user_get.body['stream']['channel']['display_name']
    viewers = user_get.body['stream']['viewers']
    m.reply "#{name} is streaming #{title}, Viewers: #{viewers}, #{url}"
  end

  def help(m)
    m.reply "checks every 10 minutes for live specified twitch channels."
    m.reply "type .twitch [user] to check specific channel for detailed info"
  end

end
