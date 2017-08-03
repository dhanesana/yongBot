require 'unirest'

module Cinch
  module Plugins
    class FacePlus
      include Cinch::Plugin

      match /(faceplus) (.+)/
      match /(faceplus)$/, method: :random
      match /(help faceplus)$/, method: :help

      def execute(m, prefix, faceplus, link)
        url = URI.encode(link)
        response = Unirest.post("https://api-us.faceplusplus.com/facepp/v3/detect?image_url=#{url}&api_key=#{ENV['FACEPLUS_KEY']}&api_secret=#{ENV['FACEPLUS_SECRET']}&return_attributes=gender,age,ethnicity,emotion")
        return m.reply "Status Code: #{response.code}" if response.code != 200
        emotion = 'Emotion: '
        response.body['faces'].first['attributes']['emotion'].each do |emo|
          emotion += "#{emo[0]} => #{emo[1]}%, " if emo[1] > 9
        end
        gender = response.body['faces'].first['attributes']['gender']['value']
        age = response.body['faces'].first['attributes']['age']['value']
        race = response.body['faces'].first['attributes']['ethnicity']['value']
        m.reply "#{m.user.nick}: [#{race} #{gender}, Age: #{age}, #{emotion.chomp(', ')}]"
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
        execute(m, '.', 'faceplus', link)
      end

      def help(m)
        m.reply "facial detection for ethnicity, gender, age, and emotion using Face++ v3"
      end

    end
  end
end
