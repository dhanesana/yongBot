require 'httparty'
require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class Flickr
      include Cinch::Plugin

      match /(flickr) (.+)/
      match /(help flickr)$/, method: :help

      def execute(m, prefix, flickr, user)
        username = URI.encode(user.split(/[[:space:]]/).join(' ').downcase)
        nsid_req = open("https://api.flickr.com/services/rest/?method=flickr.people.findByUsername&api_key=#{ENV['FLICKR_KEY']}&username=#{username}&format=json&nojsoncallback=1").read
        result = JSON.parse(nsid_req)
        return m.reply "#{result[message]}" if result['stat'] == 'fail'
        nsid = result['user']['nsid'].strip
        photos_req = open("https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=#{ENV['FLICKR_KEY']}&user_id=#{nsid}&format=json&nojsoncallback=1").read
        response = JSON.parse(photos_req)
        return m.reply 'no photos found bru' if response['photos']['photo'].size == 0
        photo_title = response['photos']['photo'].first['title'].strip
        photo_id = response['photos']['photo'].first['id'].strip
        url = "https://www.flickr.com/photos/#{nsid}/#{photo_id}/"
        exif_req = JSON.parse(open("https://api.flickr.com/services/rest/?method=flickr.photos.getExif&api_key=#{ENV['FLICKR_KEY']}&photo_id=#{photo_id}&format=json&nojsoncallback=1").read)
        camera = ''
        exposure = ''
        aperture = ''
        focal = ''
        exif_req['photo']['exif'].each do |tag|
          if tag['label'] == "Model"
            camera += tag['raw']['_content'].strip
          end
          if tag['label'] == "Focal Length"
            focal += tag['clean']['_content'].strip
          end
          if tag['label'] == "Aperture"
            aperture += tag['clean']['_content'].strip
          end
          if tag['label'] == "Exposure"
            exposure += tag['clean']['_content'].strip
          end
        end
        m.reply "#{url} => #{camera} #{focal}, #{aperture}, #{exposure}"
      end

      def help(m)
        m.reply 'returns most recent flickr pic of specified user'
      end

    end
  end
end
