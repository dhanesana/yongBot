require 'open-uri'
require 'unirest'
require 'httparty'
require 'pg'

module Cinch
  module Plugins
    class Face
      include Cinch::Plugin

      match /(face) (.+)/
      match /(face)$/, method: :random
      match /(face top)$/, method: :top
      match /(face low)$/, method: :low
      match /(help face)$/, method: :help
      match /(help face top)$/, method: :help_top
      match /(help face low)$/, method: :help_low

      def initialize(*args)
        super
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        begin
          res = conn.exec_params("create table top (url varchar, score decimal);")
          res_2 = conn.exec_params("create table low (url varchar, score decimal);")
          conn.exec(
            "INSERT INTO top (url, score) VALUES ('http://google.com', 0.001);"
          )
          conn.exec(
            "INSERT INTO low (url, score) VALUES ('http://apple.com', 100);"
          )
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Table creation failed: #{pg_error.message}"
        end
      end

      def top(m)
        conn_scores = PG::Connection.new(ENV['DATABASE_URL'])
        urls = conn_scores.exec("SELECT url FROM top")
        scores = conn_scores.exec("SELECT score FROM top")
        m.reply "#{urls[0]['url']} Beauty: #{scores[0]['score']}/100"
      end

      def low(m)
        conn_scores = PG::Connection.new(ENV['DATABASE_URL'])
        urls = conn_scores.exec("SELECT url FROM low")
        scores = conn_scores.exec("SELECT score FROM low")
        m.reply "#{urls[0]['url']} Beauty: #{scores[0]['score']}/100"
      end

      def execute(m, prefix, face, link)
        url = URI.encode(link)
        response = Unirest.post "http://rekognition.com/func/api/?api_key=#{ENV['REKOGNITION_KEY']}&api_secret=#{ENV['REKOGNITION_SECRET']}&jobs=face_aggressive_part_gender_age_emotion_beauty_race_recognize&urls=#{url}",
          headers:{
            "X-Mashape-Key" => "#{ENV['MASHAPE_KEY']}",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept" => "application/json"
          }
        return m.reply 'no face detected bru' if response.body['face_detection'] == []

        race = ''
        response.body['face_detection'].first['race'].each_key { |key| race += key }

        age = response.body['face_detection'].first['age'].to_i
        beauty = (response.body['face_detection'].first['beauty'] * 100).round(3)
        gender = response.body['face_detection'].first['sex']
        sex = 'Male' if gender >= 0.5
        sex = 'Female' if gender < 0.5
        status = 'ill3gal'
        status = 'legal' if age > 17

        hash = { link => beauty }
        scores_db = PG::Connection.new(ENV['DATABASE_URL'])
        top_urls = scores_db.exec("SELECT url from top")
        top_scores = scores_db.exec("SELECT score from top")
        high_score = top_scores[0]['score'].to_f
        low_urls = scores_db.exec("SELECT url from low")
        low_scores = scores_db.exec("SELECT score from low")
        low_score = low_scores[0]['score'].to_f
        if beauty > high_score && sex == 'Female'
          scores_db.exec(
            "update top set score = #{beauty} where score = #{high_score}"
          )
          scores_db.exec(
            "update top set url = '#{link}' where url = '#{top_urls[0]['url']}'"
          )
          m.reply "ding ding ding new high score"
        end
        if beauty < low_score
          scores_db.exec(
            "update low set score = #{beauty} where score = #{low_score}"
          )
          scores_db.exec(
            "update low set url = '#{link}' where url = '#{low_urls[0]['url']}'"
          )
          m.reply "dun dun dun new low score..."
        end

        m.reply "#{race.capitalize} #{sex} | Age: #{age} | Status: #{status} | Beauty: #{beauty}/100"
      end

      def random(m)
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
        m.reply "r/kpics #{link}"
        url = URI.encode(link)
        response = Unirest.post "http://rekognition.com/func/api/?api_key=#{ENV['REKOGNITION_KEY']}&api_secret=#{ENV['REKOGNITION_SECRET']}&jobs=face_aggressive_part_gender_age_emotion_beauty_race_recognize&urls=#{url}",
          headers:{
            "X-Mashape-Key" => "#{ENV['MASHAPE_KEY']}",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept" => "application/json"
          }
        return m.reply 'no face detected bru' if response.body['face_detection'] == []

        race = ''
        response.body['face_detection'].first['race'].each_key { |key| race += key }

        age = response.body['face_detection'].first['age'].to_i
        beauty = (response.body['face_detection'].first['beauty'] * 100).round(3)
        gender = response.body['face_detection'].first['sex']
        sex = 'Male' if gender >= 0.5
        sex = 'Female' if gender < 0.5
        status = 'ill3gal'
        status = 'legal' if age > 17

        hash = { link => beauty }
        scores_db = PG::Connection.new(ENV['DATABASE_URL'])
        top_urls = scores_db.exec("SELECT url from top")
        top_scores = scores_db.exec("SELECT score from top")
        high_score = top_scores[0]['score'].to_f
        low_urls = scores_db.exec("SELECT url from low")
        low_scores = scores_db.exec("SELECT score from low")
        low_score = low_scores[0]['score'].to_f
        if beauty > high_score && sex == 'Female'
          scores_db.exec(
            "update top set score = #{beauty} where score = #{high_score}"
          )
          scores_db.exec(
            "update top set url = '#{link}' where url = '#{top_urls[0]['url']}'"
          )
          m.reply "ding ding ding new high score"
        end
        if beauty < low_score
          scores_db.exec(
            "update low set score = #{beauty} where score = #{low_score}"
          )
          scores_db.exec(
            "update low set url = '#{link}' where url = '#{low_urls[0]['url']}'"
          )
          m.reply "dun dun dun new low score..."
        end

        m.reply "#{race.capitalize} #{sex} | Age: #{age} | Status: #{status} | Beauty: #{beauty}/100"
      end

      def help(m)
        m.reply "returns estimated race, sex, age, and beauty for specified image (if image isn't specified, random image from kpics is used)"
      end

      def help_top(m)
        m.reply 'returns highest beauty scored image'
      end

      def help_low(m)
        m.reply 'returns lowest beauty scored image'
      end

    end
  end
end
