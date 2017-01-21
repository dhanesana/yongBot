require 'unirest'
require 'open-uri'
require 'pg'

module Cinch
  module Plugins
    class Twitch
      include Cinch::Plugin

      timer 300, method: :check_live
      match /(twitch)$/
      match /(twitch) (.+)/, method: :check_user
      match /(help twitch)$/, method: :help

      def initialize(*args)
        super
        @users = ENV['TWITCH_USERS'].split(',')
        @online = []
      end

      def execute(m)
        counter = 0
        @users.each do |user|
          user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(user)}",
            headers: { "Accept" => "application/json" },
            parameters: { :client_id => ENV['TWITCH_ID'] }
          counter += 1 if user_get.body['stream'].nil?
          return m.reply "no1 streaming" if counter == @users.size
          next if user_get.body['stream'].nil?
          game = user_get.body['stream']['game']
          url = user_get.body['stream']['channel']['url']
          name = user_get.body['stream']['channel']['display_name']
          title = user_get.body['stream']['channel']['status']
          title = 'No Title' if title == ''
          viewers = user_get.body['stream']['viewers']
          m.reply "LIVE: '#{title}' (#{name} playing #{game}) => #{url}"
        end
      end

      def check_live
        response = "LIVE:"
        @users.each do |user|
          user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(user)}",
            headers: { "Accept" => "application/json" },
            parameters: { :client_id => ENV['TWITCH_ID'] }
          @online.delete(user) if user_get.body['stream'].nil?
          next if user_get.body['stream'].nil?
          next if @online.include? user
          @online << user
          game = user_get.body['stream']['game']
          url = user_get.body['stream']['channel']['url']
          name = user_get.body['stream']['channel']['display_name']
          title = user_get.body['stream']['channel']['status']
          title = 'No Title' if title == ''
          viewers = user_get.body['stream']['viewers']
          ENV["TWITCH_CHANNELS"].split(',').each do |channel|
            Channel(channel).send "LIVE: '#{title}' (#{name} playing #{game}) => #{url}"
          end
        end
      end

      def check_user(m, prefix, check_user, user)
        query = user.split(/[[:space:]]/).join(' ')
        user_get = Unirest.get "https://api.twitch.tv/kraken/streams/#{URI.encode(query)}",
          headers: { "Accept" => "application/json" },
          parameters: { :client_id => ENV['TWITCH_ID'] }
        return m.reply "#{user} is not live bru" if user_get.body['stream'].nil?
        game = user_get.body['stream']['game']
        url = user_get.body['stream']['channel']['url']
        name = user_get.body['stream']['channel']['display_name']
        title = user_get.body['stream']['channel']['status']
        title = 'No Title' if title == ''
        viewers = user_get.body['stream']['viewers']
        m.reply "'#{title}' (#{name} playing #{game}), Viewers: #{viewers} => #{url}"
      end

      def help(m)
        m.reply "checks every 5 minutes if specified twitch broadcasts are live."
        m.reply "type .twitch [user] to check status of specific twitch user"
      end

    end
  end
end
