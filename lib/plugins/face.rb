require 'open-uri'
require 'unirest'
require 'httparty'
require 'pg'

module Cinch
  module Plugins
    class Face
      include Cinch::Plugin

      match /(face) (.+)/
      match /(drop face)$/, method: :drop
      match /(face)$/, method: :random
      match /(face top)$/, method: :top
      match /(face high)$/, method: :top
      match /(face low)$/, method: :low
      match /(face bottom)$/, method: :low
      match /(help face)$/, method: :help
      match /(help face top)$/, method: :help_top
      match /(help face high)$/, method: :help_top
      match /(help face low)$/, method: :help_low
      match /(help face bottom)$/, method: :help_low

      def initialize(*args)
        super
        @users = Hash.new
        create_table
      end

      def create_table
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
        scores_hash(conn)
      end

      def scores_hash(conn)
        top_urls = conn.exec("SELECT url FROM top;")
        top_scores = conn.exec("SELECT score FROM top;")
        low_urls = conn.exec("SELECT url FROM low;")
        low_scores = conn.exec("SELECT score FROM low;")
        @scores = {
          top: [top_urls[0]['url'], top_scores[0]['score']],
          low: [low_urls[0]['url'], low_scores[0]['score']]
        }
      end

      def drop(m)
        if m.is_admin?
          conn = PG::Connection.new(ENV['DATABASE_URL'])
          conn.exec("DROP TABLE top;")
          conn.exec("DROP TABLE low;")
          m.reply 'donezo'
          create_table
        else
          return m.is_unauthorized
        end
      end

      def top(m)
        m.reply "#{@scores[:top][0]} Beauty: #{@scores[:top][1]}/100"
      end

      def low(m)
        m.reply "#{@scores[:low][0]} Beauty: #{@scores[:low][1]}/100"
      end

      def execute(m, prefix, face, url)
        link = URI.encode(url)
        return get_scores(m, link) if m.is_admin?
        if @users.keys.include? m.user.host
          if @users[m.user.host] > 2
            return m.reply 'ur doing that too much bru'
          else
            @users[m.user.host] += 1
            get_scores(m, link)
          end
        else
          @users[m.user.host] = 1
          Timer(180, options = { shots: 1 }) do |x|
            @users.delete(m.user.host)
          end
          get_scores(m, link)
        end
      end

      def random(m)
        if @users.keys.include? m.user.host
          if @users[m.user.host] > 2
            return m.reply 'ur doing that too much bru'
          else
            @users[m.user.host] += 1
            get_kpic(m)
          end
        else
          @users[m.user.host] = 1
          Timer(180, options = { shots: 1 }) do |x|
            @users.delete(m.user.host)
          end
          get_kpic(m)
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
        m.reply "r/kpics #{link}"
        get_scores(m, link)
      end

      def get_scores(m, link)
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
        sex = 'Male'
        sex = 'Female' if response.body['face_detection'].first['sex'] < 0.5
        if beauty > @scores[:top][1].to_f && sex == 'Female'
          update_db(m, 'top', beauty, link)
        end
        if beauty < @scores[:low][1].to_f && sex == 'Female'
          update_db(m, 'low', beauty, link)
        end
        m.reply "#{race.capitalize} #{sex} | Age: #{age} | Beauty: #{beauty}/100"
      end

      def update_db(m, table, beauty, link)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        conn.exec(
          "UPDATE #{table} SET score = #{beauty} WHERE score = #{@scores[table.to_sym][1]};"
        )
        conn.exec(
          "UPDATE #{table} SET url = '#{conn.escape(link)}' WHERE url = '#{@scores[table.to_sym][0]}';"
        )
        scores_hash(conn)
        m.reply "ding ding ding new #{table} score"
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
