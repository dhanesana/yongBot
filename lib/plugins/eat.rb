require 'json'
require 'open-uri'

module Cinch
  module Plugins
    class Eat
      include Cinch::Plugin

      match /(eat) (.+)/
      match /(help eat)$/, method: :help

      def execute(m, prefix, eat, item)
        # GET FOOD ID
        query = item.split(/[[:space:]]/).join(' ').downcase
        link = open("https://api.nutritionix.com/v1_1/search/#{URI.encode(query.downcase)}?results=0%3A1&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=#{ENV['NUTRITIONX_ID']}&appKey=#{ENV['NUTRITION_KEY']}").read
        result = JSON.parse(link)
        return m.reply "sorry bru nutritionix don't got #{query} in their database" if result['total_hits'] == 0
        food_id = result['hits'].first['_id']
        # GET NAME AND CALORIES
        link2 = open("https://api.nutritionix.com/v1_1/item?id=#{food_id}&appId=#{ENV['NUTRITIONX_ID']}&appKey=#{ENV['NUTRITION_KEY']}").read
        result2 = JSON.parse(link2)
        calories = result2['nf_calories']
        name = result2['item_name']
        protein = result2['nf_protein']
        m.reply "Item: #{name} | Calories: #{calories} | Protein: #{protein} g"
      end

      def help(m)
        m.reply 'returns calories and protein amount for specified food item'
      end

    end
  end
end
