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
    response_3 = Unirest.get "http://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{long}"
    kelvin = response_3.body['main']['temp'].to_f
    temp = ((kelvin - 273.15) * 1.8000 + 32).round(2)
    m.reply "#{city}, #{region} | #{DateTime.strptime(time,'%s').strftime("%B %d, %Y %I:%M %p")} | Temp: #{temp} F"
  end

  def help(m)
    m.reply 'returns current date and time for specified location'
  end

end
