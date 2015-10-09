require 'open-uri'
require 'unirest'

class Wutdis
  include Cinch::Plugin

  match /(wutdis) (.+)/, prefix: /^(\.)/
  match /(help wutdis)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, wutdis, link)
    url = URI.encode(link)
    response = Unirest.post "http://rekognition.com/func/api/?api_key=#{ENV['REKOGNITION_KEY']}&api_secret=#{ENV['REKOGNITION_SECRET']}&jobs=scene_understanding_3&urls=#{url}",
      headers:{
        "X-Mashape-Key" => "#{ENV['MASHAPE_KEY']}",
        "Content-Type" => "application/x-www-form-urlencoded",
        "Accept" => "application/json"
      }

    match1 = response.body['scene_understanding']['matches'].first['tag']
    score1 = (response.body['scene_understanding']['matches'].first['score'].to_f * 100).round(2)
    # match2 = response.body['scene_understanding']['matches'][1]['tag']
    # score2 = " and maybe a #{(response.body['scene_understanding']['matches'][1]['score'].to_f * 100).round(2)}"

    m.reply "looks like a #{match1.downcase}.. maybe. i'm #{score1.to_i}% sure tho.."
  end

  def help(m)
    m.reply 'returns a description of a specified image'
  end

end
