require 'open-uri'
require 'json'
require 'time'

module Cinch
  module Plugins
    class Meet
      include Cinch::Plugin

      match /(meet)$/
      match /(mng)$/
      match /(meet list)$/, method: :list
      match /(mng list)$/, method: :list
      match /(help meet)$/, method: :help
      match /(help mng)$/, method: :help
      match /(help meet list)$/, method: :help_meet
      match /(help mng list)$/, method: :help_meet

      def initialize(*args)
        super
        begin
          @feed = open("http://mwave.interest.me/meetgreet/list.json").read
          @feed_2 = open("http://mwave.interest.me/meetgreet/list.json?page=2").read
          @result = JSON.parse(@feed)
          @result_2 = JSON.parse(@feed_2)
          @today = (Time.now.utc - (07 * 3600)).strftime("%Y%m%d")
        rescue
          p '*' * 50
          p 'Rescue: JSON ERROR'
          p '*' * 50
        end
      end

      def execute(m)
        meets = {}
        unconfirmed = {}

        @result['listMap'].each do |x|
          if x['START_TM_SHORT_FLG'] == 'N'
            meets["#{x['TITLE']}"] = [(x['START_TM']).to_i, x['MG_SEQ']] unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
          end
          if x['START_TM_SHORT_FLG'] == 'Y'
            unconfirmed["#{x['TITLE']}"] = [(x['START_TM']).to_i, x['MG_SEQ']] unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
          end
        end

        @result_2['listMap'].each do |x|
          if x['START_TM_SHORT_FLG'] == 'N'
            meets["#{x['TITLE']}"] = [(x['START_TM']).to_i, x['MG_SEQ']] unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
          end
          if x['START_TM_SHORT_FLG'] == 'Y'
            unconfirmed["#{x['TITLE']}"] = [(x['START_TM']).to_i, x['MG_SEQ']] unless DateTime.now.strftime('%Q').to_i > x['START_TM'].to_i
          end
        end

        meets = meets.sort_by { |title, date| date.first }
        unconfirmed = unconfirmed.sort_by { |title, date| date.first }
        if meets.size > 0
          m.reply "Confirmed => #{meets.first.first.strip} #{((Time.strptime(meets.first[1].first.to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")} http://mwave.interest.me/meetgreet/view/#{meets.first[1][1]}"
        else
          m.reply "No confirmed meet & greets"
        end
        if unconfirmed.size > 0
          m.reply "Unconfirmed => #{unconfirmed.first.first.strip} #{((Time.strptime(unconfirmed.first[1].first.to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")} http://mwave.interest.me/meetgreet/view/#{unconfirmed.first[1][1]}"
        end
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
        i = 0
        u = 0
        while i < meets.size
          list += "[#{meets[i].first.strip}, #{((Time.strptime(meets[i][1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}]"
          i += 1
          break if i == 5
          list += ", "
        end
        while u < unconfirmed.size
          un_list += "[#{unconfirmed[u].first.strip}, #{((Time.strptime(unconfirmed[u][1].to_s, '%Q').utc - (07 * 3600)) + (16 * 3600)).strftime("%m/%d %H:%MKST")}]"
          u += 1
          break if u == 5
          un_list += ", "
        end
        if list.size > 11
          list.slice!(-2..-1)
          m.reply list
        else
          m.reply 'No confirmed meet & greets'
        end
        if un_list.size > 13
          un_list.slice!(-2..-1)
          m.reply un_list
        end
      end

      def help(m)
        m.reply "returns next scheduled mwave meet & greet"
      end

      def help_meet(m)
        m.reply "returns a list of upcoming mwave meet & greets"
      end

    end
  end
end
