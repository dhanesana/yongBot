require 'open-uri'
require 'unirest'
require 'httparty'
require 'yaml'

class Face
  include Cinch::Plugin

  match /(face) (.+)/, prefix: /^(\.)/
  match /(face)$/, method: :random, prefix: /^(\.)/
  match /(face top)$/, method: :top, prefix: /^(\.)/
  match /(face low)$/, method: :low, prefix: /^(\.)/
  match /(help face)$/, method: :help, prefix: /^(\.)/
  match /(help face top)$/, method: :help_top, prefix: /^(\.)/
  match /(help face low)$/, method: :help_low, prefix: /^(\.)/

  def initialize(*args)
    super
    if File.exist?('face.yml')
      @score = YAML.load_file('face.yml')
    else
      File.new('face.yml', 'w')
      first = { 'none' => 0 }.to_yaml
      File.open('face.yml', 'w') { |h| h.write first }
      @score = YAML.load_file('face.yml')
    end
    if File.exist?('low_face.yml')
      @low_score = YAML.load_file('low_face.yml')
    else
      File.new('low_face.yml', 'w')
      first = { 'none' => 100 }.to_yaml
      File.open('low_face.yml', 'w') { |h| h.write first }
      @low_score = YAML.load_file('low_face.yml')
    end
  end

  def top(m)
    @score = YAML.load_file('face.yml')
    m.reply "#{@score.first[0]} Beauty: #{@score.first[1]}/100"
  end

  def low(m)
    @low_score = YAML.load_file('low_face.yml')
    m.reply "#{@low_score.first[0]} Beauty: #{@low_score.first[1]}/100"
  end

  def execute(m, command, face, link)
    url = URI.encode(link)
    response = Unirest.post "https://orbeus-rekognition.p.mashape.com/?api_key=#{ENV['REKOGNITION_KEY']}&api_secret=#{ENV['REKOGNITION_SECRET']}&jobs=face_part_gender_age_emotion_beauty_race_recognize&urls=#{url}",
      headers:{
        "X-Mashape-Key" => "#{ENV['REK_MASHAPE']}",
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
    @score = YAML.load_file('face.yml')
    @low_score = YAML.load_file('low_face.yml')
    if beauty > @score.first[1] && sex == 'Female'
      File.open('face.yml', 'w') do |h|
        h.write hash.to_yaml
      end
      m.reply "ding ding ding new high score"
    end
    if beauty < @low_score.first[1]
      File.open('low_face.yml', 'w') do |h|
        h.write hash.to_yaml
      end
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
      # posts << post['data']['preview']['images'].first['source']['url'] unless post['data']['domain'] == 'gfycat'
    end
    link = posts.sample
    url = URI.encode(link)
    response = Unirest.post "https://orbeus-rekognition.p.mashape.com/?api_key=#{ENV['REKOGNITION_KEY']}&api_secret=#{ENV['REKOGNITION_SECRET']}&jobs=face_part_gender_age_emotion_beauty_race_recognize&urls=#{url}",
      headers:{
        "X-Mashape-Key" => "#{ENV['REK_MASHAPE']}",
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
    @score = YAML.load_file('face.yml')
    @low_score = YAML.load_file('low_face.yml')
    if beauty > @score.first[1] && sex == 'Female'
      File.open('face.yml', 'w') do |h|
        h.write hash.to_yaml
      end
      m.reply "ding ding ding new high score"
    end
    if beauty < @low_score.first[1]
      File.open('low_face.yml', 'w') do |h|
        h.write hash.to_yaml
      end
      m.reply "dun dun dun new low score..."
    end

    m.reply "#{race.capitalize} #{sex} | Age: #{age} | Status: #{status} | Beauty: #{beauty}/100"
  end

  def help(m)
    m.reply "returns estimated race, sex, age, and beauty for specified image. if image isn't specified, random image from kpics is used"
  end

  def help_top(m)
    m.reply 'returns highest beauty scored image'
  end

  def help_low(m)
    m.reply 'returns lowest beauty scored image'
  end

end
