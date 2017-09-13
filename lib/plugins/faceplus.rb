require 'unirest'
require 'pg'

module Cinch
  module Plugins
    class FacePlus
      include Cinch::Plugin

      match /(faceplus) (.+)/
      match /(faceplus)$/, method: :random
      match /(faceplus top)$/, method: :top
      match /(faceplus high)$/, method: :top
      match /(faceplus low)$/, method: :low
      match /(faceplus bottom)$/, method: :low
      match /(help faceplus)$/, method: :help
      match /(help faceplus top)$/, method: :help_top
      match /(help faceplus high)$/, method: :help_top
      match /(help faceplus low)$/, method: :help_low
      match /(help faceplus bottom)$/, method: :help_low

      def initialize(*args)
        super
        @users = Hash.new
        create_table
      end

      def create_table
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        begin
          res = conn.exec_params("CREATE TABLE plus_top (url VARCHAR, score DECIMAL);")
          res_2 = conn.exec_params("CREATE TABLE plus_bottom (url VARCHAR, score DECIMAL);")
          conn.exec(
            "INSERT INTO plus_top (url, score) VALUES ('http://google.com', 0.001);"
          )
          conn.exec(
            "INSERT INTO plus_bottom (url, score) VALUES ('http://apple.com', 100);"
          )
        rescue PG::Error => pg_error
          puts '*' * 50
          puts "Table creation failed: #{pg_error.message}"
        end
        scores_hash(conn)
      end

      def scores_hash(conn)
        top_urls = conn.exec("SELECT url FROM plus_top;")
        top_scores = conn.exec("SELECT score FROM plus_top;")
        low_urls = conn.exec("SELECT url FROM plus_bottom;")
        low_scores = conn.exec("SELECT score FROM plus_bottom;")
        @scores = {
          plus_top: [top_urls[0]['url'], top_scores[0]['score']],
          plus_bottom: [low_urls[0]['url'], low_scores[0]['score']]
        }
      end

      def top(m)
        m.reply "#{@scores[:plus_top][0]} Beauty: #{@scores[:plus_top][1]}/100"
      end

      def low(m)
        m.reply "#{@scores[:plus_bottom][0]} Beauty: #{@scores[:plus_bottom][1]}/100"
      end

      def execute(m, prefix, faceplus, url)
        return if %w(top high bottom low).include? url.downcase
        get_scores(m, URI.encode(url)) if rate_limit(m) == 'ok'
      end

      def random(m)
        get_kpic(m) if rate_limit(m) == 'ok'
      end

      def rate_limit(m)
        return 'ok' if m.is_admin?
        if @users.keys.include? m.user.host
          if @users[m.user.host] > 2
            return m.reply 'ur doing that too much bru'
          else
            @users[m.user.host] += 1
            'ok'
          end
        else
          @users[m.user.host] = 1
          Timer(180, options = { shots: 1 }) do |x|
            @users.delete(m.user.host)
          end
          'ok'
        end
      end

      def get_kpic(m)
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
        posts.delete_if { |post| post[-1] == '/' }
        url = posts.sample
        m.reply "r/kpics #{url}"
        get_scores(m, url)
      end

      def get_scores(m, url)
        response = Unirest.post("https://api-us.faceplusplus.com/facepp/v3/detect?image_url=#{url}&api_key=#{ENV['FACEPLUS_KEY']}&api_secret=#{ENV['FACEPLUS_SECRET']}&return_attributes=gender,age,ethnicity,emotion,beauty")
        return m.reply "Status Code: #{response.code}" if response.code != 200
        return m.reply "#{m.user.nick}: no face detected bru" if response.body['faces'].size < 1
        emotion = 'Emotion: '
        response.body['faces'].first['attributes']['emotion'].each do |emo|
          emotion += "#{emo[0]} => #{emo[1]}%, " if emo[1] > 9
        end
        gender = response.body['faces'].first['attributes']['gender']['value']
        age = response.body['faces'].first['attributes']['age']['value']
        race = response.body['faces'].first['attributes']['ethnicity']['value']
        beauty = response.body['faces'].first['attributes']['beauty']["#{gender.downcase}_score"].round(3)
        update_db(m, 'plus_top', beauty, url) if beauty > @scores[:plus_top][1].to_f && gender.capitalize == 'Female'
        update_db(m, 'plus_bottom', beauty, url) if beauty < @scores[:plus_bottom][1].to_f && gender.capitalize == 'Female'
        m.reply "#{m.user.nick}: [#{race} #{gender}, Age: #{age}, #{emotion.chomp(', ')}, Beauty: #{beauty}/100]"
      end

      def update_db(m, table, score, link)
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        conn.exec(
          "UPDATE #{table} SET score = #{score} WHERE score = #{@scores[table.to_sym][1]};"
        )
        conn.exec(
          "UPDATE #{table} SET url = '#{conn.escape(link)}' WHERE url = '#{@scores[table.to_sym][0]}';"
        )
        scores_hash(conn)
        m.reply "ding ding ding new high score" if table == 'plus_top'
        m.reply "dun dun dun new low score" if table == 'plus_bottom'
      end

      def help(m)
        m.reply "facial detection for ethnicity, gender, age, and emotion using Face++ v3"
      end

      def help_top(m)
        m.reply 'returns image with highest beauty score'
      end

      def help_low(m)
        m.reply 'returns image with lowest beauty score'
      end

    end
  end
end
