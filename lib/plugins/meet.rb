require 'open-uri'
require 'json'
require 'time'

class Meet
  include Cinch::Plugin

  match /(meet)$/, prefix: /^(\.)/
  match /(help meet)$/, method: :help, prefix: /^(\.)/


  def execute(m)
    feed = open("http://mwave.interest.me/meetgreet/list.json").read
    feed_2 = open("http://mwave.interest.me/meetgreet/list.json?page=2").read
    result = JSON.parse(feed)
    result_2 = JSON.parse(feed)
    today = (Time.now.utc - (07 * 3600)).strftime("%Y%m%d")
    meets = {}

    result['listMap'].each do |x|
      meets["#{x['TITLE']}"] = (Time.strptime(x['START_TM'], '%Q') + (16 * 3600)).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
    end

    result_2['listMap'].each do |x|
      meets["#{x['TITLE']}"] = (Time.strptime(x['START_TM'], '%Q') + (16 * 3600)).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
    end

    # result_2['listMap'].each do |x|
    #   meets += x['TITLE'] if (Time.strptime("#{x['START_TM']}", '%Q').strftime("%Y%m%d")) == today
    #   meets += " #{(Time.strptime("#{x['START_TM']}", '%Q') + (16 * 3600)).strftime("%H:%M")}KST | " if (Time.strptime("#{x['START_TM']}", '%Q').strftime("%Y%m%d")) == today
    # end
    return m.reply "no scheduled meet & greets today bru" if meets.size < 1
    meets = meets.sort_by { |title, date| date }
    m.reply "Next - #{meets.first.first} #{Time.strptime(meets[meets.first.first].to_s, '%Q').strftime("%m/%d %H:%MKST")}"

  end

  def help(m)
    m.reply "returns next scheduled mwave meet & greet"
  end

end
