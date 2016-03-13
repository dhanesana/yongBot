require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class P101
      include Cinch::Plugin

      match /(p101)$/
      match /(p101) (.+)/, method: :with_num
      match /(help p101)$/, method: :help

      def execute(m)
        with_num(m, '.', 'p101', 1)
      end

      def with_num(m, prefix, p101, rank)
        return m.reply 'invalid rank bru' if rank == "0"
        return with_name(m, '.', 'p101', rank) if rank.to_i < 1
        return m.reply "there's only 101 bru" if rank.to_i > 101
        feed = open("http://p101.pmrowla.com/api/idols?q={%22order_by%22:[{%22field%22:%22vote_percentage%22,%22direction%22:%22desc%22}]}&results_per_page=101").read
        result = JSON.parse(feed)
        idol = result['objects'][rank.to_i - 1]
        name = "#{idol['name_kr']} (#{idol['last_name_en']} #{idol['first_name_en']})"
        age = idol['age']
        rank_change = idol['prev_rank'] - rank.to_i
        rank_change = "+#{rank_change}" if rank_change > 0
        rank_change = "±#{rank_change}" if rank_change == 0
        agency = idol['agency']
        votes = idol['vote_percentage']
        votes_change = (idol['prev_vote_percentage'] - idol['vote_percentage']).round(2)
        votes_change *= -1 if votes_change < 0
        status = "Eliminated" if idol['is_eliminated'] == true
        m.reply "Rank #{rank}(#{rank_change}): #{name}, #{age}, Agency: #{agency}, Votes: #{votes}%(+#{votes_change})"
      end

      def with_name(m, prefix, p101, name)
        input_array = name.split(/[[:space:]]/)
        input = input_array.join(' ').downcase
        feed = open("http://p101.pmrowla.com/api/idols?q={%22order_by%22:[{%22field%22:%22vote_percentage%22,%22direction%22:%22desc%22}]}&results_per_page=101").read
        result = JSON.parse(feed)
        rank = ''
        result['objects'].each do |object|
          if object['name_kr'] == name
            puts '*' * 50
            rank += "#{result['objects'].index(object) + 1}"
          elsif "#{object['last_name_en'].downcase} #{object['first_name_en'].downcase}" == name.downcase
            puts '$' * 50
            rank += "#{result['objects'].index(object) + 1}"
          end
        end
        return m.reply "#{name} not found bru" if rank == ''
        with_num(m, '.', 'p101', rank)
      end

      def help(m)
        m.reply "returns produce101 contestant at specified voting rank or name"
      end

    end
  end
end
