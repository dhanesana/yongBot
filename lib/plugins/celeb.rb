require 'open-uri'
require 'unirest'

class Celeb
  include Cinch::Plugin

  match /(celeb) (.+)/, prefix: /^(\.)/
  match /(help celeb)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, celeb, link)
    url = URI.encode(link)
    response = Unirest.post "https://orbeus-rekognition.p.mashape.com/?api_key=#{ENV['REKOGNITION_KEY']}&api_secret=#{ENV['REKOGNITION_SECRET']}&jobs=face_celebrity&urls=#{url}",
      headers:{
        "X-Mashape-Key" => "#{ENV['REK_MASHAPE']}",
        "Content-Type" => "application/x-www-form-urlencoded",
        "Accept" => "application/json"
      }
    return m.reply "no match found bru" if response.body['face_detection'] == []
    match = response.body['face_detection'].first['matches'].first['tag']
    score = response.body['face_detection'].first['matches'].first['score']
    m.reply "#{(score.to_f * 100).round(2)}% is #{match}"
  end

  def help(m)
    m.reply 'returns a celebrity that resembles/matches specified image'
  end

end