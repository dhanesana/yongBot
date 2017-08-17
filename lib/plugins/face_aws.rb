require 'aws-sdk'
require 'open-uri'
require 'httparty'

module Cinch
  module Plugins
    class Face
      include Cinch::Plugin

      match /(face) (.+)/
      match /(face)$/, method: :random
      match /(help face)$/, method: :help

      def initialize(*args)
        super
        Aws.config.update({
          region: 'us-west-2',
          credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
        })
        @client = Aws::Rekognition::Client.new
        @users = Hash.new
      end

      def execute(m, prefix, face, url)
        return post_api(m, url) if m.is_admin?
        return if $banned.include? m.user.host
        rate_check(m, 0, url)
      end

      def random(m)
        return get_kpic(m) if m.is_admin?
        return if $banned.include? m.user.host
        rate_check(m, 1, 'http://google.com')
      end

      def rate_check(m, type, url)
        if @users.keys.include? m.user.host
          if @users[m.user.host] > 2
            return m.reply 'ur doing that too much bru'
          else
            @users[m.user.host] += 1
            return get_kpic(m) if type == 1
            post_api(m, url)
          end
        else
          @users[m.user.host] = 1
          Timer(180, options = { shots: 1 }) do |x|
            @users.delete(m.user.host)
          end
          return get_kpic(m) if type == 1
          post_api(m, url)
        end
      end

      def get_kpic(m)
        kpics = HTTParty.get("http://www.reddit.com/r/kpics/new.json")
        posts = []
        kpics['data']['children'].each do |post|
          posts << post['data']['url'] unless post['data']['domain'] == 'gfycat.com' || post['data']['domain'] == 'instagram.com'
          posts << post['data']['preview']['images'].first['source']['url'] if post['data']['domain'] == 'instagram.com'
        end
        posts.delete_if { |post| post.include? 'gifv' }
        posts.delete_if { |post| post.include? '/a/' }
        posts.delete_if { |post| post.include? 'webm' }
        posts.delete_if { |post| post.include? 'gif' }
        link = posts.sample
        m.reply "r/kpics: #{link}"
        post_api(m, link)
      end

      def post_api(m, url)
        image_url = URI.encode(url)
        begin
          resp = @client.detect_faces(
            image: { bytes: open(image_url).read },
            attributes: ['ALL']
          )
        rescue Exception => e
          return m.reply "Error: #{e}"
        end
        return m.reply 'i see no face here bru' if resp.face_details.size < 1
        gender = resp.face_details[0].gender.value
        gender_conf = resp.face_details[0].gender.confidence
        age_low = resp.face_details[0].age_range.low
        age_high = resp.face_details[0].age_range.high
        emotions = ""
        resp.face_details[0].emotions.each do |emo|
          emotions += "#{emo.type} => #{emo.confidence.round(2)}%, " if emo.confidence.round(2) > 10
        end
        m.reply "#{m.user.nick}: [#{gender} (#{gender_conf.round(2)}%), Age: #{age_low}-#{age_high}, Emotions: #{emotions.chomp(', ')}]"
      end

      def help(m)
        m.reply "facial detection for gender, age, and emotion using AWS Rekognition"
      end

    end
  end
end
