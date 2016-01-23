require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Vine
      include Cinch::Plugin

      match /(vine)$/
      match /(vine) (.+)/, method: :with_tag
      match /(help vine)$/, method: :help

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

      def with_tag(m, prefix, vine, tag)
        return m.reply "no spaces. one word tags bru" if tag.include? " "
        response = Unirest.get "https://community-vineapp.p.mashape.com/timelines/tags/#{URI.encode(tag)}",
          headers:{
            "X-Mashape-Key" => "#{ENV['MASHAPE_KEY']}",
            "Accept" => "application/json"
          }
        return m.reply "hashtag not found bru" if response.body['data']['count'] == 0
        num = rand(1..response.body['data']['records'].size) - 1
        url = response.body['data']['records'][num]['shareUrl']
        user = response.body['data']['records'][num]['username']
        desc = response.body['data']['records'][num]['description']
        m.reply "#{user}: #{desc} #{url}"
      end

      def help(m)
        m.reply 'returns random popular vine post (or specify hashtag for random hashtag related post)'
      end

    end
  end
end
