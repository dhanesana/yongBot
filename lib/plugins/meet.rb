require 'open-uri'
require 'json'
require 'time'

class Meet
  include Cinch::Plugin

  match /(meet)$/, prefix: /^(\.)/
  match /(help meet)$/, method: :help, prefix: /^(\.)/


  def execute(m)
    feed = open("http://mwave.interest.me/meetgreet/list.json").read
    result = JSON.parse(feed)
    today = (Time.now.utc - (07 * 3600)).strftime("%Y%m%d")
    meets = ''
    result['listMap'].each do |x|
      meets += x['TITLE'] if (Time.strptime("#{x['START_TM']}", '%Q').strftime("%Y%m%d")) == today
      meets += " #{(Time.strptime("#{x['START_TM']}", '%Q') + (16 * 3600)).strftime("%H:%M")}KST | " if (Time.strptime("#{x['START_TM']}", '%Q').strftime("%Y%m%d")) == today
    end
    # m.reply "#{result['listMap'][0]['START_TM']}"
    return m.reply "no scheduled meet & greets today bru" if meets.size < 1
    m.reply meets.join(', ')
  end

  def help(m)
    m.reply "returns mwave meet & greets scheduled for the day"
  end

end
