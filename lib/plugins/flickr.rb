require 'httparty'
require 'open-uri'
require 'json'

class Flickr
  include Cinch::Plugin

  match /(flickr) (.+)/, prefix: /^(\.)/
  match /(help flickr)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, flickr, user)
    username = URI.encode(user.split(/[[:space:]]/).join(' ').downcase)
    buffet = open("https://api.flickr.com/services/rest/?method=flickr.people.findByUsername&api_key=#{ENV['FLICKR_KEY']}&username=#{username}&format=json&nojsoncallback=1").read
    result = JSON.parse(buffet)
    nsid = result['user']['nsid']
    photos_req = open("https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=#{ENV['FLICKR_KEY']}&user_id=#{nsid}&format=json&nojsoncallback=1").read
    response = JSON.parse(photos_req)

    return m.reply 'nada' if response['photos']['photo'].size == 0

    photo_title = response['photos']['photo'].first['title']
    photo_id = response['photos']['photo'].first['id']

    m.reply "https://www.flickr.com/photos/#{nsid}/#{photo_id}/"
  end

  def help(m)
    m.reply 'returns most recent flickr pic of specified user'
  end

end
