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
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    result_2['listMap'].each do |x|
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end
    meets = meets.sort_by { |title, date| date }
    m.reply "Next Meet & Greet - #{meets.first.first} #{((Time.strptime(meets.first[1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}"
  end

  def help(m)
    m.reply "returns next scheduled mwave meet & greet"
  end

end
