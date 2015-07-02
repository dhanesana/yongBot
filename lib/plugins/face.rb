require 'open-uri'
require 'unirest'

class Face
  include Cinch::Plugin

  match /(face) (.+)/, prefix: /^(\.)/
  match /(help face)$/, method: :help, prefix: /^(\.)/

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

    m.reply "#{race.capitalize} #{sex} | Age: #{age} | Status: #{status} | Beauty: #{beauty}/100"
  end

  def help(m)
    m.reply 'returns estimated race, sex, age, and beauty for specified image'
  end

end