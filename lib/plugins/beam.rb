require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Beam
      include Cinch::Plugin

      timer 300, method: :check_live
      match /(beam)$/
      match /(beam) (.+)/, method: :check_user
      match /(help beam)$/, method: :help

      def initialize(*args)
        super
        @users = ENV['BEAM_USERS'].split(',')
        @online = []
      end

      def execute(m)
        counter = 0
        @users.each do |user|
          user_get = Unirest.get "https://beam.pro/api/v1/channels/#{URI.encode(user)}"
          counter += 1 if user_get.body['online'] == false
          return m.reply "no1 streaming" if counter == @users.size
          next if user_get.body['online'] == false
          name = user_get.body['user']['username']
          game = user_get.body['type']['name']
          title = user_get.body['name']
          viewers = user_get.body['viewersCurrent']
          url = "https://beam.pro/#{URI.encode(user)}"
          m.reply "LIVE: '#{title}' (#{name} playing #{game}) => #{url}"
        end
      end

      def check_live
        response = "LIVE:"
        @users.each do |user|
          user_get = Unirest.get "https://beam.pro/api/v1/channels/#{URI.encode(user)}"
          @online.delete(user) if user_get.body['online'] == false
          next if user_get.body['online'] == false
          next if @online.include? user
          @online << user
          game = user_get.body['type']['name']
          url = "https://beam.pro/#{URI.encode(user)}"
          name = user_get.body['user']['username']
          title = user_get.body['name']
          viewers = user_get.body['viewersCurrent']
          ENV["TWITCH_CHANNELS"].split(',').each do |channel|
            Channel(channel).send "LIVE: '#{title}' (#{name} playing #{game}) => #{url}"
          end
        end
      end

      def check_user(m, prefix, check_user, user)
        query = user.split(/[[:space:]]/).join(' ')
        user_get = Unirest.get "https://beam.pro/api/v1/channels/#{URI.encode(query)}"
        return m.reply "#{user} is not live bru" if user_get.body['online'] == false
        game = user_get.body['type']['name']
        url = "https://beam.pro/#{URI.encode(query)}"
        name = user_get.body['user']['username']
        title = user_get.body['name']
        viewers = user_get.body['viewersCurrent']
        m.reply "'#{title}' (#{name} playing #{game}), Viewers: #{viewers} => #{url}"
      end

      def help(m)
        m.reply "checks every 5 minutes if specified beam broadcasts are live."
        m.reply "type .beam [user] to check status of specific beam user"
      end

    end
  end
end
