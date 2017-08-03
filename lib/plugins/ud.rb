require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Ud
      include Cinch::Plugin

      match /(ud) (.+)/
      match /(help ud)$/, method: :help

      def execute(m, prefix, ud, keywords)
        query = keywords.split(/[[:space:]]/).join(' ').downcase
        response = Unirest.get("http://api.urbandictionary.com/v0/define?term=#{URI.encode(query)}")
        return m.reply "no word found bru" if response.body['list'] == []
        definition = response.body['list'].first['definition'].strip.gsub(/\r/,"").gsub(/\n/,"")
        word_entry = response.body['list'].first['word'].strip.gsub(/\r/,"").gsub(/\n/,"")
        response = "#{word_entry} => #{definition}"
        m.reply "#{response.length > 255 ? response[0, 255] + "..." : response}"
      end

      def help(m)
        m.reply 'returns urbandictionary definition for specified term'
      end

    end
  end
end
