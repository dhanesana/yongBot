require 'open-uri'
require 'json'
require 'time'

class Meet
  include Cinch::Plugin

  match /(meet)$/, prefix: /^(\.)/
  match /(meet list)$/, method: :list, prefix: /^(\.)/
  match /(help meet)$/, method: :help, prefix: /^(\.)/
  match /(help meet list)$/, method: :help_meet, prefix: /^(\.)/

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
      if x['START_TM_SHORT_FLG'] == 'Y'
        unconfirmed["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    @result_2['listMap'].each do |x|
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
      if x['START_TM_SHORT_FLG'] == 'Y'
        unconfirmed["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    meets = meets.sort_by { |title, date| date }
    unconfirmed = unconfirmed.sort_by { |title, date| date }
    m.reply "Next Confirmed M&G - #{meets.first.first} #{((Time.strptime(meets.first[1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}"
    m.reply "Next Unconfirmed M&G - #{unconfirmed.first.first} #{((Time.strptime(unconfirmed.first[1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}"
  end

  def list(m)
    meets = {}
    unconfirmed = {}

    @result['listMap'].each do |x|
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
      if x['START_TM_SHORT_FLG'] == 'Y'
        unconfirmed["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    @result_2['listMap'].each do |x|
      if x['START_TM_SHORT_FLG'] == 'N'
        meets["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
      if x['START_TM_SHORT_FLG'] == 'Y'
        unconfirmed["#{x['TITLE']}"] = (x['START_TM']).to_i unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
      end
    end

    meets = meets.sort_by { |title, date| date }
    unconfirmed = unconfirmed.sort_by { |title, date| date }
    list = "Confirmed: "
    un_list = "Unconfirmed: "
    num = meets.size
    num_2 = unconfirmed.size
    i = 0
    u = 0
    while i < meets.size
      list += "[#{meets[i].first}, #{((Time.strptime(meets[i][1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}]"
      i += 1
      list += ", "
    end
    while u < unconfirmed.size
      un_list += "[#{unconfirmed[i].first}, #{((Time.strptime(unconfirmed[i][1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}]"
      u += 1
      un_list += ", "
    end
    m.reply list
    m.reply un_list
  end

  def help(m)
    m.reply "returns next scheduled mwave meet & greet"
  end

  def help_meet(m)
    m.reply "returns a list of upcoming mwave meet & greets"
  end

end
