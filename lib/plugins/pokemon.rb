require 'open-uri'
require 'json'

module Cinch
  module Plugins
    class Pokemon
      include Cinch::Plugin

      match /(pokemon) (.+)/, prefix: /^(\.)/
      match /(help pokemon)$/, method: :help, prefix: /^(\.)/

      def execute(m, prefix, pokemon, name)
        link = open("http://pokeapi.co/api/v1/pokemon/#{name.downcase}").read
        result = JSON.parse(link)
        id = result['national_id']
        hitPoints = result['hp']
        types = "Type(s): "
        types_array = []
        image = "Image: http://pokeapi.co/media/img/#{id}.png"
        hp = "HP: #{hitPoints}"

        if result['types'].size > 1
          result['types'].each { |type| types_array << type['name'] }
          types += types_array.join(', ')
        else
          result['types'].each { |type| types += "#{type['name']}" }
        end

        image = 'http://i.imgur.com/diheSTI.jpg' if name.downcase == "squirtle"
        m.reply "ID: #{id} | #{types} | #{hp} Atk: #{result['attack']} Def: #{result['defense']} | #{image}"
      end

      def help(m)
        m.reply "returns specified pokemon's id, type, hp, atk, def, and img"
      end

    end
  end
end
