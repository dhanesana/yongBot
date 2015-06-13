require 'open-uri'
require 'json'
require 'time'

class Meet
  include Cinch::Plugin

  match /(meet)$/, prefix: /^(\.)/
  match /(meet list)$/, method: :list, prefix: /^(\.)/
  match /(help meet)$/, method: :help, prefix: /^(\.)/
  match /(help meet list)$/, method: :help_list, prefix: /^(\.)/

  def initialize(*args)
    super
    @feed = open("http://mwave.interest.me/meetgreet/list.json").read
    @feed_2 = open("http://mwave.interest.me/meetgreet/list.json?page=2").read
    @result = JSON.parse(@feed)
    @result_2 = JSON.parse(@feed_2)
    @today = (Time.now.utc - (07 * 3600)).strftime("%Y%m%d")
  end

  def execute(m)
    meets = {}
    unconfirmed = {}

    @result['listMap'].each do |x|
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    @result_2['listMap'].each do |x|
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    meets = meets.sort_by { |title, date| date }
    m.reply "Next Meet & Greet - #{meets.first.first} #{((Time.strptime(meets.first[1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}"
  end

  def list(m)
    meets = {}
    unconfirmed = {}

    @result['listMap'].each do |x|
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    @result_2['listMap'].each do |x|
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    meets = meets.sort_by { |title, date| date }
    list = "| "
    num = meets.size
    i = 0
    while i < meets.size
      list += "#{meets[i].first} #{((Time.strptime(meets[i][1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}"
      list += " | "
      i += 1
    end

    m.reply list
  end

  def help(m)
    m.reply "returns next scheduled mwave meet & greet"
  end

  def help_meet(m)
    m.reply "returns a list of upcoming mwave meet & greets"
  end

end
