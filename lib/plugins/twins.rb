require 'open-uri'
require 'unirest'

module Cinch
  module Plugins
    class Twins
      include Cinch::Plugin

      match /(twins) (.+)/, prefix: /^(\.)/
      match /(help twins)$/, method: :help, prefix: /^(\.)/

      def execute(m, prefix, twins, links)
        urls = links.split(/[[:space:]]/)
        url = URI.encode(urls[0])
        url_2 = URI.encode(urls[1])
        response = Unirest.post "http://rekognition.com/func/api/?api_key=#{ENV['REKOGNITION_KEY']}&api_secret=#{ENV['REKOGNITION_SECRET']}&jobs=face_compare&urls=#{url}&urls_compare=#{url_2}",
          headers:{
            "X-Mashape-Key" => "#{ENV['MASHAPE_KEY']}",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept" => "application/json"
          }
        return m.reply "sumn wrong wit ur first pic bru" if response.body['face_detection'].nil?
        return m.reply "sumn wrong wit ur 2nd pic bru" if response.body['face_detection'].size == 1
        score = response.body['face_detection'][1]['matches'].first['score'].to_f * 100
        return m.reply "same person bru. im #{score}% sure" if score == 100
        return m.reply "#{score}% is the same person. maybe twins? iono" if score > 70
        m.reply "#{score}% is the same person"
      end

      def help(m)
        m.reply 'returns a facial similarity score for two specified images'
      end

    end
  end
end
