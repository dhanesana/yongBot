require 'unirest'

module Cinch
  module Plugins
    class FacePlus
      include Cinch::Plugin

      match /(faceplus) (.+)/
      match /(faceplus)$/, method: :random
      match /(help faceplus)$/, method: :help

      def execute(m, prefix, face, link)
        url = URI.encode(link)
        response = Unirest.get("https://apius.faceplusplus.com/v2/detection/detect?url=#{url}&api_secret=#{ENV['FACEPLUS_SECRET']}&api_key=#{ENV['FACEPLUS_KEY']}&attribute=glass,gender,age,race,smiling")
        # Error Code Handling
        return m.reply "Status Code: #{response.code}" if response.code != 200
        age = response.body['face'].first['attribute']['age']['value']
        range = response.body['face'].first['attribute']['age']['range']
        gender = response.body['face'].first['attribute']['gender']['value']
        race = response.body['face'].first['attribute']['race']['value']
        smiling_percent = response.body['face'].first['attribute']['smiling']['value'].round(2)
        glasses = response.body['face'].first['attribute']['glass']['value']
        glasses = "Sunglasses" if response.body['face'].first['attribute']['glass']['value'] == "Dark"
        m.reply "#{race} #{gender} | Age: #{age} ± #{range} | #{smiling_percent}% Smiling | Glasses: #{glasses}"
      end

      def random(m)
        kpics = Unirest.get("http://www.reddit.com/r/kpics/new.json")
        posts = []
        kpics.body['data']['children'].each do |post|
          posts << post['data']['url'] unless post['data']['domain'] == 'gfycat.com' || post['data']['domain'] == 'instagram.com'
          posts << post['data']['preview']['images'].first['source']['url'] if post['data']['domain'] == 'instagram.com'
        end
        posts.delete_if { |post| post.include? 'gifv' }
        posts.delete_if { |post| post.include? '/a/' }
        posts.delete_if { |post| post.include? 'webm' }
        posts.delete_if { |post| post.include? 'gif' }
        link = posts.sample
        m.reply "r/kpics #{link}"
        url = URI.encode(link)
        response = Unirest.get("https://apius.faceplusplus.com/v2/detection/detect?url=#{url}&api_secret=#{ENV['FACEPLUS_SECRET']}&api_key=#{ENV['FACEPLUS_KEY']}&attribute=glass,gender,age,race,smiling")
        # Error Code Handling
        return m.reply "Status Code: #{response.code}" if response.code != 200
        age = response.body['face'].first['attribute']['age']['value']
        range = response.body['face'].first['attribute']['age']['range']
        gender = response.body['face'].first['attribute']['gender']['value']
        race = response.body['face'].first['attribute']['race']['value']
        smiling_percent = response.body['face'].first['attribute']['smiling']['value'].round(2)
        glasses = response.body['face'].first['attribute']['glass']['value']
        glasses = "Sunglasses" if response.body['face'].first['attribute']['glass']['value'] == "Dark"
        m.reply "#{race} #{gender} | Age: #{age} ± #{range} | #{smiling_percent}% Smiling | Glasses: #{glasses}"
      end

      def help(m)
        m.reply "facial detection for race, gender, age, smiling, and glasses"
      end

    end
  end
end
