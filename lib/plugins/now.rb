require 'unirest'
require 'open-uri'

class Now
  include Cinch::Plugin

  match /(now) (.+)/, prefix: /^(\.)/
  match /(help now)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, now, location)
    response = Unirest.get "https://montanaflynn-geocoder.p.mashape.com/address?address=#{URI.encode(location)}",
      headers:{
        "X-Mashape-Key" => "#{ENV['REK_MASHAPE']}",
        "Accept" => "application/json"
      }
    return m.reply 'not a real place bru' if response.body.first.first == 'error'
    city = response.body['city']
    region = response.body['region']
    country = response.body['country']
    lat = response.body['latitude']
    long = response.body['longitude']
    response_2 = Unirest.get "http://api.timezonedb.com/?lat=#{lat}&lng=#{long}&format=json&key=#{ENV['TIMEZONE']}"
    time = response_2.body['timestamp'].to_s
    m.reply "#{city}, #{region} | #{DateTime.strptime(time,'%s').strftime("%B %d, %Y %I:%M %p")}"
  end

  def help(m)
    m.reply 'returns current date and time for specified location'
  end

end
