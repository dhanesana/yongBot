require 'unirest'
require 'open-uri'

class Now
  include Cinch::Plugin

  match /(now) (.+)/, prefix: /^(\.)/
  match /(help now)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, now, location)
    loc_array = location.split(/[[:space:]]/)
    loc = loc_array.join(' ').downcase
    if loc.to_i == 0
      response = Unirest.get "http://api.openweathermap.org/data/2.5/weather?q=#{URI.encode(loc)}"
    else
      response = Unirest.get "http://api.openweathermap.org/data/2.5/weather?zip=#{loc.to_i}"
    end
    long = response.body['coord']['lon']
    lat = response.body['coord']['lat']
    kelvin = response.body['main']['temp'].to_f
    temp = ((kelvin - 273.15) * 1.8000 + 32).round(2)
    humid = response.body['main']['humidity']
    feels = -42.379 + 2.04901523*temp + 10.14333127*humid - 0.22475541*temp*humid - 6.83783*10**-3*temp**2 - 5.481717*10**-2*humid**2 +
        1.22874*10**-3*temp**2*humid + 8.5282*10**-4*temp*humid**2 - 1.99*10**-6*temp**2*humid**2
    city = response.body['name']
    country = response.body['sys']['country']
    response_2 = Unirest.get "http://api.timezonedb.com/?lat=#{lat}&lng=#{long}&format=json&key=#{ENV['TIMEZONE']}"
    time = response_2.body['timestamp'].to_s
    m.reply "#{city}, #{country} | #{DateTime.strptime(time,'%s').strftime("%B %d, %Y %I:%M %p")} | Temp: #{temp} F (feels like #{feels.round(2)} F tho) | Humidity: #{humid}%"
  end

  def help(m)
    m.reply 'returns current date, time, temp, heat index, and humidity for specified city or zip code'
  end

end
