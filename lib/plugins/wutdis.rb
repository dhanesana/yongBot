require 'open-uri'
require 'unirest'

module Cinch
  module Plugins
    class Wutdis
      include Cinch::Plugin

      match /(wutdis) (.+)/
      match /(help wutdis)$/, method: :help

      def execute(m, prefix, wutdis, link)
        url = URI.encode(link)
        response = Unirest.post "http://rekognition.com/func/api/?api_key=#{ENV['REKOGNITION_KEY']}&api_secret=#{ENV['REKOGNITION_SECRET']}&jobs=scene_understanding_3&urls=#{url}"
        match_one = response.body['scene_understanding']['matches'].first['tag']
        score_one = (response.body['scene_understanding']['matches'].first['score'].to_f * 100).round(2)
        if score_one.to_i >= 70
          m.reply "looks like a #{match_one.downcase}.. i'm #{score_one}% sure!"
        else
          m.reply "looks like a #{match_one.downcase}.. maybe. i'm #{score_one.to_i}% sure"
        end
      end

      def help(m)
        m.reply 'returns a description of a specified image'
      end

    end
  end
end
